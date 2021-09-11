import processing.core.PApplet;
import themidibus.*;
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;

int COLOR_PAD = 40; // velocity is 0-127
int FLASH_PAD = 41;
int FLASH_PAD_2 = 42;
int FADE_OUT_PAD = 43;
int UNUSED_PAD_1 = 36;
int SPARKLE_PAD = 37;
int UNUSED_PAD_2 = 38;
int PAUSE_PAD = 39;



int GAIN_DIAL = 1; // dial values are 0-127
int APERTURE_DIAL = 2;
int SPEED_DIAL = 3;
int PATTERN_SELECTOR_DIAL = 4;
int DIRECTION_DIAL = 5;
int HUE_DIAL = 6;
int SATURATION_DIAL = 7;
int AMPLITUDE_DIAL = 8;
int X_LOCATION_DIAL = 7;
int Y_LOCATION_DIAL = 6;

int RIGHT_STICK_Y = APERTURE_DIAL;
int RIGHT_STICK_X = DIRECTION_DIAL;
int LEFT_STICK_Y = Y_LOCATION_DIAL;
int LEFT_STICK_X = X_LOCATION_DIAL;

public class MidiStatus implements SimpleMidiListener {
  PApplet parent;

  public int hueDial;
  public int speedDial;
  public int gainDial;
  public int patternSelectionDial;
  public int amplitudeDial;
  public float starSpeed;
  public boolean sparklePadActive;
  public int sparklePadLevel;
  public static final int DIAL_MIN = 0;
  public static final int DIAL_MAX = 127;
  public MidiBus myBus; // The MidiBus
  public MidiBus proxyBus; // The proxy MidiBus  
  public MidiEcho midiEcho; // echos allowed commands from the java board to Go
  public MidiProxy midiProxy;  
  public MidiDials midiDials;
  public GamepadStatus gamepadStatus;
  private boolean[] padEffectsActive;
  private int[] padEffectLevels;
  public boolean padEffectActive;
  public int padEffectLevel;
  public int[] dialSettings;
  public HashMap<String, Integer> lastUpdates;
  public int golangApertureDial = 127;
  public ArrayList<String> activeEffects;
  //public boolean scopeActive = false;
  
  public MidiStatus(PApplet parent) {
    this.parent = parent;
    this.parent.registerMethod("keyEvent", this);
    this.hueDial = 0;
    this.speedDial = 66;
    this.sparklePadLevel = 0;
    this.sparklePadActive = false;
    this.gainDial = 127;
    this.amplitudeDial = 127;
    this.patternSelectionDial = 0;
    this.padEffectLevels = new int[50];
    this.starSpeed = 1;
    this.lastUpdates = new HashMap<String, Integer>();
    Arrays.fill(padEffectLevels, 0);
    this.padEffectsActive = new boolean[50];
    Arrays.fill(padEffectsActive, false);
    this.dialSettings = new int[20];
    Arrays.fill(dialSettings, 64);
    this.gamepadStatus = new GamepadStatus(parent);
    this.activeEffects = new ArrayList<String>();
    MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
    String[] devices = MidiBus.availableInputs();
    for(String deviceDescription: devices) {
      String[] wirelessMatch = match(deviceDescription, "(?i)wireless");
      String[] lpdMatch = match(deviceDescription, "(?i)lpd8");
      if (wirelessMatch != null) {
        this.myBus = new MidiBus(this, deviceDescription, deviceDescription, "wireless"); 
      } else if (lpdMatch != null) {
        this.proxyBus = new MidiBus(midiProxy, deviceDescription, deviceDescription, "LPD8"); 
      }
    }
    midiProxy = new MidiProxy("localhost", 3333);
    if (this.proxyBus != null) {
      this.proxyBus.addMidiListener(midiProxy);
    }
    midiEcho = new MidiEcho(midiProxy);
    //midiDials = new MidiDials(this);
    if (this.proxyBus != null) {
      this.proxyBus.addMidiListener(midiProxy);
      //this.proxyBus.addMidiListener(midiDials);
    }
    if (this.proxyBus != null) {
      this.myBus.addMidiListener(midiEcho);
    }
    //this.myBus.addInput("Akai LPD8 Wireless");
  }
  
  public void checkGamepad() {
    ControllerState status = this.gamepadStatus.update();
    if (!status.isConnected) {
      return;
    }
    if (status.leftStickY != 0) {
      this.adjustDialWrapped(Y_LOCATION_DIAL, 0- status.leftStickY);
    }
    if (status.leftStickX != 0) {
      this.adjustDialPatternWrapped(X_LOCATION_DIAL, status.leftStickX);
    }
    if (status.dpadLeft) {
      this.patternSelectionDial = this.adjustDialWrapped(PATTERN_SELECTOR_DIAL, 2.5);
    }
    if (status.dpadRight) {
      this.patternSelectionDial = this.adjustDialWrapped(PATTERN_SELECTOR_DIAL, -2.5);
    }
    if (status.dpadUp) {
      this.speedDial = this.adjustDial(SPEED_DIAL, 1);
    }
    if (status.dpadDown) {
      this.speedDial = this.adjustDial(SPEED_DIAL, -1);
    }
    if (status.rightStickX != 0) {
      this.adjustDialWrapped(APERTURE_DIAL, status.rightStickX);
    }
    if (status.rightStickY != 0) {
      this.adjustDialWrapped(DIRECTION_DIAL, status.rightStickY);
    }
    if (status.xJustPressed) {
      this.toggleEffect("scope");
    }
    if (status.yJustPressed) {
      this.toggleEffect("scroll");
    }    
    if (status.aJustPressed) {
      this.toggleEffect("wave");
    }
    
    if (status.b && status.rightTrigger > 0) {
      float vector = - 0.5 + status.rightTrigger;
      this.toggleEffectOn("stars");
      this.starSpeed = Math.max(Math.min(this.starSpeed + (vector * 2), DIAL_MAX), DIAL_MIN);
    } else if (status.bJustPressed) {
      this.toggleEffect("stars");
    }
    if (status.leftTrigger > 0 && status.leftStickClick) {
      float vector = - 0.5 + status.leftTrigger;
      this.amplitudeDial = int(Math.max(Math.min(this.amplitudeDial + (vector * 2), DIAL_MAX), DIAL_MIN));
    } 
  }
  
