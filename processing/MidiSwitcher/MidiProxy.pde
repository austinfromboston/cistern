 import processing.core.PApplet;
import themidibus.*;
import java.net.*;

public class MidiProxy implements RawMidiListener {
  PApplet parent;
  
  Socket socket;
  OutputStream output, pending;
  String host;
  int port;
  
  Thread thread;

  public MidiBus myBus; // The MidiBus
  
  public MidiProxy(String host, int port) {
    this.parent = parent;
    this.host = host;
    this.port = port;
    //this.myBus = new MidiBus(this, "LPD8", "LPD8"); // Create a new MidiBus object
  }
  public void rawMidiMessage(byte[] data) {
    try {
      //println("sending ", data.length);

      socket = new Socket(host, port);
      output = socket.getOutputStream();
      output.write(data);
      socket.close();
    } catch (Exception e) {
      println("esplode", e.toString());
    }
  }
}
