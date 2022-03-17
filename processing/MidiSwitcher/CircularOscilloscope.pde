import processing.core.PApplet;

public class CircularOscilloscope extends Drawable {
  BeatDetect beat;
  AudioInput audioIn;
  ddf.minim.analysis.FFT fft;
  float[] fftFilter;

  int maxSecondsPerRadiusRefresh = 25;
  int minRadius;
  int maxRadius;

  color colorOne;
  color colorTwo;
  color colorThree;
  color purple = color(128,5,128);
  color orange = color(255,128,5);
  color pink = color(255,5,128);
  color teal = color(5,128,255);


  public CircularOscilloscope(
    PApplet parent,
    BeatDetect beat,
    AudioInput audioIn,
    MidiStatus midi,
    int minRadius,
    int maxRadius
  ) {
    super(parent, midi);
    this.beat = beat;
    this.audioIn = audioIn;
    this.minRadius = minRadius;
    this.maxRadius = maxRadius;

    this.fft = new ddf.minim.analysis.FFT(audioIn.bufferSize(), audioIn.sampleRate());
    this.fft.logAverages(22, 1);
    this.fftFilter = new float[audioIn.bufferSize()];
  }

  private float radiusGrowth() {
    float secondsPerRadiusRefresh = maxSecondsPerRadiusRefresh * map(this.midi.effectSpeed.get("scope"), MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, 1, 0.05);
    return ((millis() % 100000)/2) / secondsPerRadiusRefresh % width;
  }

  void draw() {
    if(!drawing) return;
    push();
      beat.detect(audioIn.mix);


      fft.forward(audioIn.mix);
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


      //int oscillAlpha = 70; // (int) map(midi.opcDial, 65, 128, 40 , 70);
      blendMode(ADD);
      strokeWeight(6);
      strokeJoin(ROUND);

      if(lowCount > 48) {
        colorOne = purple;
        colorTwo = orange;
        colorThree = teal;
      } else if(lowCount > 32) {
        colorOne = orange;
        colorTwo = pink;
        colorThree = purple;
      } else if(lowCount > 16){
        colorOne = pink;
        colorTwo = teal;
        colorThree = orange;
      } else {
        colorOne = teal;
        colorTwo = purple;
        colorThree = pink;
      }

      int bufferSize = audioIn.bufferSize() -1 ;
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

        float r3 = map(
          (growth + parent.width / 4) % width,
          0,
          width,
          minRadius,
          maxRadius
        );

        float r4 = map(
          (growth + parent.width / 8) % width,
          0,
          width,
          minRadius,
          maxRadius
        );

        int amplitude = 80;
        float sample = r1 + audioIn.mix.get(i) * amplitude;
        float samplePrime = r1 + audioIn.mix.get(i+1) * amplitude;
        float angle =  PI * i / bufferSize;
        float anglePrime =  PI * (i + 1) / bufferSize;

        stroke(adjustColor(colorOne));

        line(
          originX - cos(angle) * sample,
          originY - sin(angle) * sample,
          originX - cos(anglePrime) * samplePrime,
          originY - sin(angle) * samplePrime
        );

      stroke(adjustColor(colorTwo));

      sample = r2 + fftFilter[i] * amplitude;
      samplePrime = r2 + fftFilter[i + 1] * amplitude;

      line(
        originX - cos(angle) * sample,
        originY - sin(angle) * sample,
        originX - cos(anglePrime) * samplePrime,
        originY - sin(angle) * samplePrime
       );
       
      int amplitude3 = 120;
      sample = r3 + audioIn.mix.get(i) * amplitude3;
      samplePrime = r3 + audioIn.mix.get(i+1) * amplitude3;

      stroke(adjustColor(colorThree));

      line(
        originX - cos(angle) * sample,
        originY - sin(angle) * sample,
        originX - cos(anglePrime) * samplePrime,
        originY - sin(angle) * samplePrime
      );
      
      stroke(adjustColor(colorTwo));

      sample = r4 + fftFilter[i] * amplitude3;
      samplePrime = r4 + fftFilter[i + 1] * amplitude3;

      line(
        originX - cos(angle) * sample,
        originY - sin(angle) * sample,
        originX - cos(anglePrime) * samplePrime,
        originY - sin(angle) * samplePrime
       );
  




    }
    pop();
  }
  
}
