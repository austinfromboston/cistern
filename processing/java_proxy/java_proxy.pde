LayoutLoader layout;
int smallPoint;
OPCListener opcIn;

void setup()
{
  layout = new LayoutLoader();
  layout.loadList("data/fanboy_strips3.json");

  opcIn = new OPCListener(this, 7890, layout.points.size());
  size(640, 640);
  smallPoint = 2;
  noStroke();
  background(0);
}

void draw() {
  for(int i=0; i < layout.points.size(); i++) {
    if(opcIn.opcColors != null) {
      int r = opcIn.opcColors[i * 3];
      int g = opcIn.opcColors[i * 3 + 1];
      int b = opcIn.opcColors[i * 3 + 2];
      if (i % 1000 == 0) {
        //println("color is", r, g,b );
      }
      fill(color(r, g, b), 120);
    } else {
      fill(#AA3333, 30);
    }
    Coordinate mappedPoint = layout.points.get(i).flip(0,0,0).multiplied(200).offset(300, 500, 400);
    ellipse(mappedPoint.x, mappedPoint.z, smallPoint, smallPoint);
  }
  
}
