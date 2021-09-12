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
    //noStroke();
    //frameRate(30);
    this.mic = new processing.sound.AudioIn(parent, 0);
    mic.start();
    //this.amp = new Amplitude(parent);
    //amp.input(mic);
        println("Soundblock is active");
  
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
    push();
    noStroke();
    a -= 0.1 * map(this.midi.dialSettings[SPEED_DIAL], MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, 0.1, 3.5);
    dialOrigins(1);
    //fft.forward(audioIn);
    //float[] spectrum = fft.analyze();
    //pushMatrix();
    strokeWeight(0);
    if (alphaAdj() > 120) {
      blendMode(REPLACE);
    }
    float scaleSetting = map(this.midi.dialSettings[APERTURE_DIAL], 0, 127, 0.3, 3);
    scale(scaleSetting);
    for (int x = -10; x < 10; x++) {
      for (int z = -10; z < 10; z++) {
         
        float y = int(40 * cos(0.55 * distance(x,z,0,0, fft.analyze()[x+z+20]) + a));  
        
        float xm = x*17 -8.5;
        float xt = x*17 +8.5;
        float zm = z*17 -8.5;
        float zt = z*17 +8.5;
        
        float halfw = originX / scaleSetting;
        float halfh = originY / scaleSetting;
            
        int isox1 = int(xm - zm + halfw);
        int isoy1 = int((xm + zm) * 0.5 + halfh);
        int isox2 = int(xm - zt + halfw);
        int isoy2 = int((xm + zt) * 0.5 + halfh);
        int isox3 = int(xt - zt + halfw);
        int isoy3 = int((xt + zt) * 0.5 + halfh);
        int isox4 = int(xt - zm + halfw);
        int isoy4 = int((xt + zm) * 0.5 + halfh);
        
        colorMode(RGB);
        color pColor1 = color(random(100, 200), random(200, 220), random(240, 255), alphaAdj());
        color pColor2 = color(random(240, 255), random(100, 200), random(200, 220), alphaAdj());
        colorMode(HSB);
        pColor1 = color(hue(pColor1) + hueAdj(), saturation(pColor1), brightness(pColor1), this.alphaAdj());
        pColor2 = color(hue(pColor2) + hueAdj(), saturation(pColor1), brightness(pColor1), this.alphaAdj());

        fill ( pColor1);
        quad(isox2, isoy2-y, isox3, isoy3-y, isox3, isoy3+40, isox2, isoy2+40);
    
        fill(pColor2);
        quad(isox3, isoy3-y, isox4, isoy4-y, isox4, isoy4+40, isox3, isoy3+40);
        colorMode(RGB);
        fill(237, 237, 230, alphaAdj());
        quad(isox1, isoy1-y, isox2, isoy2-y, isox3, isoy3-y, isox4, isoy4-y);
   
      }
    }
    scale(1);
    //canvas.endDraw();
    //image(canvas, 0, 0);
    pop();
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
