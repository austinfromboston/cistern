import processing.core.PApplet;

public class StarField {
  PApplet parent;
  MidiStatus midi;
  boolean drawing;
  Star[] stars = new Star[1400];
  float originX;
  float originY;


  public StarField(
    PApplet parent,
    MidiStatus midi,
    float originX,
    float originY
  ) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.midi = midi;
    this.originX = originX;
    this.originY = originY;

    this.drawing = true;

    for(int i = 0; i < stars.length; i++ ){
      stars[i] = new Star();
    }

  }


  void draw() {
    
    if(drawing) {
      background(0);
      
      translate(originX, originY);
      
      float speed = (midi != null) ? midi.speedDial : 22;
      
      int numStars = (int) map(speed, 0, 127, stars.length / 3 , stars.length);
      
      for(int i = 0; i < numStars; i++ ){
        stars[i].move(speed);
        stars[i].draw();
      }


      translate(-originX, -originY);

    }
  }
}

public class Star {
 float x;
 float y;
 float z;
 float zPrime;
 
 color[] redShift = {
   color(75, 0, 130),
   color(0, 0, 255),
   color(0, 255, 0),
   color(255),
   color(255),
   color(255),
   color(255),
   color(255, 255, 0),
   color(255, 127, 0),
   color(255, 0 , 0)
 };
 

 public Star() {
   resetInSpace();
 }
 
 public void resetInSpace() {
   x = random(-width,width) / 2;
   y = random(-height,height) / 2;
   z = random(width) ;
   zPrime = z;
 }
 
 public void move(float speed) {
   float psi = map(speed,0,128,1, zPrime/4);
   zPrime = zPrime - psi;
   if (zPrime <= 1) resetInSpace();
 } 
 
 public void draw() {
   
   fill(255);
   noStroke();
   
   float sx = map(x / zPrime , 0, 1, 0, width/2);
   float sy = map(y / zPrime , 0, 1, 0, height/2);
   
   float radius = map(zPrime , 0, width, 4, 0);
   
   
   float px = map(x / z, 0, 1, 0, width/2);
   float py = map(y / z, 0, 1, 0, height/2);

   z = zPrime;
   
   //stroke(255);
   //ellipse(sx, sy, radius/8, radius/8);
   strokeWeight(radius*1);
   //line(px,py,sx,sy);

   redShiftLine(px, py, sx, sy);
   
 }
 
 void redShiftLine(float x1, float y1, float x2, float y2) {
  float deltaX = x2-x1;
  float deltaY = y2-y1;
  
  float lenSqared = deltaX * deltaX + deltaY * deltaY;
  
  if (lenSqared > 100){
    float sliceX = deltaX /10;
    float sliceY = deltaY /10;
    for (int t = 0; t < 10; t ++) {
      stroke(redShift[t]);
      line(x1+t*sliceX,  y1+t*sliceY, x1+(t + 1)*sliceX,  y1+(t + 1)*sliceY);
    }
  } else {
    stroke(255);
    line(x1,y1,x2,y2);
  }
    
}
}
