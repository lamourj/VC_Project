float depth = 3000,ry=0,rx=0,rz=0;

float posx,posy;

float speed=10;

float boxSize = 2000;

Ball ball;


void setup(){
  size(800,800,P3D);
  noStroke();
  ball = new Ball();
}

void draw(){
  camera(0,-height,depth,0,0,0,0,1,0);
  directionalLight(50,100,125,0,-1,0);
  ambientLight(102,200,102);
  background(200);
  
  
  
  
  
  rotateX(rx);
  rotateZ(rz);
  rotateY(ry);
  
  color c = color(100,100,100);
  fill(c);
  box(boxSize,50,boxSize);
  
  
  ball.checkEdges(0,0,boxSize,boxSize);
  ball.update(rx,rz);
  ball.display();
  
  
}

void keyPressed(){
  if(key == CODED){
    if(keyCode == LEFT){
      ry -=speed*PI/360.  ;
    }
    else if (keyCode == RIGHT){
      ry += speed*PI/360.;
    }
  }
}

void mousePressed(){
  posx = mouseX;
  posy = mouseY;
}

void mouseDragged(){
  if(speed*(mouseX-posx)*PI/3600. <=60*PI/360. && -60*PI/360.<= speed*(mouseX-posx)*PI/3600.)
    rz = speed*(mouseX-posx)*PI/3600.;
  if(-speed*(mouseY-posy)*PI/3600. <= 60*PI/360. && -60*PI/360.<=-speed*(mouseY-posy)*PI/3600.)
    rx = -speed*(mouseY-posy)*PI/3600.;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  
  if(e+speed>0)
    speed += e;
}
