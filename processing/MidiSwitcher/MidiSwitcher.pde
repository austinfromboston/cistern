import ddf.minim.analysis.*;
import ddf.minim.*;
import themidibus.*;


OPC opc;
CircularOscilloscope circleScope;
BackgroundScroll backgroundScroll;
StarField starField;

MidiStatus midiStatus;
PImage splash;
Minim minim;
AudioInput in;
//AudioOutput out;
FFT fft;
float[] fftFilter;
float[] fftFilterLast;

LayoutLoader layout;
OPCListener opcIn;
ProxyDisplay opcDisplay;

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
  size(1000, 700, P3D);

  String ip = "127.0.0.1";
  float originX = width / 2;
  float originY = 3 * height / 4;
  
  minim = new Minim(this);
  in = minim.getLineIn();

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fftFilter = new float[fft.specSize()];

  midiStatus = new MidiStatus(this);
  layout = new LayoutLoader();
  layout.loadList("data/space_potty_fan.json");

  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);

  backgroundScroll = new BackgroundScroll(this, beat, midiStatus);
  circleScope = new CircularOscilloscope(this, beat, in, midiStatus, evenOffset, evenOffset + ledPixelSpacing * ledStripCount);
  starField = new StarField(this, midiStatus, originX, originY);

  
  layout = layout.flip(0,0,0).multiplied(115).offset(originX, 0, originY);
  opcLayout(layout, 37, 120, ip);
  
  
  //opcFanBoy(evenOffset, oddOffset, ledStripCount, ledPixelSpacing, ip);
}


void opcFanBoy(float evenOffset, float oddOffset, int ledStripCount, int ledPixelSpacing, String ip) {
 
  
  float originX = width / 2;
  float originY = 3 * height / 4;
  
  //start pointing at -X + PI/40
  float zeroStripAngle = PI + PI/20;
  
  for(int ray = 0; ray < 19; ray++){
    
    float rayOffset = (ray % 2 == 0) ? evenOffset: oddOffset;
    float rayAngle = zeroStripAngle + ray * PI / 20 ;
    
    OPC rayOpc = new OPC(this, ip, 7890 + ray, false);
    
    rayOpc.ledRay(0,ledStripCount, originX, originY, rayOffset, ledPixelSpacing, rayAngle);
   
  }
}


void opcLayout(LayoutLoader layout, int ledStripCount, int ledsPerStrip, String ip) {

    for(int ray = 0; ray < ledStripCount; ray++){
      OPC rayOpc = new OPC(this, ip, 7890 + ray, false);
      
      rayOpc.ledRayLayout(0, ray, layout,ledsPerStrip);
      
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

}
