/*
built upon
"Wandering in Space" by R.M
http://www.openprocessing.org/sketch/492680
Licensed under Creative Commons Attribution ShareAlike
https://creativecommons.org/licenses/by-sa/3.0
https://creativecommons.org/licenses/G

*/

public class Colorwander extends Drawable {
  
  Particle[] p;;
  int diagonal;
  float rot = 0.002;
  float speed = 0.07;
  float rotation = 0;
  int color1 = 3000;
  boolean x = true;
  int speedSetting;

  
  public Colorwander(PApplet parent, MidiStatus midi) {
    super(parent, midi);
    p = new Particle[800];
    rot = 0.002;
    speed = 0.07;
    speedSetting = midi.dialSettings[SPEED_DIAL];
    rotation = 0;
    color1 = 3000;
    diagonal = (int)sqrt(width*width + height * height)/2;
  }
  
  void setup() {
    for (int i = 0; i<p.length; i++) {
      p[i] = new Particle();
      p[i].o = random(1, random(1, width/p[i].n));
    }
    //fullScreen();

    //background(0);
    frameRate(30);
  }


  void draw() {
    if(!this.drawing) { return; }
    pushMatrix();
    pushStyle();
    colorMode(HSB,color1,100,100,100);
    translate(width/2, height/2);
    rotation-=rot*sin(1);
    rotate(rotation);
    rot = map(this.midi.dialSettings[X_LOCATION_DIAL], 0, 127, -1.0, 1.0); 
    if (keyPressed) {
      if (keyCode == LEFT) {
        rot -= 0.001;
      }
      if (keyCode == RIGHT) {
        rot+= 0.001;
      }
      if (keyCode == ALT)
          {rot= 0;}
   
     if (keyCode == CONTROL)
     {x = !x;}
    }
    if (x == false)
    {noStroke();}
    if (x == true)
    {stroke(0);}
    float speedAdjustment = this.speed + map(this.midi.dialSettings[SPEED_DIAL] - this.speedSetting, -64, 64, 0.001, 0.2);
    for (int i = 0; i<p.length; i++) {
      p[i].draw(speedAdjustment);
      if (p[i].drawDist()>diagonal) {
        p[i] = new Particle();
      }
    }
    popMatrix();
    popStyle();
  }
  
  public void addBackground() {
  }
  
  public boolean allowProxy() {
    return false;
  }

  
    
  public void beginDraw() {
    background(0);
  }

  class Particle {
    float n;
    float r;
    float o;
    int l;
    float k;
    Particle() {
      k = 0;
      l = 1;
      n = random(1, width/2);
      r = random(0, TWO_PI);
      o = random(1, random(1, width/n));
    }
  
    void draw(float speedAdjustment) {
      
      if(k <= color1)
      {
      k++;
      }
      if(k == color1)
      {k = 0;}
      fill(0,2);
      l++;
      pushMatrix();
      rotate(r);
      translate(drawDist(), 0);
      fill(k, min(l, 255), 100);
      ellipse(0, 0, width/o/8, width/o/8);
      popMatrix();
      o-=speedAdjustment;//speed
          if (keyPressed) {
            if (keyCode == UP) {
            speed += 0.00001; 
            }      
            if (keyCode == DOWN) {
            speed-= 0.00001;
            }
            if (keyCode == SHIFT){
            speed =0; }
            
            }
    }
    float drawDist() {
      return atan(n/o)*width/HALF_PI;
    }
  }
}
