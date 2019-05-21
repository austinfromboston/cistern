public class Drawable {
  public boolean drawing = true;
  MidiStatus midi;
  PApplet parent;
  public Drawable(PApplet parent, MidiStatus midi) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.midi = midi;
  }
  
  public void setup() {
    colorMode(RGB, 255);
  }
  
  public void addBackground() {
    background(0);
  }
  
  public void setDrawing(boolean newDrawing) {
    this.drawing = newDrawing;
  }
  
  public float alphaAdj() {
    return alphaAdj(255);
  }
  
  public float alphaAdj(float maxAlpha) {
    return map(midi.amplitudeDial, 0, 127, maxAlpha, 0);
  }
  
  
    
  public boolean allowProxy() {
    return true;
  }
  
  public color adjustColor(color c) {
    float red = red(c);
    float green = green(c);
    float blue = blue(c);
    float baseAlpha = alpha(c);
    return color(red, green, blue, alphaAdj(baseAlpha));
  }
}
