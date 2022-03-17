public class CircleWaltz extends Drawable {

  final int MAX_CIRCLE_CNT = 1000, MIN_CIRCLE_CNT = 100, 
    MAX_VERTEX_CNT = 20, MIN_VERTEX_CNT = 3;

  int circleCnt, vertexCnt;
    
  
  public CircleWaltz(PApplet parent, MidiStatus midi) {
    super(parent, midi);
  }



  void draw() {
    if(!drawing) return;
    push();
    //strokeWeight(0);
    dialOrigins(1);
    translate(originX, originY);
    colorMode(RGB);
  
    updateCntByControls();
  
    // 渲染每一个圆
    for (int ci = 0; ci < circleCnt; ci++) {
      float timeOffset = map(midi.dialSettings[SPEED_DIAL], 0, 127, 100, 5);
      float time = float(frameCount) / timeOffset;
      float thetaC = map(ci, 0, circleCnt, 0, TAU);
      float scale = 300;
  
      // 获得每一个圆的圆心、半径、颜色
      PVector circleCenter = getCenterByTheta(thetaC, time, scale);
      float circleSize = getSizeByTheta(thetaC, time, scale);
      color c = getColorByTheta(thetaC, time);
  
      // 绘制每一圆的所有顶点
      stroke(c);
      noFill();
      beginShape();
      for (int vi = 0; vi < vertexCnt; vi++) {
        float thetaV = map(vi, 0, vertexCnt, 0, TAU);
        float x = circleCenter.x + cos(thetaV) * circleSize;
        float y = circleCenter.y + sin(thetaV) * circleSize;
        vertex(x, y);
      }
      endShape(CLOSE);
    }
    pop();
  }

  void updateCntByControls() {
    //float xoffset = abs(mouseX - width / 2), yoffset = abs(mouseY - height / 2);
    circleCnt = int(map(midi.dialSettings[RIGHT_STICK_Y], MidiStatus.DIAL_MIN, MidiStatus.DIAL_MAX, MAX_CIRCLE_CNT, MIN_CIRCLE_CNT));
    vertexCnt = int(map(Math.min(midi.dialSettings[RIGHT_STICK_X], 100), MidiStatus.DIAL_MIN, 100, MAX_VERTEX_CNT, MIN_VERTEX_CNT));
  }
  
  PVector getCenterByTheta(float theta, float time, float scale) {
    PVector direction = new PVector(cos(theta), sin(theta));
    float distance = 0.6 + 0.2 * cos(theta * 6.0 + cos(theta * 8.0 + time));
    PVector circleCenter =PVector.mult(direction, distance * scale);
    return circleCenter;
  }
  
  float getSizeByTheta(float theta, float time, float scale) {
    float offset = 0.2 + 0.12 * cos(theta * 9.0 - time * 2.0);
    float circleSize = scale * offset;
    return circleSize;
  }
  
  color getColorByTheta(float theta, float time) {
    float th = 8.0 * theta + time * 2.0;
    float r = 0.6 + 0.4 * cos(th), 
      g = 0.6 + 0.4 * cos(th - PI / 3), 
      b = 0.6 + 0.4 * cos(th - PI * 2.0 / 3.0), 
      alpha = map(circleCnt, MIN_CIRCLE_CNT, MAX_CIRCLE_CNT, 150, 30);
    return color(r * 255, g * 255, b * 255, alphaAdj(alpha));
  }
}
