import processing.core.PApplet;

public class StarField {
  PApplet parent;
  MidiStatus midi;
  boolean drawing;
  Star[] stars = new Star[100];


  public StarField(
    PApplet parent,
    MidiStatus midi
  ) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.midi = midi;


    this.drawing = true;

    for(int i = 0; i < stars.length; i++ ){
      stars[i] = new Star();
    }

  }


  void draw() {
    if(drawing) {

      for(int i = 0; i < stars.length; i++ ){
        stars[i] = new Star();
      }



    }
  }
}

public class Star {
 float x;
 float y;
 float z;

 public Star(){

 }
}
