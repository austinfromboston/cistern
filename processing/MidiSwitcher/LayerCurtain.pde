public class LayerCurtain {
  PApplet parent;
  MidiStatus midi;
  PGraphics pg;
  public LayerCurtain(PApplet parent, MidiStatus midi) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.midi = midi;
  }
  
  void setup() {
    this.pg = createGraphics(width, height);
  }
  void draw() {
    int curtainLevel = int(map(midi.amplitudeDial, 0, 127, 0, 255));
    //fill(color(255));
    //fill(color(0, 0, 0, curtainLevel));
    pg.beginDraw();
    pg.background(color(255, 0, 0, curtainLevel));
    pg.endDraw();
    //tint(curtainLevel);
    //noStroke();
    //println(curtainLevel);
    //translate(0, 0, -10000);
    //blendMode(DARKEST);
    //rect(0, 0, width, height);
    //box(width);
    //translate(-width/2, 0, 0);
    //translate(0, 0, -1000);
    //blendMode(REPLACE);
    image(this.pg, 0, 0);
  }
}
