import themidibus.*;


OPC opc;
ArtnetPixels artnetPix;
CircularOscilloscope circleScope;
BackgroundScroll backgroundScroll;
//StarField starField;
GeoBubbles geoBubbles;
WarpDrive warpDrive; 
SoundBlock soundBlock;
SoundWave soundWave;
//Eyelid eyelid;
CircleWaltz circleWaltz;

MidiStatus midiStatus;
PImage splash;
Minim minim;
AudioInput in;

//AudioOutput out;
//FFT fft;
//float[] fftFilter;
//float[] fftFilterLast;

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
  
  int lastPattern;
  boolean allowProxy;
  
Drawable[] selectablePatterns;
HashMap<String, Drawable> allowedEffects;

void setup()
{
  size(1100, 900, P3D);

  //String ip = "localhost";
  String ip = "192.168.10.20";  
  minim = new Minim(this);
  in = minim.getLineIn();

  //fft = new FFT(in.bufferSize(), in.sampleRate());
  //fftFilter = new float[fft.specSize()];

  midiStatus = new MidiStatus(this);
  layout = new LayoutLoader();
  layout.loadList("data/awesome_fan_2019_onsite.json");

  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);

  // effects
  backgroundScroll = new BackgroundScroll(this, in, beat, midiStatus);
  circleScope = new CircularOscilloscope(this, beat, in, midiStatus, evenOffset, int(evenOffset + ledPixelSpacing * ledStripCount * 1.8));
  //starField = new StarField(this, midiStatus);
  soundWave = new SoundWave(this, midiStatus);
  soundWave.setup();
  warpDrive = new WarpDrive(this, midiStatus);


  // patterns
  geoBubbles = new GeoBubbles(this, midiStatus);
  soundBlock = new SoundBlock(this, midiStatus);
  circleWaltz = new CircleWaltz(this, midiStatus);

  allowedEffects = new HashMap<String, Drawable>();
  allowedEffects.put("scope", circleScope);
  allowedEffects.put("scroll", backgroundScroll);
  allowedEffects.put("wave", soundWave);
  allowedEffects.put("stars", warpDrive);
  
  selectablePatterns = new Drawable[]{ geoBubbles, circleWaltz, soundBlock };


  float proxyOriginX = width /2;
  float proxyOriginY = 3 * height / 4;
  //layout = layout.flip(0,0,0).multiplied(115).o  ffset(proxyOriginX, 0, proxyOriginY);
  layout = layout.flip(0,0,0).flipX(0).multiplied(115).offset(proxyOriginX, 0, proxyOriginY);

  //eyelid = new Eyelid(this, midiStatus);
  opcIn = new OPCListener(8890, layout.points.size());
  opcDisplay = new ProxyDisplay(this, opcIn, midiStatus, layout);
  
  //opcLayout(layout, 37, 120, ip);
  artnetLayout(layout, 38, 120, ip);
  artnetLayout(layout, 38, 120, "192.168.10.3");
}


void opcLayout(LayoutLoader layout, int ledStripCount, int ledsPerStrip, String ip) {

    for(int ray = 0; ray < ledStripCount; ray++){
      OPC rayOpc = new OPC(this, ip, 7890 + ray, false);
      
      rayOpc.ledRayLayout(0, ray, layout,ledsPerStrip);
      
    }
}


void artnetLayout(LayoutLoader layout, int ledStripCount, int ledsPerStrip, String ip) {
    int universes = ledStripCount;

    ArtnetPixels artnetPix = new ArtnetPixels(this, ip, false, universes, ledsPerStrip);
    artnetPix.pixelLayout(layout);
}

  
void draw()
{
  midiStatus.checkGamepad();
  int selectedPattern = round(map(midiStatus.dialSettings[PATTERN_SELECTOR_DIAL], 0, 127, 0, selectablePatterns.length-1));
  for(int i = 0; i< selectablePatterns.length; i++) {
    selectablePatterns[i].setDrawing(i == selectedPattern);
  }
  // display active effects
  for(String key : allowedEffects.keySet()){
    allowedEffects.get(key).setDrawing(midiStatus.activeEffects.contains(key));
  }

  this.allowProxy = selectablePatterns[selectedPattern].allowProxy();
  if(lastPattern != selectedPattern) {
    selectablePatterns[selectedPattern].setup();
    lastPattern = selectedPattern;
  }
  //System.gc();
  selectablePatterns[selectedPattern].addBackground();
}
