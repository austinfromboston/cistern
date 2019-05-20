public class WarpDrive {

  PApplet parent;
  MidiStatus midi;
  float originX;
  float originY;


int n = 500; //number of warp stars
float[] angle = new float[n];  //their angle versus the center of the screen
float[] dist = new float[n];   //distance from center of the screen
float[] speed = new float[n];  //speed leaving the center
float[] bright = new float[n]; //brightness (start black, fade to white)
float[] thick = new float[n];  //diameter of the warp star




public WarpDrive(
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



  for(int i = 0; i < n; i++) { //create warp stars
    restartStar(i);
    dist[i] = random(0,width+height);
  }
}


int randSeed = 0;

void draw() {
  randSeed += frameCount;
  randomSeed(randSeed % 120); //Make a predictable pattern (useful for making the effect consistent)

  //Fade the tails drawn by the stars to black:
  colorMode(RGB);
  fill(0,50);
  noStroke();
  rect(0,0,width,height);

  //Draw the warp stars:
  for(int i = 0; i < n; i++) {
    pushMatrix();
    translate(width/2,height/2);
    rotate(angle[i]);
    translate(dist[i],0);
    stroke(starcolor(bright[i]));
    strokeWeight(thick[i]);
    line(0,0,speed[i],0); //draw line from previous to next position
    popMatrix();

    dist[i] += speed[i]; //Move the warp stars
    speed[i] += .1*warp(); //accelerate as they leave center
    if(dist[i] > width + height) restartStar(i); //restart stars out of screen
    bright[i] += 5;
  }

  //Draw 'static' non-moving stars (when stationary)
  randomSeed(0);
  colorMode(RGB);
  for(int i = 0; i < 400; i++) {
    fill(map(warp(),0,2,200,0)); //make visible only when warp is between 0 and 2
    if(warp() > 2) fill(0);
    noStroke();
    float diameter = random(1,5); //draw random size static stars
    ellipse(random(0,width),random(0,height),diameter,diameter);
  }

  //Draw the text of warp speed at top left
  fill(255);
  textSize(30);
  textAlign(LEFT,TOP);
  text("WARP "+round(warp()*10)/10.0,40,40);
}

void restartStar(int i) {
  //Restart code for when star leaves screen and comes back
  angle[i] = random(0,2*PI*100);
  dist[i] = random(width/50,width);
  speed[i] = random(0*warp(),.1*warp());
  thick[i] = random(1,5);
  bright[i] = 0;
}

//Makes stars blue when faster
color starcolor(float bright) {
  colorMode(HSB);
  float sat = map(warp(),1,10,0,100);
  return color(150,sat,bright);
}

float warp() { //returns a number from 0 to 10, increasing and decreasing over time
  return map(cos(PI + frameCount / 60.0 / 5),-1,1,0,10);
}

}
