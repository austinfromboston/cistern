public class Drawable {
  public boolean drawing = true;
  MidiStatus midi;
  public Drawable(MidiStatus midi) {
    this.midi = midi;
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
  
  public color adjustColor(color c) {
    float red = red(c);
    float green = green(c);
    float blue = blue(c);
    float baseAlpha = alpha(c);
    return color(red, green, blue, alphaAdj(baseAlpha));
  }
}
