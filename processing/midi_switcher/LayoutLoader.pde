
public class Coordinate {
  public float x;
  public float y;
  public float z;
  
  public Coordinate(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

public class LayoutLoader {
  //String filename;
  //JSONObject json;  
  JSONArray points;
  
  ArrayList<Coordinate> coords;
  
  //public LayoutLoader(String filename) {
  //  this.filename = filename;
  //}
  
  public void loadList(String filename) {
    JSONArray json = loadJSONArray(filename);
    //JSONArray points = json.getJSONArray();
    println("points found " + json.size());
  }
}
