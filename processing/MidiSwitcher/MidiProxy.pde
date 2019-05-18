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
    this.host = host;
    this.port = port;
    int midiDevice = 0;
    println("the thing");
    MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
    this.myBus = new MidiBus(this, midiDevice, 1); // Create a new MidiBus object
  }
  public void rawMidiMessage(byte[] data) {
    try {
      println("sending ", data.length);

      socket = new Socket(host, port);
      output = socket.getOutputStream();
      output.write(data);
      socket.close();
    } catch (Exception e) {
      println("esplode", e.toString());
    }
  }
}
