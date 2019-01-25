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
FFT fft;
float[] fftFilter;

String filename = "083_trippy-ringysnarebeat-3bars.mp3";
float spin = 0.001;
float radiansPerBucket = radians(2);
float decay = 0.97;
float opacity = 40;
float minSize = 0.1;
float sizeScale = 0.5;

void setup()
{
  size(300, 300, P3D);

  minim = new Minim(this); 

  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  dot = loadImage("dot.png");
  colors = loadImage("colors.png");

  opcFanBoy();
}

void opcFanBoy() {
  
  int ledStripCount = 120;
  int ledPixelSpacing = 1;
  int evenOffset = 8;
  int oddOffset = 12;
  
  float originX = width / 40;
  float originY = height * 3 / 4;
  
  
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI / 2;
  
  
  for(int ray = 0; ray < 19; ray++){
    
    originX += width / 20;
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle ;
    
    OPC rayOpc = new OPC(this, "192.168.10.3", 7890 + ray);
    
    rayOpc.ledRay(0,ledStripCount, originX, originY, rayOffset, ledPixelSpacing, rayAngle);
   
  }
}

void draw()
{
  background(0);

  fft.forward(in.mix);
  for (int i = 0; i < fftFilter.length; i++) {
    fftFilter[i] = max(fftFilter[i] * decay, log(1 + fft.getBand(i)));
  }
  
  for (int i = 0; i < fftFilter.length; i += 3) {   
    color rgb = colors.get(int(map(i, 0, fftFilter.length-1, 0, colors.width-1)), colors.height/2);
    tint(rgb, fftFilter[i] * opacity);
    blendMode(ADD);
 
    float size = height * (minSize + sizeScale * fftFilter[i]);
    PVector center = new PVector(width * (fftFilter[i] * 0.2), 0);
    center.rotate(millis() * spin + i * radiansPerBucket);
    center.add(new PVector(width * 0.5, height * 0.5));
 
    image(dot, center.x - size/2, center.y - size/2, size, size);
  }
}
