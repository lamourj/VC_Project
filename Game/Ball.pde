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
  final static float mu = 0.17;
  final static float rebounce = 0.8;
  
  final static boolean drawVector = false;

  Ball(float radius, float boxThickeness) {    
    location = new PVector(0, -(radius + boxThickness/2), 0);
    gravityForce = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    frictionForce = new PVector(0, 0, 0);

    this.radius = radius;
  }

  void update(float rx, float rz, float boxLength, ArrayList<PVector> cylinders, float cylinderRadius) {

    gravityForce.x = sin(rz) * gravityCst;
    gravityForce.z = -sin(rx) * gravityCst;

    frictionForce = velocity.get();
    frictionForce.normalize();
    frictionForce.mult(-mu);

    velocity.add(gravityForce);
    velocity.add(frictionForce);

    //this part simulate the static friction constant (which we set equal to the kinetic friction constant)
    //it is useful when the plate is not inclined enough
    if (velocity.mag() <= mu) {
      velocity = new PVector(0, 0, 0);
    }
    
    location.add(velocity);
    
    //Now we check bounds, on x
    if (location.x >= boxLength/2){
      velocity.x = -rebounce * velocity.x;
      location.x = boxLength/2;
    }
    else if(location.x <= -boxLength/2){
      velocity.x = -rebounce * velocity.x;
      location.x = -boxLength/2;
    }
    
    //on z
    if (location.z >= boxLength/2){
      velocity.z = -rebounce * velocity.z;
      location.z = boxLength/2;
    }
    else if (location.z <= -boxLength/2) {
      velocity.z = -rebounce * velocity.z;
      location.z = -boxLength/2;
    }

    for(PVector pos : cylinders){
      PVector sub = new PVector(location.x, 0, location.z);
      sub.sub(new PVector(pos.x, 0, pos.z)); 
      
      if(sub.mag() < cylinderRadius + radius){
        //sub is the normal
        sub.normalize();
        
        PVector x = sub.get();
        x.mult(2.*velocity.dot(sub));
        velocity.sub(x);
        velocity.mult(rebounce);
        
        PVector old = new PVector(location.x, 0, location.z);
        
        location.add(velocity);
        
        //set location
        old.sub(pos);
        old.normalize();
        old.mult(cylinderRadius + radius);
        old.add(pos);

        location = new PVector(old.x, location.y, old.z); 
      }
    }

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

}

