import processing.core.PApplet;
import ddf.minim.analysis.*;
import ddf.minim.*;
  
public class BackgroundScroll extends Drawable {

  PImage scroll;
  BeatDetect beat;
  AudioInput audioIn;
  float mid;
  int scrollSeam;
  
  public BackgroundScroll(PApplet parent, AudioInput audioIn, BeatDetect beat, MidiStatus midi) {
    super(parent, midi);
    this.beat = beat;
    this.mid = 0.7;
    this.scrollSeam = 0;
    this.audioIn = audioIn;
    this.scroll = loadImage("steamrainbow.jpg");
  }
  
  public int cycleMarker() {
    float scrollSpeed = map(this.midi.effectSpeed.get("scroll"), MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, 0.01, 1); 
    //return ((millis() % (100000))/ 2) / scrollSpeed % width;
    return int(millis() * scrollSpeed) % width;
  }
  
  public void draw() {
    if (!this.drawing) return;
    push();
      beat.detect(audioIn.mix);

      this.mid = this.beat.isSnare() ? .3 : max(.1,this.mid * 0.96);
      int scrollAlpha = (int) map(this.mid, 0, 1, 0 ,255);
      //int scrollAlpha = 255;
    
      blendMode(MULTIPLY);
      tint(adjustColor(color(255, scrollAlpha)));
      image(this.scroll, this.scrollSeam, 0, width, height);
      image(this.scroll, this.scrollSeam - width, 0, width, height);
      this.scrollSeam = this.cycleMarker();  
    pop();
  }

}
