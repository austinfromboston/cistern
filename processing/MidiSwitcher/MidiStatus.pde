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


public class MidiStatus implements SimpleMidiListener {
  PApplet parent;

  public int hueDial;
  public int speedDial;
  public int gainDial;
  public int patternSelectionDial;
  public int amplitudeDial;
  public boolean sparklePadActive;
  public int sparklePadLevel;
  public static final int DIAL_MIN = 0;
  public static final int DIAL_MAX = 127;
  public MidiBus myBus; // The MidiBus
  public MidiBus proxyBus; // The proxy MidiBus  
  public MidiEcho midiEcho; // echos allowed commands from the java board to Go
  public MidiProxy midiProxy;  
  public MidiDials midiDials;
  private boolean[] padEffectsActive;
  private int[] padEffectLevels;
  public boolean padEffectActive;
  public int padEffectLevel;
  public int[] dialSettings;
  public int golangApertureDial = 127;
  
  public MidiStatus(PApplet parent) {
    this.parent = parent;
    this.parent.registerMethod("keyEvent", this);
    this.hueDial = 0;
    this.speedDial = 66;
    this.sparklePadLevel = 0;
    this.sparklePadActive = false;
    this.gainDial = 127;
    this.amplitudeDial = 127;
    this.patternSelectionDial = 64;
    this.padEffectLevels = new int[50];
    Arrays.fill(padEffectLevels, 0);
    this.padEffectsActive = new boolean[50];
    Arrays.fill(padEffectsActive, false);
    this.dialSettings = new int[20];
    Arrays.fill(dialSettings, 64);
    
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
    midiEcho = new MidiEcho(midiProxy);
    midiDials = new MidiDials(this);
    //this.myBus.addInput("Akai LPD8 Wireless");
    this.proxyBus.addMidiListener(midiProxy);
    this.proxyBus.addMidiListener(midiDials);
    this.myBus.addMidiListener(midiEcho);
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
