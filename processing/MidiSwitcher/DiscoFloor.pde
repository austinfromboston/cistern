public class DiscoFloor extends Drawable {
  AudioIn mic;
  Amplitude amp;
  
  public DiscoFloor(PApplet parent, MidiStatus midi) {
    super(parent, midi);
    this.mic = new processing.sound.AudioIn(parent, 0);
    mic.start();
    this.amp = new Amplitude(parent);
    amp.input(mic);
  }
  
  void draw() {
    //background(0);
    if (!drawing) return;
    push();
    float rms = amp.analyze();
    fill(31, 127, 255);
    noStroke();
    for (int j = 0; j < height; j = j + 100) {
      for (int i = 0; i < width; i = i + 100) {
        fill(rms * random(100, 1000), rms * random(100, 1000), rms * random(100, 1000), alphaAdj());
        noStroke();
        rect(i, j, rms * 500, rms * 500);
        fill(rms * random(100, 1000), rms * random(100, 1000), rms * random(100, 1000), alphaAdj(100));
        ellipse(i, j, rms * 300, rms * 300);
        fill(rms * random(100, 1000), rms * random(100, 1000), rms * random(100, 1000), alphaAdj(50));
      }
    }
    //background(255);
    fill(255);
    //strokeWeight(2);
    
    textSize(30);
    textAlign(LEFT,TOP);
    text("Music Required ",800,40);
    pop();
    //float speed = map(mouseX, 0.1, width, 0, 2);
    //speed = constrain(speed, 0.01, 4);
    //sound.rate(speed);
  }
}
