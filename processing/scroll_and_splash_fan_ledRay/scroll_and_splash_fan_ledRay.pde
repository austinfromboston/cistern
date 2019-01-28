// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;

OPC opc;
PImage scroll;
PImage splash;
Minim minim;
AudioInput in;
//AudioOutput out;
FFT fft;
float[] fftFilter;
float[] fftFilterLast;

float spin = 0.003;
float radiansPerBucket = radians(2);
float decay = 0.95;
float opacity = 80;
float minSize = 0.1;
float sizeScale = 4.5;

BeatDetect beat;

float heightScale;

int foo = 0;

float size = 100;

void setup()
{
  size(500, 500, P3D);

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();
  
  

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  //scroll = loadImage("rainbow5.jpeg");
  scroll = loadImage("steamrainbow.jpg");
  splash = loadImage("steamrainbow.jpg");

  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  opcFanBoy();
}


void opcFanBoy() {
  
  int ledStripCount = 120;
  int ledPixelSpacing = 1;
  int evenOffset = 8;
  int oddOffset = 12;
  
  float originX = width / 40;
  float originY = height / 2;
  
  
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI / 2;
  
  
  for(int ray = 0; ray < 19; ray++){
    
    originX += width / 20;
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle ;
    
    OPC rayOpc = new OPC(this, "192.168.10.4", 7890 + ray, true);
    
    rayOpc.ledRay(0,ledStripCount, originX, originY, rayOffset, ledPixelSpacing, rayAngle);
   
  }
}


void draw()
{
  background(0);
  //image(dot, foo, 0, width, height);
  beat.detect(in.mix);

  //fft.forward(in.mix);
   image(scroll, foo, 0, width, height);
    image(scroll, foo - width, 0, width, height);
    foo = (millis() % 70000)/70 % width; 
  /*
  float fftAvg = 0;
  for (int i = 0; i < fftFilter.length; i++) {
    
    float fresh = .15 * log(1 + fft.getBand(i));
    float newVal = (fresh > fftFilter[i] * 1.01) ? fresh : fftFilter[i] * .92;
    
    fftFilter[i] = newVal;
  
  
  fftAvg += fftFilter[i];
    
  //  //fftFilter[i] = .25 * (max(fftFilter[i] * decay, log(1 + fft.getBand(i)) * (1 + i * 0.013)));
  //  //fftFilter[i] = .25 * (fftFilter[i] * decay + log(1 + fft.getBand(i)) * (1 + i * 0.013));
  }
  
   fftAvg = (fftFilter[11] + fftFilter[22] + fftFilter[33]) / 3;
   */
    blendMode(ADD);
   
    float low = height * (minSize + sizeScale * fftFilter[22]);
    float mid = height * (minSize + sizeScale * fftFilter[55]);
    float high = height * (minSize + sizeScale * fftFilter[99]);
    
    
    //float size = height * (minSize + sizeScale * fftAvg);
    
    if(beat.isKick()){  
      size = 300;
    }else {
      size = max(100, size * 0.95);
    }
     
    heightScale = min(2.5, map(size, 0, height, 1,2.5));
    tint(33, 153, 204, 255);
    //image(splash, height/2 - size/2, 0, size, height /heightScale);
    image(splash, 0, 0, width, height /heightScale);
    tint(255, 255);
     
    
    //image(dot, 0, height/2 - size/2, width, size);
   // image(dot, height/2 - size/2, widsize, width);
 // }
}
