class Ball{
  PVector location;
  PVector velocity;
  PVector gravity;
  
  float gravityCst;
  
  Ball(){
    gravityCst = 0.9;
    location = new PVector(0,0,0);
    gravity = new PVector(0,0,0);
    velocity = new PVector(0,0,0);
  }
  
  void update(float rotX, float rotZ){
    gravity.x = sin(rotZ) * gravityCst;
    gravity.z = -sin(rotX) * gravityCst;
    
    velocity.add(gravity);
    
    float normalForce = 1;
    float mu = 0.01;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    
    location.add(velocity);
    location.add(friction);

    
    
    
    color c = color(255,0,0);
    fill(c);
    translate(location.x,-75,location.z);
  }
  
  void display(){
    sphere(50);
  }
  
  void checkEdges(float boardX, float boardZ, float sizeX, float sizeZ){
    if(location.x+velocity.x > boardX+sizeX/2){
      velocity.x = velocity.x * -1;
    }
    else if(location.x+velocity.x < boardX-sizeX/2 ){
      velocity.x = velocity.x * -1;
    }
    
    if(location.z+velocity.z > boardZ+sizeZ/2){
      velocity.z = velocity.z * -1;
    }
    else if(location.z+velocity.z < boardZ-sizeZ/2){
      velocity.z = velocity.z * -1;
    }
  }
}
