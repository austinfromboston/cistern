import codeanticode.syphon.*;

public class SyphonSender {
  PApplet parent;
  SyphonServer server;
  public SyphonSender(PApplet parent) {
    this.parent = parent;
    this.parent.registerMethod("draw", this);
    this.server = new SyphonServer(parent, "Processing Syphon");
  }
  
  void draw() {
    this.server.sendScreen();
  }
}