  public void toggleEffect(String effectName) {
    if (this.activeEffects.contains(effectName)) {
      this.activeEffects.remove(effectName);
    } else {
      this.activeEffects.add(effectName);
    }
  }

  public void toggleEffectOn(String effectName) {
    if (this.activeEffects.contains(effectName)) {
      // do nothing
    } else {
      this.activeEffects.add(effectName);
    }
  }
  public int adjustDial(int dialName, float vector) {
    int newSetting = Math.max(Math.min(this.dialSettings[dialName] + int(vector * 2), DIAL_MAX), DIAL_MIN);
    this.dialSettings[dialName] = newSetting;
    return newSetting;
  }

  public int adjustDialWrapped(int dialName, float vector) {
    int oldSetting = this.dialSettings[dialName];
    if (oldSetting == DIAL_MAX && vector > 0) {
      this.dialSettings[dialName] = DIAL_MIN;
    } else if (oldSetting == DIAL_MIN && vector < 0) {
      this.dialSettings[dialName] = DIAL_MAX;
    }
    return adjustDial(dialName, vector);
  }
  
  public int adjustDialPatternWrapped(int dialName, float vector) {
    int oldSetting = this.dialSettings[dialName];
    if (oldSetting == DIAL_MAX && vector > 0) {
      this.adjustDialWrapped(PATTERN_SELECTOR_DIAL, 2.5);
    } else if (oldSetting == DIAL_MIN && vector < 0) {
      this.adjustDialWrapped(PATTERN_SELECTOR_DIAL, -2.5);
    }
    return this.adjustDialWrapped(dialName, vector);
  }
  
  public void controllerChange(int channel, int number, int value) {
    String dialName = "";
      if(number == HUE_DIAL) {
        this.hueDial = value;
        dialName = "hue";
      }
      if(number == GAIN_DIAL) {
        this.gainDial = value;
        dialName = "gain";  
      }
      if(number == SPEED_DIAL) {
        this.speedDial = value;
        dialName = "speed";  
      }
      if(number == PATTERN_SELECTOR_DIAL) {
        this.patternSelectionDial = value;
        dialName = "pattern";  
      }
      if(number == AMPLITUDE_DIAL) {
        this.amplitudeDial = value;
        dialName = "java alpha";  
      }
      this.dialSettings[number] = value;
      println("controllerChange dial " + dialName + " channel " + channel + ": number "+ number + ", value " + value);

  }
  
  public void keyEvent(KeyEvent e) {
    //if (e.getKey() != KeyEvent.PRESS) { return; }
    //println("i see key", e.getKeyCode());
    if (e.getKeyCode() == UP) {
      this.golangApertureDial += 2; 
    }      
    if (e.getKeyCode() == 40) {
      this.golangApertureDial += 2; 
    }
    if (e.getKeyCode() == 65) {
      dialSettings[PATTERN_SELECTOR_DIAL] += 5; 

    }
        if (e.getKeyCode() == 66) {
      dialSettings[PATTERN_SELECTOR_DIAL] -= 5; 

    }
  }
  
  public boolean isPadEffectActive() {
    for(int j = 0; j< this.padEffectsActive.length; j++) {
      if(this.padEffectsActive[j]) {
        return true;
      }
    }
    return false;
  }
  
  public int padEffectMaxLevel() {
    int maxLevel = 0;
    for(int j = 0; j< this.padEffectLevels.length; j++) {
      if(this.padEffectLevels[j] > maxLevel) {
        maxLevel = this.padEffectLevels[j];
      }
    }
    return maxLevel;
  }
  
  
  public void noteOn(int channel, int pitch, int velocity) {
    String padName = "";
      if(pitch == SPARKLE_PAD) {
        this.sparklePadActive = true;
        this.sparklePadLevel = velocity;
        padName = "sparkle";
      }
      this.padEffectsActive[channel] = true;
      this.padEffectLevels[channel] = velocity;
      this.padEffectActive = true;
      this.padEffectLevel = velocity;
      println("noteOn pad " + padName + " channel " + channel + ": pitch "+ pitch + ", velocity " + velocity);
  }

  public void noteOff(int channel, int pitch, int velocity) {
      println("noteOff channel " + channel + ": velocity "+ velocity);
      this.padEffectsActive[channel] = false;
      this.padEffectLevels[channel] = 0;
      this.padEffectActive = this.isPadEffectActive();
      this.padEffectLevel = this.padEffectMaxLevel();
      if(pitch == SPARKLE_PAD) {
        this.sparklePadActive = false;
        this.sparklePadLevel = 0;
      }
  }
  
}
