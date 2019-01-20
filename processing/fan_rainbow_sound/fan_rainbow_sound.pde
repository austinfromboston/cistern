// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;

OPC opc;
PImage dot;
PImage colors;
TriangleGrid triangle;
Minim minim;
AudioInput in;
//AudioOutput out;
FFT fft;
float[] fftFilter;

float spin = 0.003;
float radiansPerBucket = radians(2);
float decay = 0.70;
float opacity = 15;
float minSize = 0.1;
float sizeScale = 0.5;

void setup()
{
  size(500, 500, P3D);

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();
  //out = minim.getLineOut();
  

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  dot = loadImage("rainbow4.jpeg");
  colors = loadImage("rainbow5.jpeg");

  
  opcFanBoy();
}


void opcFanBoy() {
  
  int ledStripCount = 120;
  int ledPixelSpacing = 2;
  int evenOffset = 24;
  int oddOffset = 17;
  
  float originX = width / 2;
  float originY = height / 2;
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI / 40;
  float arcStrip = PI / 20;
  
  for(int ray = 0; ray < 19; ray++){
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle + (ray * arcStrip);
    
    OPC rayOpc = new OPC(this, "192.168.1.70", 7890 + ray);
    rayOpc.ledRay(0,ledStripCount, originX, originY, rayOffset, ledPixelSpacing, rayAngle);
   
  }
}


void draw()
{
  background(0);

  fft.forward(in.mix);
  for (int i = 0; i < fftFilter.length; i++) {
    fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getBand(i)) * (1 + i * 0.01));
  }
  
  for (int i = 0; i < fftFilter.length; i += 3) {   
    color rgb = colors.get(int(map(i, 0, fftFilter.length-1, 0, colors.width-1)), colors.height/2);
    tint(rgb, fftFilter[i] * opacity);
    blendMode(ADD);
 
    float size = height * (minSize + sizeScale * fftFilter[i]);
    PVector center = new PVector(width * (fftFilter[i] * 0.2), 0);
    center.rotate(millis() * spin + i * radiansPerBucket);
    center.add(new PVector(width * .2, height * 0.5));
 
    image(dot, height/2 - size/2, width/2 - size/2, size, size);
  }
}
