import processing.core.PApplet;

public class StarField {
  PApplet parent;
  MidiStatus midi;
  boolean drawing;




  public CircularOscilloscope(
    PApplet parent,
    MidiStatus midi
  ) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.midi = midi;


    this.drawing = true;
    this.fft = new FFT(in.bufferSize(), in.sampleRate());
    this.fft.logAverages(22, 1);
    this.fftFilter = new float[in.bufferSize()];

  }

  private float radiusGrowth() {
    return ((millis() % 100000)/2) / secondsPerRadiusRefresh % width;
  }

  void draw() {
    if(drawing) {

      beat.detect(in.mix);


      fft.forward(in.mix);
      fft.setBand(0, 20);
      fft.setBand(3, 20);
      fft.setBand(4, 20);

      for(int i = fft.specSize(); i<fft.specSize(); i--){
        fft.setBand(i, 0.75);
      }

      fft.inverse(fftFilter);

      if (beat.isKick()){
        lowCount = (lowCount + .5) % 64;
      }


      int oscillAlpha = 70; // (int) map(midi.opcDial, 65, 128, 40 , 70);

      blendMode(ADD);
      strokeWeight(6);
      strokeJoin(ROUND);

      if(lowCount > 48) {
        colorOne = purple;
        colorTwo = orange;
      } else if(lowCount > 32) {
        colorOne = orange;
        colorTwo = pink;
      } else if(lowCount > 16){
        colorOne = pink;
        colorTwo = teal;
      } else {
        colorOne = teal;
        colorTwo = purple;
      }

      int bufferSize = in.bufferSize() -1 ;
      for(int i = 0; i < bufferSize; i++){
        float originX = width / 2;
        float originY = 3 * height / 4;

        //int radiusMin = evenOffset;
        //int radiusMax = evenOffset + ledStripCount * ledPixelSpacing
        float growth = radiusGrowth();

        float r1 = map(
          growth,
          0,
          parent.width,
          minRadius,
          maxRadius
        );

        float r2 = map(
          (growth + parent.width / 2) % width,
          0,
          width,
          minRadius,
          maxRadius
        );

        int amplitude = 80;
        float sample = r1 + in.mix.get(i) * amplitude;
        float samplePrime = r1 + in.mix.get(i+1) * amplitude;
        float angle =  PI * i / bufferSize;
        float anglePrime =  PI * (i + 1) / bufferSize;

        stroke (colorOne, oscillAlpha);

        line(
          originX - cos(angle) * sample,
          originY - sin(angle) * sample,
          originX - cos(anglePrime) * samplePrime,
          originY - sin(angle) * samplePrime
        );

      stroke (colorTwo, oscillAlpha);

      sample = r2 + fftFilter[i] * amplitude;
      samplePrime = r2 + fftFilter[i + 1] * amplitude;

      line(
        originX - cos(angle) * sample,
        originY - sin(angle) * sample,
        originX - cos(anglePrime) * samplePrime,
        originY - sin(angle) * samplePrime
       );
    }



    }
  }
}
