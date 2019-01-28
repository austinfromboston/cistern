import themidibus.*;
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;

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
MidiRequests midiRequests;
//AudioOutput out;
FFT fft;
float[] fftFilter;
float[] fftFilterLast;

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

BeatDetect beat;

float heightScale;

int scrollSeam = 0;

float size = 100;

 int ledStripCount = 120;
  int ledPixelSpacing = 2;
  int evenOffset = 8;
  int oddOffset = 12;

MidiBus myBus; // The MidiBus

void setup()
{
  size(500, 500, P3D);

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();
  
  int midiDevice = 0;
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, midiDevice, 1); // Create a new MidiBus object
  midiRequests = new MidiRequests();

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  //scroll = loadImage("rainbow5.jpeg");
  scroll = loadImage("steamrainbow.jpg");
  //splash = loadImage("steamrainbow.jpg");
  venus = loadImage("blue_venus.jpg");
  cells = loadImage("Wire_orange_red_stripe.svg.png");
  
  horizontal = false;

  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  String ip = "192.168.10.4";
  //opcFenceBoy(evenOffset, oddOffset, ledStripCount, ledPixelSpacing, ip);
  opcFanBoy(evenOffset, oddOffset, ledStripCount, ledPixelSpacing, ip);
  
 
}

//void midiMessage(javax.sound.midi.MidiMessage message, long timeStamp, String bus_name) {
//  int note = (int)(message.getMessage()[1] & 0xFF) ;
//  int vel = (int)(message.getMessage()[2] & 0xFF);

//  println("Bus " + bus_name + ": Note "+ note + ", vel " + vel);
//  //if (vel > 0 ) {
//  // currentColor = vel*2;
//  //}
//}

public void controllerChange(int channel, int number, int value) {
    midiRequests.controllerChange(channel, number, value);
}

public void noteOff(int channel, int pitch, int velocity) {
    midiRequests.noteOff(channel, pitch, velocity);
}

public void noteOn(int channel, int pitch, int velocity) {
    midiRequests.noteOn(channel, pitch, velocity);
}

void opcFanBoy(float evenOffset, float oddOffset, int ledStripCount, int ledPixelSpacing, String ip) {
 
  
  float originX = width / 2;
  float originY = 3 * height / 4;
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI/20;
  
  for(int ray = 0; ray < 19; ray++){
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle + ray * PI / 20 ;
    
    OPC rayOpc = new OPC(this, ip, 7890 + ray, true);
    
    rayOpc.ledRay(0,ledStripCount, originX, originY, rayOffset, ledPixelSpacing, rayAngle);
   
  }
}

void opcFenceBoy(float evenOffset, float oddOffset, int ledStripCount, int ledPixelSpacing, String ip) {
   

  
  float originX = width / 40;
  float originY = height / 1.5;
  
  
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI / 2;
  
  
  for(int ray = 0; ray < 19; ray++){
    
    originX += width / 20;
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle ;
    
    OPC rayOpc = new OPC(this, ip, 7890 + ray, true);
    
    rayOpc.ledRay(0,ledStripCount, originX, originY, rayOffset, ledPixelSpacing, rayAngle);
   
  }
}

void draw()
{
  background(0);
  beat.detect(in.mix);
  
    if (beat.isKick()){
      lowCount = (lowCount + .5) % 64;
    }
   
    low1 = midiRequests.sparklePadActive ? map(midiRequests.sparklePadLevel, 0, 127, 0.6, 1) : max(0, low1 * 0.92);
    low2 = midiRequests.sparklePadActive ? map(midiRequests.sparklePadLevel, 0, 127, 0.6, 1) : max(0, low2 * 0.9);
    low3 = beat.isKick() &&  lowCount > 32  ? .66 : max(0, low3 * 0.87);
    low4 = beat.isKick() && lowCount  > 48  ? .7 : max(0, low4 * 0.85);
    
    mid = beat.isSnare() ? .3 : max(.1,mid * 0.96);
    high = beat.isHat() ? .3 : max(0,high * 0.85);;
    

    int venus1Alpha = (int) map(low1, 0, 1, 0 ,255);
    int venus2Alpha = (int) map(low2, 0, 1, 0 ,255);
    int venus3Alpha = (int) map(low3, 0, 1, 0 ,255);
    int venus4Alpha = (int) map(low4, 0, 1, 0 ,255);
    
    int scrollAlpha = (int) map(mid, 0, 1, 0 ,255);
    
    int batteryAlpha = (int) map(high, 0, 1, 0 ,255);
    
    if (midiRequests.sparklePadActive) {
     blendMode(ADD);
   
     tint(64, 255, 255, venus1Alpha); 
     image(venus, 110, 150 , 100, 100);
      
     tint(96, 132, 196, venus2Alpha); 
     image(venus, 80, 200 , 80, 80);
    }
  /*      
     tint(132, 96, 148, venus3Alpha); 
     image(venus, 50, 250 , 80, 80);
     
     tint(255, 64, 132, venus4Alpha); 
     image(venus, 20, 300 , 80, 80);
   */
    /*
    blendMode(ADD);
    tint(256, 256, 256, batteryAlpha); 
    image(cells, 3 * width /6 , height / 3 , 200, 80);
    */
    blendMode(ADD);
    tint(255, scrollAlpha);
    image(scroll, scrollSeam, 0, width, height);
    image(scroll, scrollSeam - width, 0, width, height);
    int scrollSpeed = Math.round(100-map(midiRequests.speedDial, midiRequests.DIAL_MIN, midiRequests.DIAL_MAX, 0, 80)); 
    scrollSeam = (millis() % 70000)/scrollSpeed % width;  

    
  strokeWeight(6);
  strokeJoin(ROUND);
  if(midiRequests.hueDial > 96) {
    stroke (128,5,128, 64);
  }else if(midiRequests.hueDial > 64) {
    stroke (255,128,5, 64);
  }else if(midiRequests.hueDial > 32){
    stroke (255,5,128, 64);
  }else {
    stroke (5,128,255, 64);
  }
  
  int bufferSize = in.bufferSize() -1 ;
  for(int i = 0; i < bufferSize; i++)
  { 
      float originX = width / 2;
      float originY = 3 * height / 4;
      float r = map(scrollSeam, 0, width, evenOffset, evenOffset + ledStripCount * ledPixelSpacing);
      
      int amplitude = 200;
      float sample = r + in.mix.get(i) * amplitude;
      float samplePrime = r + in.mix.get(i+1) * amplitude;
      float angle =  PI * i / bufferSize;
      float anglePrime =  PI * (i + 1) / bufferSize;
      
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
