
public class Coordinate {
  public float x;
  public float y;
  public float z;
  
  public Coordinate(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public Coordinate multiplied(float multiplier) {
    return new Coordinate(
      this.x * multiplier,
      this.y * multiplier,
      this.z * multiplier
    );
  }
  
  public Coordinate offset(float offsetX, float offsetY, float offsetZ) {
    return new Coordinate(
      this.x + offsetX,
      this.y * offsetY,
      this.z + offsetZ
    );

  }
  
  public Coordinate flip(float centerX, float centerY, float centerZ) {
        return new Coordinate(
      centerX - this.x,
      centerY - this.y,
      centerZ - this.z
    );
  }
}

public class LayoutLoader {
  //String filename;
  //JSONObject json;  
  //JSONArray points;
  
  public ArrayList<Coordinate> points;
  
  public LayoutLoader() {
    this.points = new ArrayList<Coordinate>();
  }
  
  public void loadList(String filename) {
    JSONArray json = loadJSONArray(filename);
    //JSONArray points = json.getJSONArray();
    println("points found " + json.size());
    for(int i = 0; i < json.size(); i++) {
      JSONArray rawCoord = json.getJSONObject(i).getJSONArray("point");
      this.points.add(
        new Coordinate(
          rawCoord.getFloat(0), 
          rawCoord.getFloat(1), 
          rawCoord.getFloat(2)
          )
      );      
    }
  }
}