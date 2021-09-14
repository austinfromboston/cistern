import processing.core.PApplet;
import themidibus.*;
import java.net.*;

public class MidiDials implements SimpleMidiListener {
  PApplet parent;
  
  Socket socket;
  OutputStream output, pending;
  String host;
  int port;
  
  Thread thread;

  //public MidiBus myBus; // The MidiBus
  public MidiStatus midi;
  
  public MidiDials(MidiStatus midi) {
    this.midi = midi;
  }
   public void controllerChange(int channel, int number, int value) {
    //String dialName = "";
    // just listen to Aperture dial
    if(number == APERTURE_DIAL) {
      midi.golangApertureDial = value;
    }
  }
  
  public void noteOn(int channel, int pitch, int velocity) {
  }
  public void noteOff(int channel, int pitch, int velocity) {
  }
}
