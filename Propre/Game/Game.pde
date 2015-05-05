// Version Julien Data Visualization

float rx = 0;
float rz = 0;

float lrx = 0;
float lrz = 0;

float moveSpeed = 5;
float extremValue = (60 * 2 * PI / 360);

float plateHeight = 10;
float plateLength = 300;
int windowSize = 700;

float cylinderBaseSize = 20;
float cylinderHeight = 30;
int cylinderResolution = 30;
ArrayList<PVector> cylinders = new ArrayList<PVector>();

Ball ball;
boolean pause;
boolean canAddCylinder;

// Data visualization variables

PGraphics dataBackground;
int dataVSize = 150;

PGraphics topView;
int ecart = 10;
int topViewSize = dataVSize - ecart;

void setup() {
  size(windowSize, windowSize, P3D);
  this.ball = new Ball(20., plateHeight);
  pause = false;  
  canAddCylinder = false;

  dataBackground = createGraphics(windowSize, dataVSize, P2D);
  topView = createGraphics( topViewSize, topViewSize, P2D);
}

void draw() {
  background(200);
  fill(10, 0, 0);
  text("mouse speed : " + (int)moveSpeed, 0, 10);

  pushMatrix();

  drawBackground(); 
  image(dataBackground, 0, windowSize - dataVSize);

  drawTopView();
  image(topView, ecart / 2.0, windowSize - topViewSize - ecart / 2.0);

  popMatrix();


  translate(height/2, (windowSize - dataVSize) / 2, 0);




  if (!pause) {
    rotateX(rx);
    rotateZ(rz);
    fill(color(255, 0, 0));
    box(plateLength, plateHeight, plateLength);
    fill(color(0, 255, 0));
    drawCylinders();
    ball.update(rx, rz, plateLength);
    ball.display();
  }

  if (pause) {
    pushMatrix();
    rotateX(-PI/2);
    pushMatrix();
    ball.display();
    popMatrix();
    fill(color(255, 0, 0));
    box(plateLength, plateHeight, plateLength);
    fill(color(0, 255, 0));
    drawCylinders();

    float currentX = mouseX - windowSize / 2;
    float currentY = mouseY - windowSize / 2;
    translate(currentX, 0, currentY);

    PVector v = new PVector(currentX, 0, currentY);
    float d = sqrt(
    (ball.location.x - v.x) * (ball.location.x - v.x) +
      (ball.location.z - v.z) * (ball.location.z - v.z))
      - ball.radius
        - cylinderBaseSize;

    canAddCylinder = 
      currentX - cylinderBaseSize  > -plateLength / 2 
      && currentX + cylinderBaseSize < plateLength / 2
      && currentY - cylinderBaseSize > -plateLength / 2 
      && currentY + cylinderBaseSize < plateLength / 2
      && d > 0;

    if (canAddCylinder)
      fill(color(0, 255, 0));
    else
      fill(color(255, 0, 0));

    cylinder();
    popMatrix();
  }
}


void drawBackground() { 
  dataBackground.beginDraw(); 
  dataBackground.background(100); 
  dataBackground.endDraw();
}

void drawTopView() {
  topView.beginDraw();
  topView.background(0);



  /*
  pushMatrix();
   rotateX(-PI/2);
   pushMatrix();
   ball.display();
   popMatrix();
   fill(color(255,0,0));
   box(plateLength, plateHeight, plateLength);
   fill(color(0,255,0));
   drawCylinders();
   popMatrix();
   */

  /*
  for(int i = 0; i < cylinders.size() ; i++){
   PVector v = cylinders.get(i); 
   pushMatrix();
   translate(v.x, v.y, v.z);
   cylinder();
   popMatrix();
   }
   */

  //topView.ellipse(50, 50, 25, 25);
/*
  for (int i = 0; i < cylinders.size (); i++)  {
    PVector v = cylinders.get(i);
    pushMatrix();
    translate(v.x, v.y, v.z);
    //cylinder();
    
    float r = cylinderBaseSize * (topViewSize / windowSize);
    topView.ellipse(v.x, v.y, r, r);
    popMatrix();   
  } */
  topView.endDraw();
}



  void mousePressed() {
    if (pause && canAddCylinder) {
      cylinders.add(new PVector(mouseX - windowSize / 2, 0, mouseY - windowSize / 2));
    }
  }

  void keyPressed() {
    if (key == CODED && keyCode == SHIFT)
      pause = true;
  }

  void keyReleased() {
    if (key == CODED && keyCode == SHIFT) {
      pause = !pause;
    }
  }

  void mouseMoved() {
    lrx = mouseX;
    lrz = mouseY;
  }

  void mouseDragged() {
    rx = rx - moveSpeed * 0.001 * -(lrz - mouseY);
    rz = rz - moveSpeed * 0.001 * (lrx - mouseX);


    if (rx > extremValue)
      rx = extremValue;
    if (rx < -extremValue)
      rx = -extremValue;
    if (rz > extremValue)
      rz = extremValue;
    if (rz < -extremValue)
      rz = -extremValue;

    lrx = mouseX;
    lrz = mouseY;
  }


  void cylinder(float baseR, float h, int sides)
  {
    pushMatrix();

    translate(0, -cylinderHeight, 0);

    float angle;
    float[] x = new float[sides+1];
    float[] z = new float[sides+1];

    //get the x and z position on a circle for all the sides
    for (int i=0; i < x.length; i++) {
      angle = TWO_PI / (sides) * i;
      x[i] = sin(angle) * baseR;
      z[i] = cos(angle) * baseR;
    }


    //draw the bottom of the cylinder
    beginShape(TRIANGLE_FAN);

    vertex(0, 0, 0);

    for (int i=0; i < x.length; i++) {
      vertex(x[i], 0, z[i]);
    }

    endShape();

    //draw the center of the cylinder
    beginShape(QUAD_STRIP); 

    for (int i=0; i < x.length; i++) {
      vertex(x[i], 0, z[i]);
      vertex(x[i], cylinderHeight, z[i]);
    }

    endShape();

    //draw the top of the cylinder
    beginShape(TRIANGLE_FAN); 

    vertex(0, cylinderHeight, 0);

    for (int i=0; i < x.length; i++) {
      vertex(x[i], cylinderHeight, z[i]);
    }

    endShape();

    popMatrix();
  }

  void drawCylinders() {
    for (int i = 0; i < cylinders.size (); i++) {
      PVector v = cylinders.get(i); 
      pushMatrix();
      translate(v.x, v.y, v.z);
      cylinder();
      popMatrix();
    }
  }

  void mouseWheel(MouseEvent event) {
    float e = -event.getCount();
    moveSpeed = moveSpeed * e;

    if (moveSpeed < 1)
      moveSpeed = 1;
    if (moveSpeed > 10)
      moveSpeed = 10;
  }

  void cylinder() {
    cylinder(cylinderBaseSize, cylinderHeight, cylinderResolution);
  }

