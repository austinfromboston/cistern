import processing.core.PApplet;

public class StarField {
  PApplet parent;
  MidiStatus midi;
  boolean drawing;




  public StarField(
    PApplet parent,
    MidiStatus midi
  ) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.midi = midi;


    this.drawing = true;

  }

  private float radiusGrowth() {
    return 0.0;
  }

  void draw() {
    if(drawing) {





    }
  }
}
