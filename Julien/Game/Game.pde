float rx = 0;
float rz = 0;

float lrx = 0;
float lrz = 0;

float moveSpeed = 1;
float extremValue = (60 * 2 * PI / 360);

float plateHeight = 10;
float plateLength = 300;
int windowSize = 800;

float cylinderBaseSize = 20;
float cylinderHeight = 30;
int cylinderResolution = 30;
ArrayList<PVector> cylinders = new ArrayList<PVector>();

Ball ball;
boolean pause;

void setup(){
  size(windowSize, windowSize, P3D);
  this.ball = new Ball(20., plateHeight);
  pause = false;  
}

void draw() {
  background(200);
  translate(height/2, width/2, 0);
  
  if(!pause){
    rotateX(rx);
    rotateZ(rz);
    fill(color(255,0,0));
    box(plateLength, plateHeight, plateLength);

    drawCylinders();
    ball.update(rx, rz, plateLength);
    ball.display();
    
  }
  
  if(pause){
    pushMatrix();
    rotateX(-PI/2);
    box(plateLength, plateHeight, plateLength);
    drawCylinders();
    translate(mouseX - windowSize / 2, 0, mouseY - windowSize / 2);
    if(mouseX - windowSize / 2 - cylinderBaseSize / 2 > -plateLength / 2 
    && mouseX - windowSize / 2 + cylinderBaseSize / 2 < plateLength / 2
    && mouseY - windowSize / 2 - cylinderBaseSize / 2 > -plateLength / 2 
    && mouseY - windowSize / 2 + cylinderBaseSize / 2 < plateLength / 2)
      cylinder();
    popMatrix();
  }
}


void mousePressed() {
  if(pause){
    cylinders.add(new PVector(mouseX - windowSize / 2, 0, mouseY - windowSize / 2));
  }
}

void keyPressed() {
  if(key == CODED && keyCode == SHIFT)
    pause = true;
}

void keyReleased(){
  if(key == CODED && keyCode == SHIFT){
     pause = !pause;
  }
}

void mouseMoved() {
  lrx = mouseX;
  lrz = mouseY;
}

void mouseDragged() {
  rx = rx - moveSpeed * 0.01 * -(lrz - mouseY);
  rz = rz - moveSpeed * 0.01 * (lrx - mouseX);
  
  
  if(rx > extremValue)
    rx = extremValue;
  if(rx < -extremValue)
    rx = -extremValue;
  if(rz > extremValue)
    rz = extremValue;
  if(rz < -extremValue)
    rz = -extremValue;
    
  lrx = mouseX;
  lrz = mouseY;
  
}


void cylinder(float baseR, float h, int sides)
{
 pushMatrix();
  
 translate(0,-cylinderHeight,0);
  
  float angle;
  float[] x = new float[sides+1];
  float[] z = new float[sides+1];

  //get the x and z position on a circle for all the sides
  for(int i=0; i < x.length; i++){
    angle = TWO_PI / (sides) * i;
    x[i] = sin(angle) * baseR;
    z[i] = cos(angle) * baseR;
  }
  
  
  //draw the bottom of the cylinder
  beginShape(TRIANGLE_FAN);
 
  vertex(0,   0,    0);
 
  for(int i=0; i < x.length; i++){
    vertex(x[i], 0, z[i]);
  }
 
  endShape();
 
  //draw the center of the cylinder
  beginShape(QUAD_STRIP); 
 
  for(int i=0; i < x.length; i++){
    vertex(x[i], 0, z[i]);
    vertex(x[i], cylinderHeight, z[i]);
  }
 
  endShape();
 
  //draw the top of the cylinder
  beginShape(TRIANGLE_FAN); 
 
  vertex(0,  cylinderHeight, 0);
 
  for(int i=0; i < x.length; i++){
    vertex(x[i], cylinderHeight, z[i]);
  }
 
  endShape();
  
  popMatrix();
}

void drawCylinders() {
  for(int i = 0; i < cylinders.size() ; i++){
    PVector v = cylinders.get(i); 
    pushMatrix();
    fill(color(0,0, 255));
    translate(v.x, v.y, v.z);
    cylinder();
    popMatrix();
  }
}

void cylinder(){
  cylinder(cylinderBaseSize, cylinderHeight, cylinderResolution);
}