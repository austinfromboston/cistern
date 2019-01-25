// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;

OPC opc;
PImage dot;
PImage colors;
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
float sizeScale = 0.7;

int foo = 0;

void setup()
{
  size(500, 500, P3D);

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();
  
  

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  dot = loadImage("rainbow5.jpeg");
  //colors = loadImage("rainbow5.jpeg");

  
  opcFanBoy();
}


void opcFanBoy() {
  
  int ledStripCount = 120;
  int ledPixelSpacing = 1;
  int evenOffset = 8;
  int oddOffset = 12;
  
  float originX = 0;
  float originY = height / 2;
  
  
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI / 2;
  
  
  for(int ray = 0; ray < 19; ray++){
    
    originX += width / 20;
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle ;
    
    OPC rayOpc = new OPC(this, "192.168.10.3", 7890 + ray, true);
    
    rayOpc.ledRay(0,ledStripCount, originX, originY, rayOffset, ledPixelSpacing, rayAngle);
   
  }
}


void draw()
{
  background(0);
  //image(dot, foo, 0, width, height);

  fft.forward(in.mix);
  
  
  
  for (int i = 0; i < fftFilter.length; i++) {
    
    float fresh = .15 * log(1 + fft.getBand(i));
    float newVal = (fresh > fftFilter[i] * 1.01) ? fresh : fftFilter[i] * .92;
    
    fftFilter[i] = newVal;
    
    //fftFilter[i] = .25 * (max(fftFilter[i] * decay, log(1 + fft.getBand(i)) * (1 + i * 0.013)));
    //fftFilter[i] = .25 * (fftFilter[i] * decay + log(1 + fft.getBand(i)) * (1 + i * 0.013));
  }
  
 // for (int i = 0; i < fftFilter.length; i += 30) {   
  //  color rgb = colors.get(int(map(i, 0, fftFilter.length-1, 0, colors.width-1)), colors.height/2);
    
   
   
   
    blendMode(ADD);
    //image(dot, foo, 0, width, height);
    //image(dot, foo - width, 0, width, height);
    foo = (millis() % 70000)/70 % width; 
    
    float size = height * (minSize + sizeScale * fftFilter[22]);
    //PVector center = new PVector(width * (fftFilter[i] * 0.2), 0);
    //center.rotate(millis() * spin + i * radiansPerBucket);
    //center.add(new PVector(width * .2, height * 0.5));
 
    //image(dot, height/2 - size/2, 0, size, width);
    
    //image(dot, 0, height/2 - size/2, width, size);
   // image(dot, height/2 - size/2, widsize, width);
 // }
}
