import processing.core.PApplet;
import ddf.minim.analysis.*;
import ddf.minim.*;

public class VenusPattern extends Drawable {
  BeatDetect beat;
  PImage venus;
  float low1;
  float low2;
  float low3;
  float low4;
  
  public VenusPattern(PApplet parent, BeatDetect beat, MidiStatus midi) {
    super(parent, midi);
    this.beat = beat;
    this.venus = loadImage("blue_venus.jpg");
  }
  
  public void draw() {
      if (this.beat.isKick()){
      lowCount = (lowCount + .5) % 64;
    }
   
    this.low1 = this.midi.sparklePadActive ? map(this.midi.sparklePadLevel, 0, 127, 0.6, 1) : max(0, this.low1 * 0.92);
    this.low2 = this.midi.sparklePadActive ? map(this.midi.sparklePadLevel, 0, 127, 0.6, 1) : max(0, this.low2 * 0.9);
    this.low3 = this.beat.isKick() &&  lowCount > 32  ? .66 : max(0, this.low3 * 0.87);
    this.low4 = this.beat.isKick() && lowCount  > 48  ? .7 : max(0, this.low4 * 0.85);
    
    mid = this.beat.isSnare() ? .3 : max(.1,mid * 0.96);
    

    int venus1Alpha = (int) map(low1, 0, 1, 0 ,255);
    int venus2Alpha = (int) map(low2, 0, 1, 0 ,255);
    int venus3Alpha = (int) map(low3, 0, 1, 0 ,255);
    int venus4Alpha = (int) map(low4, 0, 1, 0 ,255);
    
    blendMode(ADD);
   
    tint(64, 255, 255, venus1Alpha); 
    image(venus, 110, 150 , 100, 100);
      
    tint(96, 132, 196, venus2Alpha); 
    image(venus, 80, 200 , 80, 80);
      
    tint(132, 96, 148, venus3Alpha); 
    image(venus, 50, 250 , 80, 80);
     
    tint(255, 64, 132, venus4Alpha); 
    image(venus, 20, 300 , 80, 80);
  }
}
