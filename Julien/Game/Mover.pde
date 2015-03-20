class Mover{
  PVector location;
  PVector velocity;
  float ballRadius = 10;
  PVector gravity;
  float gravityCst;
  float frictionMag;
  float normalForce = 1;
  float mu = 0.8;
  int mySwaggyCounter = 0;

  Mover(){
    location = new PVector(width/2, height/2, plateDepth + sphereRadius - 1);
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0,0,0);
    gravityCst = 0.9;
  }

  void update() {
    gravity.x = sin(rotY) * gravityCst;
    gravity.y = -sin(rotX) * gravityCst;

// println(rotX + " " + rotY + " " + rotZ);

    float frictionMag = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMag);


    velocity.add(gravity);
    velocity.add(friction);

    location.add(velocity);

    translate(location.x,location.y,location.z);
  }

  void display(){
    stroke(0);
    strokeWeight(2);
    fill(127);
    sphere(ballRadius);
  }

  void checkEdges(){
    if(location.x < -boxLength/2 || location.x > boxLength/2){
      velocity.x = - velocity.x;
    }
    if(location.x < -boxLength/2){
      location.x = -boxLength/2;
    }
    if(location.x > boxLength/2) {
      location.x = boxLength/2;
    }

    if(location.y < -boxLength/2 || location.y > boxLength/2){
      velocity.y = - velocity.y;
    }

    if(location.y < -boxLength/2){
      location.y = -boxLength/2;
    }
    if(location.y > boxLength/2){
      location.y = boxLength/2; 
    } 
  }

  void checkCylinderCollision(){
    for(int i = 0 ; i < cylindersCoords.size() ; i++){
      PVector n = new PVector(cylindersCoords.get(i).x, cylindersCoords.get(i).y, cylindersCoords.get(i).z);
      
     
      float dist = sqrt((n.x - location.x) * (n.x - location.x) + (n.y - location.y) * (n.y - location.y)) - sphereRadius - cylinderBaseSize;
      boolean edgeReached = dist <= 0;
      
      // Je suis assez sur que edgeReached marche comme il faut
      // (testé au println)... :-)
      
      n = new PVector(location.x - n.x, location.y - n.y, 0);
      
      if(edgeReached){
        
        // Where is the bullshit ?
        float f = velocity.dot(n);        
        n.mult(f);
        n.mult(2);
        velocity.sub(n);
      }     
    }
  }

}
