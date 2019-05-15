// Some real-time FFT! This visualizes music in the frequency domain using a
// polar-coordinate particle system. Particle size and radial distance are modulated
// using a filtered FFT. Color is sampled from an image.

import ddf.minim.analysis.*;
import ddf.minim.*;
//import themidibus.*;
  
import processing.video.*;
Movie myMovie;

OPC opc;
VenusPattern venusPattern;
BackgroundScroll backgroundScroll;
MidiStatus midiStatus;
PImage splash;
Minim minim;
AudioInput in;
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

void setup()
{
  size(500, 500, P3D);

  minim = new Minim(this); 

  // Small buffer size!
  in = minim.getLineIn();

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  midiStatus = new MidiStatus(this);

  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  venusPattern = new VenusPattern(this, beat, midiStatus);
  //backgroundScroll = new BackgroundScroll(this, beat, midiStatus);  

  myMovie = new Movie(this, "ferris_bueller.mp4");
  myMovie.play();
  
  String ip = "192.168.10.4";
  opcFanBoy(evenOffset, oddOffset, ledStripCount, ledPixelSpacing, ip);
}


void opcFanBoy(float evenOffset, float oddOffset, int ledStripCount, int ledPixelSpacing, String ip) {
 
  
  float originX = width / 2;
  float originY = 3 * height / 4;
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI/20;
  
  for(int ray = 0; ray < 19; ray++){
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle + ray * PI / 20 ;
    
    OPC rayOpc = new OPC(this, ip, 7890 + ray, false, midiStatus);
    
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
    
    OPC rayOpc = new OPC(this, ip, 7890 + ray, true, midiStatus);
    
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
   
    mid = beat.isSnare() ? .3 : max(.1,mid * 0.96);
    high = beat.isHat() ? .3 : max(0,high * 0.85);;
    

    
  strokeWeight(6);
  strokeJoin(ROUND);
  if(lowCount > 48) {
    stroke (128,5,128, 64);
  }else if(lowCount > 32) {
    stroke (255,128,5, 64);
  }else if(lowCount > 16){
    stroke (255,5,128, 64);
  }else {
    stroke (5,128,255, 64);
  }
  
  int bufferSize = in.bufferSize() - 1;
  for(int i = 0; i < bufferSize; i++)
  { 
      float originX = width / 2;
      float originY = 3 * height / 4;
      float r = evenOffset + ledStripCount * ledPixelSpacing;
      
      int amplitude = 50;
      float sample = r + in.mix.get(i) * amplitude;
      float samplePrime = r + in.mix.get(i+1) * amplitude;
      float angle =  PI * i / bufferSize;
      float anglePrime =  PI * (i + 1) / bufferSize;
      
      blendMode(ADD);
      
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
      blendMode(ADD);
          tint(255, 128); 
          pushMatrix();
          scale(1.0, -1.0);
          image(myMovie, 0, -100, 500, -280); 
          popMatrix();


}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}


void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      myMovie.jump(myMovie.time() + 300);
    }
  } 
}
