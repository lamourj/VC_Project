void setup() {
  size(1000, 1000, P2D);
}

void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  
  //rotated around x
  float[][] transform1 = rotateXMatrix(PI/8); 
  input3DBox = transformBox(input3DBox, transform1); 
  projectBox(eye, input3DBox).render();
  
  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0); 
  input3DBox = transformBox(input3DBox, transform2); 
  projectBox(eye, input3DBox).render();
  
  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2); 
  input3DBox = transformBox(input3DBox, transform3); 
  projectBox(eye, input3DBox).render();
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] ps = new My3DPoint[box.p.length];
  for (int i = 0; i<box.p.length; i++) {

    ps[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(ps);
}

class My3DBox {
  My3DPoint[] p;

  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[] {
      new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }

  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

My2DBox projectBox(My3DPoint eye, My3DBox box) {
  My2DPoint[] hey = new My2DPoint[8];
  for (int i = 0; i<box.p.length; i++) {
    hey[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(hey);
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float[] pHomo = new float[4];
  pHomo[0] = p.x;
  pHomo[1] = p.y;
  pHomo[2] = p.z; 
  pHomo[3] = 1;

  float[][] t = {{1, 0, 0, -eye.x},
                 {0, 1, 0, -eye.y},
                 {0, 0, 1, -eye.z},
                 {0, 0, 0, 1}};

  float[] pHomoTrans = new float[4];
  pHomoTrans[0] = scalMult(t[0], pHomo);
  pHomoTrans[1] = scalMult(t[1], pHomo);
  pHomoTrans[2] = scalMult(t[2], pHomo);
  pHomoTrans[3] = scalMult(t[3], pHomo);

  float[][] P = {{1, 0, 0, 0},
                 {0, 1, 0, 0},
                 {0, 0, 1, 0},
                 {0, 0, 1/(-eye.z), 0}};

  float[] pHomoTransPro = new float[4];
  pHomoTransPro[0] = scalMult(P[0], pHomoTrans);
  pHomoTransPro[1] = scalMult(P[1], pHomoTrans);
  pHomoTransPro[2] = scalMult(P[2], pHomoTrans);
  pHomoTransPro[3] = scalMult(P[3], pHomoTrans);

  return new My2DPoint(pHomoTransPro[0]/pHomoTransPro[3], pHomoTransPro[1]/pHomoTransPro[3]);
}

float scalMult(float[] a, float[] b) {
  float sum = 0;
  for (int i = 0; i<a.length; i++) {
    sum = sum + a[i]*b[i];
  }
  return sum;
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }

  void render() {
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);

    line(s[2].x, s[2].y, s[1].x, s[1].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);

    line(s[7].x, s[7].y, s[3].x, s[3].y);
    line(s[7].x, s[7].y, s[4].x, s[4].y);
    line(s[7].x, s[7].y, s[6].x, s[6].y);

    line(s[5].x, s[5].y, s[1].x, s[1].y);
    line(s[5].x, s[5].y, s[4].x, s[4].y);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
  }
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0, 0, 0},
                        {0, cos(angle), sin(angle), 0},
                        {0, -sin(angle), cos(angle), 0},
                        {0, 0, 0, 1}});
}

float[][] rotateYMatrix(float angle) {
  return(new float[][] {{cos(angle), 0, -sin(angle), 0},
                       {0, 1, 0, 0},
                       {sin(angle), 0, cos(angle), 0},
                       { 0, 0, 0, 1 }});
}

float[][] rotateZMatrix(float angle) {
  return(new float[][] {{cos(angle), sin(angle), 0, 0},
                        {sin(angle), cos(angle), 0, 0},
                        {0, 0, 1, 0},
                        {0, 0, 0, 1}});
}

float[][] scaleMatrix(float x, float y, float z) {
  return (new float[][] {{x, 0, 0, 0},
                         {0, y, 0, 0},
                         {0, 0, z, 0},
                         {0, 0, 0, 1}});
}

float[][] translationMatrix(float x, float y, float z) {
  return (new float[][] {{1, 0, 0, x},
                         {0, 1, 0, y},
                         {0, 0, 1, z},
                         {0, 0, 0, 1}});
}

float[] matrixProduct(float[][] a, float[]b) {
  float[] toReturn = new float[b.length];
  for (int i = 0; i<a.length; i++) {
    toReturn[i] = scalMult(a[i], b);
  } 
  return toReturn;
}
