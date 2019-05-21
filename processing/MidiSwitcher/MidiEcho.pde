import themidibus.*;

public class MidiEcho implements RawMidiListener {
  public MidiProxy midiProxy; 
  public int NOTE_ON = 0x9a;
  public int NOTE_OFF = 0x8a;
  
  public MidiEcho(MidiProxy midiProxy) {
    this.midiProxy = midiProxy;
  }
  
  public void rawMidiMessage(byte[] data) {
    // echo only button presses
    //System.out.printf("pushed %x for (%x | %x)", data[0], NOTE_ON, NOTE_OFF);
    if ((data[0] == byte(NOTE_ON)) || (data[0] == byte(NOTE_OFF))) {
      this.midiProxy.rawMidiMessage(data);
    }
  }
    
}
