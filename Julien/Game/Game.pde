float rotX = 0;
float rotY = 0;
float rotZ = 0;

float lastPosX = 0;
float lastPosY = 0;

float moveSpeed = 0.25;
float plateDepth = 10;
final static float sphereRadius = 8;
final static float boxLength = 200;
final static int windowSize = 500;

boolean pause;
boolean canRegister = false;

ArrayList<PVector> cylindersCoords = new ArrayList<PVector>();

// closedCylinder implementation:
PShape closedCylinder = new PShape();
float cylinderBaseSize = 12;
float cylinderHeight = 40;
int cylinderResolution = 100;


Mover mover = new Mover();


void setup() {
  size(windowSize, windowSize, P3D); 
  noStroke();
  pause = false;
  //frameRate(20);


  //ClosedCylinder implementation:    
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];

  for (int i = 0; i < x.length; i++) {
    float angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }

  closedCylinder = createShape();
  closedCylinder.beginShape(QUAD_STRIP);

  for (int i = 0; i < x.length; i++) {
    //draw the border of the cylinder
    closedCylinder.vertex(x[i], y[i], 0);
    closedCylinder.vertex(x[i], y[i], cylinderHeight);
  }

  //closedCylinder.beginShape(TRIANGLE_FAN);

  closedCylinder.endShape();
}


void draw() {

  if (pause) {
    clear();
    background(200);
    //camera(width, -height, 0, 250, 250, 250, 0, 0, 0);
    fill(color(0, 0, 0));
    translate(width/2, height/2, 0);
    rotateX(PI/10);
    fill(color(30, 30, 30));
    box(boxLength, boxLength, plateDepth);  
    fill(color(255, 0, 0));
    float currX = mouseX - windowSize / 2;
    float currY =  mouseY - windowSize / 2;
    boolean xCond = -boxLength / 2 + cylinderBaseSize <= currX && currX <= boxLength / 2 - cylinderBaseSize;
    boolean yCond = -boxLength / 2 + cylinderBaseSize <= currY && currY <= boxLength / 2 - cylinderBaseSize;
    canRegister = xCond && yCond;
    //displayCylinders();
    if(xCond && yCond){
      translate(currX, currY, 0);
      shape(closedCylinder);
    }
        
  } else {
    background(200);
    //ambientLight(125,125,0);
    //camera(width, -height, 20, 250, 250, 0, 0, 1, 0); 
    translate(width/2, height/2, 0);
    rotateX(PI/2); 


    rotateX(rotX);
    rotateY(rotY);
    rotateZ(rotZ);


    fill(color(0, 255, 0));
    box(boxLength, boxLength, plateDepth);  
    
    

    textSize(20);
    fill(50);
    String s = "Move-speed " + int(moveSpeed * 20);
    stroke(0, 10, 10);
    text(s, -boxLength/2, boxLength/2 + 5, -30);

    fill(color(255, 0, 0));
    
    displayCylinders();
    
    mover.update();
    mover.checkEdges();
    //mover.checkCylinderCollision();
    mover.display();
    
    
  }
}


void keyPressed() {
  if (key == CODED && keyCode == SHIFT) {
      pause = true;
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      pause = false;
      for(int i = 0; i < cylindersCoords.size(); i++){
        println(i + " " + cylindersCoords.get(i));
      }
      println("____________");
    }
  }
}

void displayCylinders(){
  for(int i = 0; i < cylindersCoords.size(); i++){
     //display Cylinders
    translate(cylindersCoords.get(i).x, cylindersCoords.get(i).y, 0);
    shape(closedCylinder);
    translate(-cylindersCoords.get(i).x, -cylindersCoords.get(i).y, 0);
  }
}

void mouseMoved() {
  lastPosX = mouseX;
  lastPosY = mouseY;
}

void mousePressed() {
  if (pause && canRegister) {
    cylindersCoords.add(new PVector(mouseX - windowSize / 2, mouseY - windowSize / 2, 0));
  }
}

void mouseDragged() {
  rotY = rotY - moveSpeed * 0.01 * (lastPosX - mouseX);
  rotX = rotX - moveSpeed * 0.01 * (-(lastPosY - mouseY));

  float extremValue =  (60*2*PI/360);
  if (rotX > extremValue)
    rotX = extremValue;
  if (rotX < -extremValue)
    rotX = -extremValue;
  if (rotY > extremValue)
    rotY = extremValue;
  if (rotY < -extremValue)
    rotY = -extremValue;
  lastPosX = mouseX;
  lastPosY = mouseY;
}

void mouseWheel(MouseEvent event)  {
  moveSpeed -= 0.05 * event.getCount();
  if (moveSpeed < 0.05)
    moveSpeed = 0.05;
  if (moveSpeed > 0.5)
    moveSpeed = 0.5;
}




