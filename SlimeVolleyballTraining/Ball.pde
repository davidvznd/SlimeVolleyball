class Ball {
  PVector position;
  PVector velocity;
  PVector acceleration;
  // The object now has mass!
  float mass;
  float size;
  int side=2;
  int count = 0;

  Ball(float x, float y) {
    // And for now, we’ll just set the mass equal to 1 for simplicity.
    setMass(1);
    velocity = new PVector(random(-4, 4), -5);
    position = new PVector(x, y);
    acceleration = new PVector(0, 0);
  }

  void setMass(float m) {
    mass = m;
    size = m * 5.0;
  }

  // Newton’s second law, applies forces when we need to.
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  //Update will calculate the position every draw call.
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    checkEdges();
    acceleration.mult(0);
  }
  //Display will visualize the position of the ball.
  void display() {
    stroke(0);
    fill(175);
    ellipse(position.x, position.y, size * 2, size * 2);
    fill(0);
    text(count, position.x, position.y);
    acceleration.mult(0);
  }

  // Somewhat arbitrarily, we are deciding that an object bounces when it hits the edges of a window.
  void checkEdges() {
    if (position.x > width - size) {
      position.x = width - size;
      velocity.x *= -0.95;
    } else if (position.x < size) {
      velocity.x *= -0.95;
      position.x = size;
    }

    if (position.y > height - size) {
      velocity.y *= -0.95;
      position.y = height - size;
    } else if (position.y < size) {
      velocity.y *= -0.95;
      position.y = size;
    }
  }

  //Checking collisions with player
  void checkCollision(Player other)
  {
    //Gets distance magnitude from the vector between two objects
    PVector distanceVector = PVector.sub(other.position, position);
    float distanceMag = distanceVector.mag();

    //Gets min. distance from the two object radiuses
    float minDistance = size + other.size/2;
    if (distanceMag < minDistance)
    {
      //Find direction to go and apply it.
      PVector directionCurrent = PVector.sub(position, other.position);
      velocity.mult(0.3);
      this.applyForce(directionCurrent);
      other.ballCollisions +=1;
    }
  }

  //Checking collision with wall
  void checkCollision(Wall other)
  {

    float testX = position.x;
    float testY = position.y;

    if (position.x < other.position.x)         testX = other.position.x;      // test left edge
    else if (position.x > other.position.x + other.sizeX) testX = other.position.x + other.sizeX;   // right edge

    if (position.y < other.position.y)         testY = other.position.y;      // top edge
    else if (position.y > other.position.y+other.sizeY) testY = other.position.y+other.sizeY;   // bottom edge

    // get distance from closest edges
    float distX = position.x-testX;
    float distY = position.y-testY;
    float distance = sqrt( (distX*distX) + (distY*distY) );

    if (distance <= size) {
      PVector origin = new PVector(other.position.x + other.sizeX/2, other.position.y + other.sizeY/2);
      PVector newDirection = PVector.sub(position, origin);
      velocity.mult(0.3);
      this.applyForce(newDirection);
    }
  }


  void drawVector(PVector vDir) {
    vDir.add(position);
    line(position.x, position.y, vDir.x, vDir.y);
    PVector arrow = PVector.sub(vDir, position).setMag(5).rotate(radians(130));
    line(vDir.x, vDir.y, vDir.x + arrow.x, vDir.y + arrow.y);
    arrow.rotate(radians(100));
    line(vDir.x, vDir.y, vDir.x + arrow.x, vDir.y + arrow.y);
  }
}