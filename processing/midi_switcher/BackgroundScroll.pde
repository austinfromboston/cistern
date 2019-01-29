import processing.core.PApplet;
import ddf.minim.analysis.*;
import ddf.minim.*;

public class BackgroundScroll {
  PApplet parent;
  PImage scroll;
  BeatDetect beat;
  MidiStatus midi;
  float mid;
  int scrollSeam;
 
  
  public BackgroundScroll(PApplet parent, BeatDetect beat, MidiStatus midi) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.beat = beat;
    this.mid = 0;
    this.midi = midi;
    this.scrollSeam = 0;
    this.scroll = loadImage("steamrainbow.jpg");
  }
  
  public int cycleMarker() {
    //int scrollSpeed = Math.round(100-map(this.midi.speedDial, MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, 0, 80)); 
    return (millis() % (70 * 1000))/70 % width;
  }
  
  public void draw() {
    this.mid = this.beat.isSnare() ? .3 : max(.1,this.mid * 0.96);
    int scrollAlpha = (int) map(this.mid, 0, 1, 0 ,255);
  
    blendMode(ADD);
    tint(255, scrollAlpha);
    image(scroll, this.scrollSeam, 0, width, height);
    image(scroll, this.scrollSeam - width, 0, width, height);
    this.scrollSeam = this.cycleMarker();  
  }
}
