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
AudioOutput out;
FFT fft;
float[] fftFilter;
//float[] fftFilterLast;

float spin = 0.003;

float decay = 0.95;
float opacity = 80;
float minSize = 0.1;
float sizeScale = 4.5;
boolean horizontal;

float low1 = 0;
float low2 = 0;
float low3 = 0;
float low4 = 0;
float mid = 0;
float high = 0;
float lowCount = 0;

    color colorOne;
    color colorTwo;
    color purple = color(128,5,128);
    color orange = color(255,128,5);
    color pink = color(255,5,128);
    color teal = color(5,128,255);

BeatDetect beat;

float heightScale;

int scrollSeam = 0;

float size = 100;

 int ledStripCount = 240;
  int ledPixelSpacing = 2;
  int evenOffset = 8;
  int oddOffset = 12;
  
LayoutLoader layout;
int smallPoint;
OPCListener opcIn;
ProxyDisplay opcDisplay;

MidiStatus midiStatus;

void setup()
{
  size(1000, 700, P3D);

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();
  midiStatus = new MidiStatus(this);
  layout = new LayoutLoader();
  layout.loadList("data/space_potty_fan2.json");
  float originX = width / 2;
  float originY = 3 * height / 4;

  layout = layout.flip(0,0,0).multiplied(115).offset(originX, 0, originY);

  opcIn = new OPCListener(7890, layout.points.size());
  opcDisplay = new ProxyDisplay(this, opcIn, midiStatus, layout);

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(22, 1);
  fftFilter = new float[in.bufferSize()];

  //scroll = loadImage("rainbow5.jpeg");
  scroll = loadImage("steamrainbow.jpg");
  //splash = loadImage("steamrainbow.jpg");
  venus = loadImage("blue_venus.jpg");
  cells = loadImage("Wire_orange_red_stripe.svg.png");
  
  horizontal = false;

  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  String ip = "192.168.10.3";
  //opcFenceBoy(evenOffset, oddOffset, ledStripCount, ledPixelSpacing, ip);
  //opcFanBoy(evenOffset, oddOffset, ledStripCount, ledPixelSpacing, ip);
  opcLayout(layout, 19, 120, ip);
 
}

void opcLayout(LayoutLoader layout, int ledStripCount, int ledsPerStrip, String ip) {

    for(int ray = 0; ray < ledStripCount; ray++){
      OPC rayOpc = new OPC(this, ip, 7890 + ray, false);
      
      rayOpc.ledRayLayout(0, ray, layout,ledsPerStrip);
      
    }
}

void keyPressed() {
  if (keyCode == 32) {
    midiStatus.opcDial = (midiStatus.opcDial + 20) % 127;
    println("opc is now ", midiStatus.opcDial);
  }
}


void draw()
{
  background(0);
  beat.detect(in.mix);
  //midiStatus = new MidiStatus();
  
  fft.forward(in.mix);
  fft.setBand(0, 20);
  fft.setBand(3, 20);
  fft.setBand(4, 20);
  for(int i = fft.specSize(); i<fft.specSize(); i--){
    fft.setBand(i, 0.75);
  }
  fft.inverse(fftFilter);
  
    if (beat.isKick()){
      lowCount = (lowCount + .5) % 64;
    }
   
    //low1 = beat.isKick() && lowCount  > 0   ? .5 : max(0, low1 * 0.92);
    //low2 = beat.isKick() && lowCount  > 16  ? .6 : max(0, low2 * 0.9);
    //low3 = beat.isKick() &&  lowCount > 32  ? .66 : max(0, low3 * 0.87);
    //low4 = beat.isKick() && lowCount  > 48  ? .7 : max(0, low4 * 0.85);
    
    mid = beat.isSnare() ? .3 : max(.1,mid * 0.96);
    //high = beat.isHat() ? .3 : max(0,high * 0.85);;
    

    //int venus1Alpha = (int) map(low1, 0, 1, 0 ,255);
    //int venus2Alpha = (int) map(low2, 0, 1, 0 ,255);
    //int venus3Alpha = (int) map(low3, 0, 1, 0 ,255);
    //int venus4Alpha = (int) map(low4, 0, 1, 0 ,255);
    
    int oscillAlpha;
    if (midiStatus.opcDial > 65) {
      oscillAlpha = (int) map(midiStatus.opcDial, 65, 128, 40 , 70);
    } else {
      oscillAlpha = 0;
    }
    int scrollAlpha;
    if (midiStatus.opcDial > 96) {
      scrollAlpha = (int) map(mid, 0, 1, 0 ,midiStatus.opcDial + (255 - 96));
    } else {
      scrollAlpha = 0;
    }

    
    
    //int batteryAlpha = (int) map(high, 0, 1, 0 ,255);
    

    blendMode(ADD);
    tint(255, scrollAlpha);
    int numSecPerScroll = 25;
    image(scroll, scrollSeam, 0, width, height);
    image(scroll, scrollSeam - width, 0, width, height);
    scrollSeam = ((millis() % 100000)/2) / numSecPerScroll % width;  


    
  strokeWeight(6);
  strokeJoin(ROUND);
  if(lowCount > 48) {
    colorOne = purple;
    colorTwo = orange;
  }else if(lowCount > 32) {
    colorOne = orange;
    colorTwo = pink;
  }else if(lowCount > 16){
    colorOne = pink;
    colorTwo = teal;
  }else {
    colorOne = teal;
    colorTwo = purple;
  }
  
  int bufferSize = in.bufferSize() -1 ;
  for(int i = 0; i < bufferSize; i++)
  { 
      float originX = width / 2;
      float originY = 3 * height / 4;
      float r1 = map(scrollSeam, 0, width, evenOffset, evenOffset + ledStripCount * ledPixelSpacing);
      float r2 = map((scrollSeam + width / 2) % width , 0, width, evenOffset, evenOffset + ledStripCount * ledPixelSpacing);
      
      int amplitude = 80;
      float sample = r1 + in.mix.get(i) * amplitude;
      float samplePrime = r1 + in.mix.get(i+1) * amplitude;
      float angle =  PI * i / bufferSize;
      float anglePrime =  PI * (i + 1) / bufferSize;
      
      stroke (colorOne, oscillAlpha);
      
      line( 
        originX - cos(angle) * sample,
      //y1
        originY - sin(angle) * sample, 
      //x2
        originX - cos(anglePrime) * samplePrime , 
      //y2
         originY - sin(angle) * samplePrime 
       );
       
      stroke (colorTwo, oscillAlpha);
      
      sample = r2 + fftFilter[i] * amplitude;
      samplePrime = r2 + fftFilter[i + 1] * amplitude;  
      
      line( 
        originX - cos(angle) * sample,
      //y1
        originY - sin(angle) * sample, 
      //x2
        originX - cos(anglePrime) * samplePrime , 
      //y2
         originY - sin(angle) * samplePrime 
       );
  }
  
}
