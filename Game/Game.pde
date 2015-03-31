float depth = 3000;
float rx = 0;
float rz = 0;
float oldMouseX = 0.;
float oldMouseY = 0.;
float rotateSpeed = 0.005;

boolean pause = false;
ArrayList<PVector> cylinderPos = new ArrayList<PVector>();

final static float limitAngle = PI/3;//60°

final static float boxLength = 2000;
final static float boxThickness = 50;

final static float cylinderBaseSize = 75.;
final static float cylinderHeight = 100.;
final static int cylinderResolution = 40;

final static float ballSize = 80.;

PShape openCylinder = new PShape();
PShape disk = new PShape();
PShape tree;

Ball ball;

void setup() {
  size(800, 800, P3D);
  noStroke();
  this.ball = new Ball(ballSize, boxThickness);

  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];

  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }

  openCylinder = createShape();

  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], 0, y[i]);
    openCylinder.vertex(x[i], -cylinderHeight, y[i]);
  }
  openCylinder.endShape();
  openCylinder.disableStyle();// in order to put custom colors

  disk = createShape();
  disk.beginShape(TRIANGLE_FAN);
  disk.vertex(0, 0, 0);
  for (int i = 0; i < x.length; i++) {
    disk.vertex(x[i], 0, y[i]);
  }
  disk.vertex(x[0], 0, y[0]);
  disk.endShape();
  disk.disableStyle();//in order to put custom colors
  
  tree = loadShape("arbre.obj");
  tree.scale(175);
}

void draw() {

  camera(0, 0, depth, 0, 0, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0); //those are some random value, to have smth but are not important
  ambientLight(102, 200, 102);
  background(200);
  text("rx = "+Math.toDegrees(rx)+"° rz = "+Math.toDegrees(rz)+"°", -250, -250, 2500);

  if (!pause) {
    rotateX(rx); //did not check if order rx then rz changes something
    rotateZ(rz);
  } else {
    rotateX((float) -Math.PI/2);
  }

  update();

  fill(color(24, 116, 150));
  box(boxLength, boxThickness, boxLength);
  fill(color(0, 0, 255));
  for (PVector pos : cylinderPos) {
    drawTree(pos);
  }
  ball.display();
  

}

void update() {
  if (!pause) {
    ball.update(rx, rz, boxLength, cylinderPos, cylinderBaseSize);
  } else {
    float scale = boxLength/(633-168);//1 px = scale U
    float transX = (mouseX - width/2.) * scale;
    float transY = (mouseY - width/2.) * scale;


    PVector sub = new PVector(ball.location.x, 0, ball.location.z);
    sub.sub(new PVector(transX, 0, transY));

    boolean correctPlacement = -boxLength/2. <= transX - cylinderBaseSize && transX + cylinderBaseSize <= boxLength/2. && // x bounds
                               -boxLength/2. <= transY - cylinderBaseSize && transY + cylinderBaseSize <= boxLength/2. && // z bounds
                                sub.mag() > (cylinderBaseSize + ballSize); // no intersect with the ball

    if (correctPlacement) {
      fill(color(0, 255, 0, 200));
      drawTree(new PVector(transX, 0, transY));
    } else {
      fill(color(255, 0, 0, 200));
      drawTree(new PVector(transX, 0, transY));
    }
  }
}

void drawTree(PVector pos) {
  pushMatrix();
  
  translate(pos.x, -boxThickness/2, pos.z);
  
  shape(openCylinder);
  
  rotateX(PI);

  shape(tree);
  popMatrix();
}

void mouseDragged() { //This function controls the movement of the plate
  //first, rotate on x axis
  float newRx = rx + rotateSpeed * (oldMouseY - mouseY);
  if (-1*limitAngle <= newRx && newRx <= limitAngle) {
    rx = newRx;
  }
  oldMouseY = mouseY;

  //then on z axis
  float newRz = rz + rotateSpeed * (mouseX - oldMouseX);
  if (-1*limitAngle <= newRz && newRz <= limitAngle) {
    rz = newRz;
  }
  oldMouseX = mouseX;
}

void keyPressed() {
  if (key == CODED && keyCode == SHIFT) {
    pause = true;
  }
}

void keyReleased() {
  if (key == CODED && keyCode == SHIFT) {
    pause = false;
  }
}

void mouseWheel(MouseEvent event) { //this function controls the speed of rotation of the plate
  float maxRotateSpeed = 0.01; //those are arbitrary limits
  float minRotateSpeed = 0.001;

  float newRotateSpeed = event.getCount()/10000. + rotateSpeed; // the div by 10^4 is there to normalize the wheel. 

  if (minRotateSpeed <= newRotateSpeed && newRotateSpeed <= maxRotateSpeed) {
    rotateSpeed = newRotateSpeed;
  }
}

void mouseMoved() { //useful to avoid jump in the moves of the plate
  oldMouseX = mouseX;
  oldMouseY = mouseY;
}

void mouseClicked() {
  if (pause) {


    float scale = boxLength/(633-168);//1 px = scale U
    float transX = (mouseX - width/2.) * scale;
    float transY = (mouseY - width/2.) * scale;

    PVector sub = new PVector(ball.location.x, 0, ball.location.z);
    sub.sub(new PVector(transX, 0, transY));

    boolean notOutOfPlate = -boxLength/2. <= transX - cylinderBaseSize && transX + cylinderBaseSize <= boxLength/2 &&
                            -boxLength/2. <= transY - cylinderBaseSize && transY + cylinderBaseSize <= boxLength/2. &&
                            sub.mag() > (cylinderBaseSize + ballSize);
                            
    if (notOutOfPlate) {
      System.out.println("added smth!");
      cylinderPos.add(new PVector(transX, 0, transY));
    }
  }
}



