import ch.bildspur.artnet.*;
import ch.bildspur.artnet.packets.*;
import ch.bildspur.artnet.events.*;

import ch.bildspur.artnet.*;
import ch.bildspur.artnet.packets.*;
import ch.bildspur.artnet.events.*;

import processing.core.PApplet;
import processing.video.*;

Movie myMovie;

LayoutLoader layout;

void setup()
{
  String ip = "192.168.10.20";
  
  layout = new LayoutLoader();
  layout.loadList("data/boat_burn.json");
  size(20, 150);
  
  float proxyOriginX = width /2 - 60;
  float proxyOriginY = height / 6;
  //layout = layout.flip(0,0,0).flipX(0).multiplied(132).offset(proxyOriginX, 0, proxyOriginY);
  layout = layout.multiplied(1).flip(0,0,0).flipX(0).offset(0, 0, 0);

  myMovie = new Movie(this, "ripple_good_sliver.mov");
  myMovie.loop();
  
  OPCArtnetBridge rayOpc = new OPCArtnetBridge(this, ip, false);
  rayOpc.ledRayLayout(0, 0, layout, 310);
}

void draw()
{
   tint(28, 20, 170);
  image(myMovie, 0, 0);
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
