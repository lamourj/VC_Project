class Ball {

  /**
   * considering that the ball has a mass of M = 1
   * with the only forces of the system to be gravitational force & friction force
   * We got Fres = gravityF - frictionF = m * a = a 
   * since we assume velocity new = velocity old + a
   * we get velocity new = velocityold + (gravityForce - frictionForce)
   *
   * gravityForce = (..., 0, ...)
   * frictionForce = (
   * 
   **/

  PVector location;
  PVector velocity;
  PVector gravityForce;
  PVector frictionForce;

  final float radius;
  final static float gravityCst = 0.9;
  final static float mu = 0.13;
  final static float rebounce = 1;
  
  final static boolean drawVector = false;

  Ball(float radius, float boxThickness) {    
    location = new PVector(0, -(radius + boxThickness/2), 0);
    gravityForce = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    frictionForce = new PVector(0, 0, 0);

    this.radius = radius;
  }

  void update(float rx, float rz, float boxLength) {

    gravityForce.x = sin(rz) * gravityCst;
    gravityForce.z = -sin(rx) * gravityCst;

    frictionForce = velocity.get();
    frictionForce.normalize();
    frictionForce.mult(-mu);

    velocity.add(gravityForce);
    velocity.add(frictionForce);
    
    PVector tempLocation = new PVector(location.x, location.y, location.z);
    tempLocation.add(velocity);
/*

    checkCylinderCollision();
    
    location.add(velocity);

    */
    //Now we check bounds
    if (tempLocation.x >= boxLength/2 || tempLocation.x <= -boxLength/2) {
      velocity.x = -rebounce * velocity.x;
    }

    if (tempLocation.z >= boxLength/2 || tempLocation.z <= -boxLength/2) {
      velocity.z = -rebounce * velocity.z;
    }

    //we prevent overflows
    if (location.x < -boxLength/2) {
      location.x = -boxLength/2;
    } else if (location.x > boxLength/2) {
      location.x = boxLength/2;
    }

    if (location.z < -boxLength/2) {
      location.z = -boxLength/2;
    } else if (location.z > boxLength/2) {
      location.z = boxLength/2;
    } 

    //this part simulate the static friction constant (which we set equal to the kinetic friction constant)
    if (velocity.mag() <= mu) {
      velocity = new PVector(0, 0, 0);
    }
    
    
    
    checkCylinderCollision();
    
    location.add(velocity);
    
  }

  void display() {
    translate(location.x, location.y, location.z);

    if (drawVector) {    
      fill(color(255, 0, 0));
      drawVector(gravityForce, 1000);
      fill(color(0, 255, 0));
      drawVector(frictionForce, 1000);
      fill(color(0, 0, 255));
      drawVector(velocity, 10);
    }

    fill(color(188, 61, 219));
    sphere(radius);
  }

  void drawVector(PVector x, float multiplier) {
    PVector perp = new PVector(-x.z, 0, x.x);
    perp.normalize();
    beginShape();
    vertex(-radius * perp.x, 0, -radius * perp.z);
    vertex(x.x * multiplier, 0, x.z * multiplier);
    vertex(radius * perp.x, 0, radius * perp.z);
    endShape();
  }
  
  void checkCylinderCollision(){
    for(int i = 0 ; i < cylinders.size() ; i++){
      PVector tmp = cylinders.get(i);
      PVector v = new PVector(tmp.x, tmp.y, tmp.z);
      
      PVector tempLocation = new PVector(location.x, location.y, location.z);
      tempLocation.add(velocity);
      float d = sqrt(
        (tempLocation.x - v.x) * (tempLocation.x - v.x) +
        (tempLocation.z - v.z) * (tempLocation.z - v.z));
        
      boolean collision = d - cylinderBaseSize - radius < 0;
    
      if(collision && velocity.mag() >= mu){
        PVector n = new PVector(location.x - v.x, 0, location.z - v.z);
        n.normalize();
        
        float f = 2 * n.dot(velocity);
        n.mult(f);
        velocity.sub(n);
      }
    }
  }
}

