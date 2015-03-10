float rotX = 0;
float rotY = 0;
float rotZ = 0;
float lastPosX = 0;
float lastPosY = 0;
float moveSpeed = 1;


void setup() {
  size(500, 500, P3D); 
  noStroke();
}
void draw() {
  background(200);
  //ambientLight(125,125,0);
  //camera(mouseX, mouseY, 450, 250, 250, 0, 0, 1, 0); 
  translate(width/2, height/2, 0);
  
  boolean displayAxes = true;
  if(displayAxes){
    rotateX(0.04);
    rotateZ(0.04);
    color c = color(256,0,0);
    fill(c);
    // axe X = rouge
    box(500,10,10);
    c = color(0,255,0);
    fill(c);
    // axe Y = vert
    box(5, 500, 5);
    c = color(0,0,255);
    fill(c);
    // axe Z = bleu
    box(5,5,500);
  }
  
    
  rotateX(rotX);
  rotateY(rotY);
  rotateZ(rotZ);
  
  
  fill(color(0,0,0));
  box(100, 100, 10);  
}


void keyPressed(){
  if(key == CODED){
    if(keyCode == LEFT) {
      rotY -= moveSpeed * 0.1;
    }
    else if (keyCode == RIGHT){
      rotY += moveSpeed * 0.1;
    }
  }
}

void mouseMoved(){
  lastPosX = mouseX;
  lastPosY = mouseY;
}

void mouseDragged(){
  rotZ = rotZ - moveSpeed * 0.01 * (lastPosX - mouseX);
  rotX = rotX - moveSpeed * 0.01 * (-(lastPosY - mouseY));
  
  float extremValue =  (60*2*PI/360);
  if (rotX > extremValue)
    rotX = extremValue;
  if (rotX < -extremValue)
    rotX = -extremValue;
  if(rotZ > extremValue)
    rotZ = extremValue;
  if(rotZ < -extremValue)
    rotZ = -extremValue;
  lastPosX = mouseX;
  lastPosY = mouseY;
}

void mouseWheel(MouseEvent event) {
  moveSpeed -= 0.05 * event.getCount();
  if (moveSpeed < 0.1)
    moveSpeed = 0.1;
}





