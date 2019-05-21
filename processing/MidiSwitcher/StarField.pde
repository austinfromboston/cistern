import processing.core.PApplet;

public class StarField extends Drawable {
  PApplet parent;
  Star[] stars;


  public StarField(PApplet parent, MidiStatus midi) {
    super(parent, midi);
  }
  
  void setup() {
    colorMode(RGB, 255);

    stars = new Star[1400];
    for(int i = 0; i < stars.length; i++ ){
      stars[i] = new Star();
    }
  }


  void draw() {
    if(drawing) {
      //background(0);
      originX = map(this.midi.dialSettings[X_LOCATION_DIAL], 0, 127, 200, width - 200);
      originY = map(this.midi.dialSettings[Y_LOCATION_DIAL], 0, 127, height / 4, 5 * height / 4);
      translate(originX, originY);
      float alpha = alphaAdj();
      
      float speed = (midi != null) ? midi.speedDial - 64 : 22;
      
      int numStars = (int) map(speed, -64, 64, stars.length / 3 , stars.length);
      
      for(int i = 0; i < numStars; i++ ){
        stars[i].move(speed);
        stars[i].draw(alpha);
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
   float psi = map(speed,-64,64, - zPrime/4, zPrime/4);
   zPrime = zPrime - psi;
   if (zPrime <= 1) resetInSpace();
 } 
 
 public void draw(float alpha) {
   
   fill(255, alpha);
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
   if(radius <= 0) {
     resetInSpace();
   }

   redShiftLine(px, py, sx, sy, alpha);
   
 }
 
 public color adjustColor(color c, float alpha) {
    float red = red(c);
    float green = green(c);
    float blue = blue(c);
    //float newAlpha = map(alpha, 0, 255, 0, alpha(c));
    //return color(red, green, blue, newAlpha);
    return color(red, green, blue, round(alpha));
}
 
 void redShiftLine(float x1, float y1, float x2, float y2, float alpha) {
  float deltaX = x2-x1;
  float deltaY = y2-y1;
  
  float lenSqared = deltaX * deltaX + deltaY * deltaY;
  
  if (lenSqared > 100){
    float sliceX = deltaX /10;
    float sliceY = deltaY /10;
    for (int t = 0; t < 10; t ++) {
      stroke(redShift[t], alpha);
      line(x1+t*sliceX,  y1+t*sliceY, x1+(t + 1)*sliceX,  y1+(t + 1)*sliceY);
    }
  } else {
    stroke(color(255), alpha);
    line(x1,y1,x2,y2);
  }
    
}


}
