
public class GeoBubbles extends Drawable {
  float t;
  float theta;
  int maxFrameCount = 200; // frameCount, change for faster or slower animation    
  
  public GeoBubbles(PApplet parent, MidiStatus midi) {
    super(parent, midi);
  }
  
  void draw() {
    if (!this.drawing) return;
  
    push();
    noStroke();
    dialOrigins(1);
    translate(originX, originY); // translate 0,0 to center
  
    float frameVelocity = map(this.midi.dialSettings[SPEED_DIAL], 0, 127, 300, 20);
    t = (float)frameCount/frameVelocity;
    theta = TWO_PI*t;
  
    float offsetAdjustment = map(this.midi.dialSettings[APERTURE_DIAL], 0, 127, 10, 90);
    float colorAdjustment = map(this.midi.dialSettings[COLOR_DIAL], 0, 127, 0, 200);
    for ( int x= -375; x <= 375; x += 25) {
      for (int y= -200; y <= 155; y += 50) {
        float offSet = round(offsetAdjustment)*x+y+y;   // play with offSet to change map below
  
        float x2 = map(cos(-theta+offSet), 0, 1, 0, 25); // map x position
        float y2 = map(cos(-theta+offSet), 0, 1, 25, 0); // map y position
        float sz2 = map(sin(-theta+offSet), 0, 1, 15, 45); // map size off the ellipse
        fill(150-(x/2) + colorAdjustment, 50+(x/6) + colorAdjustment, 350-(y/2) - colorAdjustment, alphaAdj()); // color with gradient created

        ellipse(x+x2, y-y2, sz2, sz2);
      }
    }
    pop();


  }
  //void setBackground() {
  //  background(0);
  //}
}
