class Tube {
  int counter=0;
  int totalPoints = 6;   //the resolution of the tube.
  float slice = TWO_PI /totalPoints;
  float radius = thickness;     
  float len;            //length of the line (distance between two points)
  PVector start;        //starting point
  PVector end;          //ending point
  PVector rot;          //the rotation needed to go from starting point to ending point
  Tube(float x1, float y1, float z1, float x2, float y2, float z2) {
    start = new PVector(x1, y1, z1);
    end = new PVector(x2, y2, z2);
    len = start.dist(end);
    float rotX = calcRotation(start.y, start.z, end.y, end.z);
    float rotY =  (acos((end.z-start.z) / len))-HALF_PI;
    float rotZ = calcRotation(start.x, start.y, end.x, end.y);
    rot = new PVector(rotX, rotY, rotZ);
  }

  void setThickness(float thickness){
    radius = thickness;
  }

  void render() {
    float angle = 0;
    pushMatrix();
    translate(start.x, start.y, start.z);
    rotateZ(rot.z);
    rotateY(rot.y);
    rotateX(HALF_PI);

    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < totalPoints+1; i++) {
       float[] xy = polarToCartesian(radius, angle); 
       vertex(len, xy[0], xy[1]);
       vertex(0, xy[0], xy[1] );
       angle += slice;
    }
    endShape();
    popMatrix();
  }

  float[] polarToCartesian(float _radius, float angle) {
    float[] xy = new float[2];
    xy[0] = _radius*cos(angle);
    xy[1] = _radius*sin(angle);
    return xy;
  }

  private float calcRotation(float baseX, float baseY, float angleToX, float angleToY) {
    float angleInRadians = atan2(angleToY - baseY, angleToX - baseX);
    return angleInRadians;
  }
}

