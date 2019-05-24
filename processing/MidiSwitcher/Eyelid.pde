public class Eyelid extends Drawable {
  public Eyelid(PApplet parent, MidiStatus midi) {
    super(parent, midi);
  }
  
  void draw() {
    noStroke();
    blendMode(MULTIPLY);
    fill(0, 220);
    float rectTop = map(this.midi.golangApertureDial, 127, 0, -height, 0);
    //println(rectTop);
    rect(0, rectTop , width, height);
    blendMode(BLEND);
  }
}
