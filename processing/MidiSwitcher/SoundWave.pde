public class SoundWave extends Drawable {
float cont = 300;
float cont1 = 299;

int type = 1;
AudioIn mic;
Amplitude amp;
float rand;
float rand2;
float rand3;
float rand4;
float rand5;
float rand6;
float randW;
float randS;
float micLevel;
float h;

public SoundWave(PApplet parent, MidiStatus midi) {
  super(parent, midi);
  this.mic = new processing.sound.AudioIn(parent, 0);
  mic.start();
  this.amp = new Amplitude(parent);
  amp.input(mic);
}


void mousePressed() {
  if(type == 0) {
    type = 1;
    rand = random(40)+5;
  } 
  else {
    type = 0;
    rand = random(40)+5;
  }
}

void draw() {
  if(!this.drawing) { return; }
  dialOrigins(1.2);
//------random clock-------
  if(cont > cont1){
    rand = random(60);
    rand2 = random(60);
    rand3 = random(60);
    rand4 = random(1000,500);
    rand5 = random(1000,500);
    rand6 = random(1000,500);
    randW = random(0.003, 0);
    randS = random(0.002, 0.05);
    cont = 0;
    cont1 = random(299, 599);
  }
  else{
    cont++;
  }
  push();
    //blendMode(BLEND);
    //background(0);
    blendMode(SCREEN);
    noFill();
    float speedFactor = map(this.midi.effectSpeed.get("wave"), MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, 0.5, 10);
    int clock = int(frameCount * speedFactor);
    float strokeAdj = alphaAdj(1); 
//-------red Line -------
    beginShape();
      stroke(color(255,0,0), alphaAdj());
    for(int w = -20; w < width + 20; w += 5){
      micLevel = amp.analyze();
      //println("wave seeing ", micLevel);
      strokeWeight((100*micLevel+5) * strokeAdj);
      h = ((rand4*micLevel)+50)*sin(w/(rand)) * pow(abs(sin(w * randW + clock * randS)), 5) + originX;
      //curveVertex(w,h);
      curveVertex(h,w);
    }
  endShape();
//----blue line---------
  beginShape();
      stroke(color(0,100,255), alphaAdj());
      for(int w = -20; w < width + 20; w += 5){
      micLevel = amp.analyze();
      strokeWeight((100*micLevel+5)* strokeAdj);
      h = (rand5*micLevel+50)*sin(w/(rand2)) * pow(abs(sin(w * randW + clock * randS)), 5) + originX;
      curveVertex(h,w);
    }
  endShape();
//-----green line-------
  beginShape();
      stroke(color(0,255,0), alphaAdj());
      for(int w = -20; w < width + 20; w += 5){
      micLevel = amp.analyze();
      //println(micLevel);
      strokeWeight((100*micLevel+5)* strokeAdj);
      h = (rand6*micLevel+50)*sin(w/(rand3)) * pow(abs(sin(w * randW + clock * randS)), 5) + originX;
      curveVertex(h,w);
    }
  endShape();
  pop();

}
}
