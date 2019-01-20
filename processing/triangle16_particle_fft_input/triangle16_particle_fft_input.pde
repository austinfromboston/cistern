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

  // Connect to the local instance of fcserver
  //opc = new OPC(this, "127.0.0.1", 7890);
  opc = new OPC(this, "192.168.1.70", 7890);

  makeArch(opc, 0.0, 0);
  makeArch(opc, 100.0, 444);
  makeArch(opc, 200.0, 888);

  //float startX = 100.0;

  //float startY = 100.0;
  //float ledWidth = 1.0;
  //float halfStrip = 74.0;
  //float fullStrip = 148.0;
    
  //opc.ledStrip(0, 148, (startX + 0.0), startY + (halfStrip * ledWidth), ledWidth, (PI * 1.5), false);
  //opc.ledStrip(148, 148, (startX + (halfStrip * ledWidth)), startY + (fullStrip * ledWidth), ledWidth, (PI), false);
  //opc.ledStrip(296, 148, (startX + (fullStrip * ledWidth)), startY + (halfStrip * ledWidth), ledWidth, (PI * 0.5), false);

  //float stripOffset = 100;
  //opc.ledStrip(296, 148, (startX + (fullStrip * ledWidth)), startY + (halfStrip * ledWidth), ledWidth, (PI * 0.5), false);

  //opc.ledStrip(444, 148, 0.0, 150.0, 1.0, (PI * 0.5), false);

  //opc.showLocations(true);

  // Map our triangle grid to the center of the window
  //triangle = new TriangleGrid();
  //triangle.grid16();
  //triangle.mirror();
  //triangle.rotate(radians(60));
  //triangle.scale(height * 0.2);
  //triangle.translate(width * 0.5, height * 0.5);
  //triangle.leds(opc, 0);
}

void makeArch(OPC opc, float offset, int startLed) {
  float startX = 100.0 + offset;
  float startY = 200.0;
  float ledWidth = 1.0;
  float halfStrip = 74.0;
  float fullStrip = 148.0;
    
  opc.ledStrip(startLed + 0, 148, (startX + 0.0), startY + (halfStrip * ledWidth), ledWidth, (PI * 1.5), false);
  opc.ledStrip(startLed + 148, 148, (startX + (halfStrip * ledWidth)), startY + (fullStrip * ledWidth), ledWidth, (PI), false);
  opc.ledStrip(startLed + 296, 148, (startX + (fullStrip * ledWidth)), startY + (halfStrip * ledWidth), ledWidth, (PI * 0.5), false);

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
    //center.rotate(millis() * spin + i * radiansPerBucket);
    center.add(new PVector(width * 0.5, height * 0.5));
 
    image(dot, center.x - size/2, center.y - size/2, size, size);
  }
}
