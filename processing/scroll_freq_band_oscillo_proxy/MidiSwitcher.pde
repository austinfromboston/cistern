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
int OPC_DIAL = 8;

public class MidiStatus implements SimpleMidiListener {
  PApplet parent;

  public int hueDial;
  public int speedDial;
  public int gainDial;
  public int opcDial;
  public boolean sparklePadActive;
  public int sparklePadLevel;
  public static final int DIAL_MIN = 0;
  public static final int DIAL_MAX = 127;
  public MidiBus myBus; // The MidiBus

  
  public MidiStatus(PApplet parent) {
    this.parent = parent;
    this.hueDial = 0;
    this.speedDial = 0;
    this.sparklePadLevel = 0;
    this.sparklePadActive = false;
    this.gainDial = 127;
    this.opcDial = 64;
    
    int midiDevice = 0;
    MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
    this.myBus = new MidiBus(this, midiDevice, 1); // Create a new MidiBus object
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
      if(number == OPC_DIAL) {
        this.opcDial = value;
        dialName = "opc"; 
      }
      println("controllerChange dial " + dialName + " channel " + channel + ": number "+ number + ", value " + value);

  }
  
  public void noteOn(int channel, int pitch, int velocity) {
    String padName = "";
      if(pitch == SPARKLE_PAD) {
        this.sparklePadActive = true;
        this.sparklePadLevel = velocity;
        padName = "sparkle";
      }
      println("noteOn pad " + padName + " channel " + channel + ": pitch "+ pitch + ", velocity " + velocity);
  }

  public void noteOff(int channel, int pitch, int velocity) {
      println("noteOff channel " + channel + ": velocity "+ velocity);
      if(pitch == SPARKLE_PAD) {
        this.sparklePadActive = false;
        this.sparklePadLevel = 0;
      }
  }
  
}
