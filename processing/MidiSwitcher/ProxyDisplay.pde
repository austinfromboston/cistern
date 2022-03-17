import processing.core.PApplet;

public class ProxyDisplay {
  PApplet parent;
  PImage scroll;
  BeatDetect beat;
  MidiStatus midi;
  float mid;
  int scrollSeam;
  OPCListener opcIn;
  int smallPoint;
  LayoutLoader layout;
 
  
  public ProxyDisplay(PApplet parent, OPCListener opcIn, MidiStatus midi, LayoutLoader layout) {
    this.parent = parent;
      this.parent.registerMethod("draw", this);

    this.midi = midi;
    this.opcIn = opcIn;
    this.layout = layout;
    this.smallPoint = 4;
  }
  
  void draw() {
    if(!allowProxy) {
      return;
    }
    blendMode(LIGHTEST);
    //tint(255, 255);
    noStroke();
    //background(0);
    float proxyAlpha = map(this.midi.gainDial, 0, 127, 0, 255);
    if(this.midi.padEffectActive) {
      proxyAlpha = map(this.midi.padEffectLevel, 0, 127, 150, 255);
    }
    for(int i=0; i < layout.points.size(); i++) {
      if(opcIn.opcColors != null) {
        int r = opcIn.opcColors[i * 3];
        int g = opcIn.opcColors[i * 3 + 1];
        int b = opcIn.opcColors[i * 3 + 2];
        if (i % 1000 == 0) {
          //println("color is", r, g,b );
        }
        fill(color(r, g, b), proxyAlpha);
      } else {
        fill(#AA33FF, 200);
      }
      Coordinate mappedPoint = layout.points.get(i); //.flip(0,0,0).multiplied(30).offset(300, 200, 500);
      //println(String.format("showing x %f z %f", mappedPoint.x, mappedPoint.z));
      ellipse((int) mappedPoint.x, (int) mappedPoint.z, smallPoint, smallPoint);
    }
    blendMode(EXCLUSION); 
  }
}
