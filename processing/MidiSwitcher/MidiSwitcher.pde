import ddf.minim.analysis.*;
import ddf.minim.*;
import themidibus.*;


OPC opc;
CircularOscilloscope circleScope;
BackgroundScroll backgroundScroll;
StarField starField;
PerlinNoise perlinNoise;
LayerCurtain layerCurtain;

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
  
Drawable[] selectablePatterns;

void setup()
{
  size(1000, 700, P3D);

  String ip = "localhost";
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
  circleScope = new CircularOscilloscope(this, beat, in, midiStatus, evenOffset, int(evenOffset + ledPixelSpacing * ledStripCount * 1.8));
  starField = new StarField(this, midiStatus, originX, originY);
  perlinNoise = new PerlinNoise(this, midiStatus);
  perlinNoise.setup();
  selectablePatterns = new Drawable[]{ backgroundScroll, circleScope, starField, perlinNoise };
  layerCurtain = new LayerCurtain(this, midiStatus);
  
  layout = layout.flip(0,0,0).multiplied(115).offset(originX, 0, originY);

  opcIn = new OPCListener(8890, layout.points.size());
  opcDisplay = new ProxyDisplay(this, opcIn, midiStatus, layout);
  
  opcLayout(layout, 37, 120, ip);
}


void opcLayout(LayoutLoader layout, int ledStripCount, int ledsPerStrip, String ip) {

    for(int ray = 0; ray < ledStripCount; ray++){
      OPC rayOpc = new OPC(this, ip, 7890 + ray, false);
      
      rayOpc.ledRayLayout(0, ray, layout,ledsPerStrip);
      
    }
}


  
void draw()
{
  int selectedPattern = round(map(midiStatus.patternSelectionDial, 0, 127, 0, selectablePatterns.length-1));
  for(int i = 0; i< selectablePatterns.length; i++) {
    selectablePatterns[i].setDrawing(i == selectedPattern);
  }
  selectablePatterns[selectedPattern].addBackground();
}
