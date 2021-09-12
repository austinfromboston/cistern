
public class Koosh extends Drawable {
  AudioIn mic;
  Amplitude amp;
  ArrayList<Line> boxArray;
  final int STRING_COUNT=800;
  
  public Koosh(PApplet parent, MidiStatus midi) {
    super(parent, midi);
    this.mic = new processing.sound.AudioIn(parent, 0);
    mic.start();
    this.amp = new Amplitude(parent);
    amp.input(mic);
    this.boxArray = new ArrayList<Line>();
  
    for(int x = 0; x < STRING_COUNT; x++){
      boxArray.add(new Line(this, amp));
    }
  }
  
  //public addBackground() {
  //}



  void draw(){
   //background(0,0,0, 20);
    if (!drawing) return;
    push();
    dialOrigins(1);
    blendMode(LIGHTEST);
    for(int x = 0; x < boxArray.size(); x++){
      boxArray.get(x).show();
      boxArray.get(x).move();
      boxArray.get(x).checkEdge();
    } //for
    float offsetAdj = map(this.midi.dialSettings[APERTURE_DIAL], 0, 127, 0, 400);

    //float volume = amp.analyze();
    //float W = map(volume, 0, 1, 2, 40);
    blendMode(BLEND);
    //noStroke();
    colorMode(RGB);
    stroke(0, 0, 0, 5);
    for(int i = 0; i < offsetAdj; i++) {
      strokeWeight(i+1);
      //fill(0, 0, 0, 255);
      ellipse(originX, originY, i, i);

    }

    pop();
  } //draw
}

class Line {
  float centerY;
  float centerX;
  float startX;
  float startY;

  float X;
  float Y;
  float Xstep;
  float Ystep;
  //color col;
  float r;
  float b;
  float g;
  Amplitude amp;
  Drawable parent;
  
  public Line(Drawable parent, Amplitude amp){
    this.X = random(10, width - 10);
    this.Y = random(10, height - 10);
    this.Xstep = random(-4,4);
    this.Ystep = random(-4,4);
    this.amp = amp;
    this.parent = parent;
    
    this.r = random(255);
    this.b = random(255);
    this.g = random(255);
  } //constuctor

  public void show(){
    this.centerY = parent.originY;
    this.centerX = parent.originX;
    noStroke();
    colorMode(RGB);
    color pColor = color(this.r, this.g, this.b, parent.alphaAdj());
    colorMode(HSB);
    pColor = color(hue(pColor) + parent.hueAdj(), saturation(pColor), brightness(pColor), parent.alphaAdj());
    stroke(pColor);
    float volume = amp.analyze();
    float W = map(volume, 0, 1, 2, 40);
    strokeWeight(W);
    fill(pColor);
    line(this.X, this.Y, this.centerX, this.centerY);
  } //show
  
  public void move(){
    this.X = this.X + this.Xstep * map(parent.midi.speedDial, MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, 0.1, 5);
    this.Y = this.Y + this.Ystep* map(parent.midi.speedDial, MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, 0.1, 5);
  } //move
  
  public void checkEdge(){
      if(this.X < 10 | this.X > width - 10){
      this.Xstep = -1 * this.Xstep;
      } //Xif
      if(this.Y < 10 | this.Y > height - 10){
      this.Ystep = -1 * this.Ystep;
      } //Yif
  } //checkEdge
}
