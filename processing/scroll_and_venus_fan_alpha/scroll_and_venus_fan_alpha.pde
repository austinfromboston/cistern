// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;

OPC opc;
PImage scroll;
PImage splash;
PImage venus;
PImage cells;
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

float low = 0;
float mid = 0;
float high = 0;


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
  venus = loadImage("blue_venus.jpg");
  cells = loadImage("Wire_orange_red_stripe.svg.png");

  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  opcFanBoy();
}


void opcFanBoy() {
  
  int ledStripCount = 120;
  int ledPixelSpacing = 2;
  int evenOffset = 8;//17;
  int oddOffset = 12;//24;
  
  float originX = width / 2;
  float originY = 3 * height / 4;
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI/20;
  
  for(int ray = 0; ray < 19; ray++){
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle + ray * PI / 20 ;
    
    OPC rayOpc = new OPC(this, "192.168.10.4", 7890 + ray, true);
    
    rayOpc.ledRay(0,ledStripCount, originX, originY, rayOffset, ledPixelSpacing, rayAngle);
   
  }
}

void opcFenceBoy() {
  
  int ledStripCount = 120;
  int ledPixelSpacing = 2;
  int evenOffset = 8;//17;
  int oddOffset = 12;//24;
  
  float originX = width / 2;
  float originY = 3 * height / 4;
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI/20;
  
  for(int ray = 0; ray < 19; ray++){
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle + ray * PI / 20 ;
    
    OPC rayOpc = new OPC(this, "192.168.10.3", 7890 + ray, true);
    
    rayOpc.ledRay(0,ledStripCount, originX, originY, rayOffset, ledPixelSpacing, rayAngle);
   
  }
}

void draw()
{
  background(0);
  beat.detect(in.mix);


   
    low = beat.isKick() ? .6 : max(0,low * 0.85);
    mid = beat.isSnare() ? .4 : max(.1,mid * 0.96);
    high = beat.isHat() ? .3 : max(0,high * 0.85);;
    
    //float size = height * (minSize + sizeScale * fftAvg);
    
    //if(beat.isKick()){  
    //  size = max(250,size*0.95);
    //}else if(beat.isSnare()){  
    //  size = max(400,size*0.95);
    //}else if(beat.isHat()){  
    //  size = 550;
    //}else {
    //  size = max(100, size * 0.95);
    //}
    int venusAlpha = (int) map(low, 0, 1, 0 ,255);
    
    int scrollAlpha = (int) map(mid, 0, 1, 0 ,255);
    
    int marsAlpha = (int) map(high, 0, 1, 0 ,255);
    
    blendMode(ADD);
    
    tint(255, 255, 255, venusAlpha); 
    image(venus, width / 6, height / 4 , 160, 160);
    
    blendMode(ADD);
    tint(256, 256, 256, marsAlpha); 
    image(cells, 3 * width /6 , height / 3 , 200, 80);
    
    blendMode(ADD);
    tint(255, scrollAlpha);
    image(scroll, foo, 0, width, height);
    image(scroll, foo - width, 0, width, height);
    foo = (millis() % 70000)/70 % width; 
    
 // }
}
