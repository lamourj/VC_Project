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
float ballRadius = 20;
boolean pause;
boolean canAddCylinder;

// Data visualization variables

PGraphics dataBackground;
int dataVSize = 150;

PGraphics topView;
int ecart = 10;
int topViewSize = dataVSize - ecart;

PGraphics scoreView;
int scoreViewSize = topViewSize;
int score;
int lastScore;
int difficultyLevel;

PGraphics scoreChartView;
int hsHeight = 20;
int scoreChartViewWidth;
HScrollbar scoreChartHs;

void setup() {
  size(windowSize, windowSize, P3D);
  this.ball = new Ball(ballRadius, plateHeight);
  pause = false;  
  canAddCylinder = false;

  dataBackground = createGraphics(windowSize, dataVSize, P2D);
  topView = createGraphics(topViewSize, topViewSize, P2D);
  scoreView = createGraphics(scoreViewSize, scoreViewSize, P2D);
  scoreChartViewWidth = width - topViewSize - scoreViewSize - 3 * ecart;
  scoreChartView = createGraphics(scoreChartViewWidth, topViewSize - hsHeight - ecart);
  scoreChartHs = new HScrollbar(topViewSize + 2.5 * ecart + scoreViewSize,height - hsHeight - ecart / 2.0,scoreChartViewWidth,hsHeight);
  lastScore = 0;
  score = 0;
  difficultyLevel = 4;
}

void draw() {
  background(200);
  fill(10, 0, 0);
  text("Mouse speed : " + (int)moveSpeed + "  (press q/w to adjust)"  , 0, 10);
  text("Difficulty level (edges' hit influence on your score) :" + difficultyLevel + "   (press y/x to adjust)", 0, 25);

  pushMatrix();

  drawBackground(); 
  image(dataBackground, 0, windowSize - dataVSize);

  drawTopView();
  image(topView, ecart / 2.0, windowSize - topViewSize - ecart / 2.0);
  
  drawScoreView();
  image(scoreView, (3.0 / 2) * ecart + topViewSize, windowSize - scoreViewSize - ecart / 2.0);

  drawScoreChartView();
  image(scoreChartView, 2.5 * ecart + topViewSize + scoreViewSize, windowSize - scoreViewSize - ecart / 2.0);
  popMatrix();


  translate(windowSize / 2, (windowSize - dataVSize) / 2, 0);




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
    float currentY = mouseY - (windowSize - dataVSize) / 2;
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

void drawScoreChartView() {
  scoreChartView.beginDraw();
  scoreChartView.background(50);
  scoreChartHs.update();
  scoreChartHs.display();
  scoreChartView.endDraw();
}

void drawScoreView() {
  scoreView.beginDraw();
  scoreView.background(0);
  scoreView.text("Total Score", 5, 15);
  scoreView.text(score, 5, 30);
  scoreView.text("Velocity", 5, 65);
  scoreView.text((int)(ball.velocity.mag()), 5, 80);
  scoreView.text("Last Score", 5, 115);
  scoreView.text(lastScore, 5, 130);
  scoreView.endDraw();
}  
 
void drawTopView() {
  topView.beginDraw();
  topView.background(0);
  
  float scale = topViewSize / plateLength;

  for(PVector cylinder : cylinders) {
    float x = cylinder.x;
    float z = cylinder.z;
   
    x = x * scale + topViewSize / 2;
    z = z * scale + topViewSize / 2;
    
    float ellipseRadius = cylinderBaseSize * scale;
    ellipseRadius *= 2;
    topView.fill(color(255, 255, 255));
    topView.ellipse(x, z, ellipseRadius, ellipseRadius);
  }
  
  float x = ball.location.x;
  float z = ball.location.z;
  
  x *= scale;
  x += topViewSize / 2;
  z *= scale;
  z += topViewSize / 2;
  
  float ellipseRadius = ballRadius * scale * 2;
  
  topView.fill(color(255, 0, 0));
  topView.ellipse(x, z, ellipseRadius, ellipseRadius);
  

  topView.endDraw();
}



  void mousePressed() {
    if (pause && canAddCylinder) {
      cylinders.add(new PVector(mouseX - windowSize / 2, 0, mouseY - (windowSize - dataVSize) / 2));
    }
  }

  void keyPressed() {
    if (key == CODED && keyCode == SHIFT)
      pause = true;
    if(key == 'y')
      if(difficultyLevel > 1)
        difficultyLevel--;
    if(key == 'x')
      if(difficultyLevel < 10)
        difficultyLevel++;
    if(key == 'q')
      if(moveSpeed > 1)
        moveSpeed--;
    if(key == 'w')
      if(moveSpeed < 10)
        moveSpeed++;     
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
    if(mouseY < height - dataVSize) {
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
  }


  void cylinder(float baseR, float h, int sides)
  {
    pushMatrix();

    translate(0, - cylinderHeight, 0);

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

  void cylinder() {
    cylinder(cylinderBaseSize, cylinderHeight, cylinderResolution);
  }
