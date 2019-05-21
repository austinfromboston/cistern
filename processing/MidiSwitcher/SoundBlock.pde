import processing.sound.*;
//import ddf.minim.analysis.*;
//import ddf.minim.*;

public class SoundBlock extends Drawable {

  processing.sound.FFT fft;
  AudioIn mic; 
  Amplitude amp;
  float a;
  int bandCount = 64;
  //PGraphics canvas;
  
  
  public SoundBlock(PApplet parent, MidiStatus midi) {
    super(parent, midi);
    //fft.input(audioIn);
    this.a = 0;
  }

  void setup() {
    noStroke();
    //frameRate(30);
    this.mic = new processing.sound.AudioIn(parent, 0);
    mic.start();
    this.amp = new Amplitude(parent);
    amp.input(mic);
      
    this.fft = new processing.sound.FFT(parent, 64);
    //this.amp = new Amplitude(parent);
    //fft.linAverages( 30 );
    //this.audioIn = new AudioIn(parent, 0);
    //audioIn.start();
    //amp.input(audioIn);
    fft.input(mic);
    //audioIn.addListener(fft);
    //sound.loop();
    //this.canvas = createGraphics(width, height);
  }
  
  void addBackground() {
      background(20); 
  }
   
  void draw() {
    if (!this.drawing) { return; }
    a -= 0.1;
    //fft.forward(audioIn);
    //float[] spectrum = fft.analyze();
    pushMatrix();
    if (alphaAdj() > 120) {
      blendMode(REPLACE);
    }
    for (int x = -10; x < 10; x++) {
      for (int z = -10; z < 10; z++) {
         
        float y = int(40 * cos(0.55 * distance(x,z,0,0, fft.analyze()[x+z+20]) + a));  
        
        float xm = x*17 -8.5;
        float xt = x*17 +8.5;
        float zm = z*17 -8.5;
        float zt = z*17 +8.5;
        
        float halfw = width/2;
        float halfh = height/2;
            
        int isox1 = int(xm - zm + halfw);
        int isoy1 = int((xm + zm) * 0.5 + halfh);
        int isox2 = int(xm - zt + halfw);
        int isoy2 = int((xm + zt) * 0.5 + halfh);
        int isox3 = int(xt - zt + halfw);
        int isoy3 = int((xt + zt) * 0.5 + halfh);
        int isox4 = int(xt - zm + halfw);
        int isoy4 = int((xt + zm) * 0.5 + halfh);
        
        fill ( random(100, 200), random(200, 220), random(240, 255), alphaAdj());
        quad(isox2, isoy2-y, isox3, isoy3-y, isox3, isoy3+40, isox2, isoy2+40);
    
        fill(random(240, 255), random(100, 200), random(200, 220), alphaAdj());
        quad(isox3, isoy3-y, isox4, isoy4-y, isox4, isoy4+40, isox3, isoy3+40);
    
        fill(237, 237, 230, alphaAdj());
        quad(isox1, isoy1-y, isox2, isoy2-y, isox3, isoy3-y, isox4, isoy4-y);
   
      }
    }
    //canvas.endDraw();
    //image(canvas, 0, 0);
    popMatrix();
  }

  


  //The distance
  public float distance(int x, int y, float cx, float cy, float spectrum) {
    //fft変換
    //println("block seeing ", spectrum);
    //for(int i = 0; i < spectrum.length; i++){
    return sqrt(sq(cx - x) + sq(cy - y))+spectrum*100;
    //}
  }
}
