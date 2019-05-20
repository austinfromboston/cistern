public class PerlinNoise extends Drawable {

int nums = 500;
Particle[] particles_a;
Particle[] particles_b;
Particle[] particles_c;

PApplet parent;

public PerlinNoise(PApplet parent, MidiStatus midi) {
  super(midi);  
  this.parent = parent;
    this.parent.registerMethod("draw", this);
}
void setup(){
  background(21, 8, 50);
  particles_a = new Particle[nums];
  particles_b = new Particle[nums];
  particles_c = new Particle[nums];
  for(int i = 0; i < nums; i++){
    particles_a[i] = new Particle(random(0, width),random(0,height));
    particles_b[i] = new Particle(random(0, width),random(0,height));
    particles_c[i] = new Particle(random(0, width),random(0,height));
  }
}

void draw(){
  if(drawing) {
    noStroke();
    smooth();
    int drawSpeed = round(map(midi.speedDial, 0, 127, 0, 5));
    for(int multiDraw = 0; multiDraw <= drawSpeed; multiDraw++) {
      for(int i = 0; i < nums; i++){
        float radius = map(i,0,nums,1,2);
        float alpha = map(i,0,nums,0,250);
    
        fill(69,33,124,alphaAdj(alpha));
        particles_a[i].move();
        particles_a[i].display(radius);
        particles_a[i].checkEdge();
    
        fill(7,153,242,alphaAdj(alpha));
        particles_b[i].move();
        particles_b[i].display(radius);
        particles_b[i].checkEdge();
    
        fill(255,255,255,alphaAdj(alpha));
        particles_c[i].move();
        particles_c[i].display(radius);
        particles_c[i].checkEdge();
      }  
    }
  }
}

  
  public void addBackground() {
    // this pattern depends on prior frames being preserved
    //background(0);
  }

}

class Particle {
  PVector dir;
  PVector vel;
  PVector pos;
  float speed;
  int noiseScale = 800;
  
  public Particle(float x, float y){
    this.dir = new PVector(0, 0);
    this.vel = new PVector(0, 0);
    this.pos = new PVector(x, y);
    this.speed = 0.4;
  } 
  public void move(){
    float angle = noise(this.pos.x/noiseScale, this.pos.y/noiseScale)*TWO_PI*noiseScale;
    this.dir.x = cos(angle);
    this.dir.y = sin(angle);
    this.vel = this.dir.copy();
    this.vel.mult(this.speed);
    this.pos.add(this.vel);
  }

  public void checkEdge(){
    if(this.pos.x > width || this.pos.x < 0 || this.pos.y > height || this.pos.y < 0){
      this.pos.x = random(50, width);
      this.pos.y = random(50, height);
    }
  }

  public void display(float r){
    ellipse(this.pos.x, this.pos.y, r, r);
  }
}
