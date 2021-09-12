public class Drawable {
  public boolean drawing = true;
  MidiStatus midi;
  PApplet parent;
  float originX;
  float originY;
  public Drawable(PApplet parent, MidiStatus midi) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.midi = midi;
  }
  
  public void setup() {
    colorMode(RGB, 255);
    dialOrigins();
  }
  
  public void dialOrigins() {
    dialOrigins(2);
  }
  
  public void dialOrigins(float heightFactor) {
    originX = map(midi.dialSettings[X_LOCATION_DIAL], 0, 127, 0, width);
    originY = map(midi.dialSettings[Y_LOCATION_DIAL], 0, 127, height - height/heightFactor, height);
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
    return map(midi.amplitudeDial, 0, 127, 0, maxAlpha);
  }
  
  public float hueAdj() {
    return map(this.midi.dialSettings[COLOR_DIAL], MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, -127, 127);
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
