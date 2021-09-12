
public class Plaid extends Drawable {
int w, j, i, p, z;
float x, y, d, a;

  public Plaid(PApplet parent, MidiStatus midi) {
    super(parent, midi);
    this.w = width / 3;
    this.p = 0;
  }
  void draw() {
    this.p+= 1 * map(this.midi.dialSettings[SPEED_DIAL], MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, 1, 20);
    if (!drawing) return;
    dialOrigins(1);
    push();
    float scaleSetting = map(this.midi.dialSettings[APERTURE_DIAL], 0, 127, 0.3, 3);
    //scale(scaleSetting);
    float pOffset = (this.w / 2) * scaleSetting;
    //float yOffset = (this.w * scaleSetting) / 2;
    //float scaledOriginX = this.originX / scaleSetting;
    //float scaledOriginY = this.originY / scaleSetting;
    for (j = -1; j < w; y = -1+2.0*j++/w) {
      for (i = -1; i < w; x = -1.0+2.0*i++/w, d = sqrt(x*x+y*y), 
        this.z = int(w*cos(a = atan2(y, x))/d+p)^int(w*sin(a)/d+p)) {
          color pColor = color(d, z&w, z&w);
          colorMode(HSB);
          pColor = color(hue(pColor) + hueAdj(), saturation(pColor), brightness(pColor));
          set(int((i*scaleSetting)+originX-pOffset), int((j*scaleSetting)+originY-pOffset), pColor);
          colorMode(RGB);
        }
    }
    scale(1);
    pop();
  }
}
