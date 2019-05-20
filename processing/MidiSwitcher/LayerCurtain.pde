public class LayerCurtain {
  PApplet parent;
  MidiStatus midi;
  public LayerCurtain(PApplet parent, MidiStatus midi) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.midi = midi;
  }
  
  void draw() {
    int curtainLevel = int(map(midi.amplitudeDial, 0, 127, 0, 255));
    fill(color(255, 0, 0, curtainLevel));
    //fill(color(255, 0, 0, curtainLevel));
    
    //noStroke();
    //println(curtainLevel);
    //translate(0, 0, -10000);
    blendMode(DARKEST);
    rect(0, 0, -10, width, height);
    //box(width);
    //translate(-width/2, 0, 0);
    //translate(0, 0, -1000);

  }
}
