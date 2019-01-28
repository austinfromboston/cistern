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
int UNUSED_DIAL = 8;

public class MidiRequests {
  public int hueDial;
  public int speedDial;
  public boolean sparklePadActive;
  public int sparklePadLevel;
  public int DIAL_MIN = 0;
  public int DIAL_MAX = 127;

  
  public MidiRequests() {
    this.hueDial = 0;
    this.speedDial = 0;
    this.sparklePadLevel = 0;
    this.sparklePadActive = false;
  }
  
  
  public void controllerChange(int channel, int number, int value) {
      println("controllerChange channel " + channel + ": number "+ number + ", value " + value);
      if(number == HUE_DIAL) {
        this.hueDial = value;
      }
      if(number == SPEED_DIAL) {
        this.speedDial = value;
      }
  }
  
  public void noteOn(int channel, int pitch, int velocity) {
      println("noteOn channel " + channel + ": pitch "+ pitch + ", velocity " + velocity);
      if(pitch == SPARKLE_PAD) {
        this.sparklePadActive = true;
        this.sparklePadLevel = velocity;
      }
  }

  public void noteOff(int channel, int pitch, int velocity) {
      println("noteOff channel " + channel + ": velocity "+ velocity);
      if(pitch == SPARKLE_PAD) {
        this.sparklePadActive = false;
        this.sparklePadLevel = 0;
      }
  }
  
}
