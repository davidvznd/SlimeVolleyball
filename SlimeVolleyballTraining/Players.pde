class Player {
  int idInList;

  //physics variables
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;
  float size;

  //Player properties
  boolean jump = false;
  int playerNo;
  int wallPadding;
  int fitness_value = 0;
  boolean isGameOver = false;
  public int ballCollisions = 0;
  int internal_score;
  int player_count = 0;
  Network brain;

  //Constructor, comes with a new NN brain when called.
  Player(int playerNumber, int id)
  {
    idInList = id;
    internal_score = 0;
    brain = new Network(12, 4, 3);
    wallPadding = 10;
    if (playerNumber == 1)
    {
      playerNo = 1;
      position = new PVector(random(0, width/2-10), 600);
      velocity = new PVector(0, 0);
      acceleration = new PVector(0, 0);
    }
    if (playerNumber == 2)
    {
      playerNo = 2;
      position = new PVector(random(width/2+10, width-size), 600);
      velocity = new PVector(0, 0);
      acceleration = new PVector(0, 0);
    }
    arc(position.x, position.y, 100, 100, radians(180), radians(360));
  }

  void setMass(float m) {
    mass = m;
    size = m * 15f;
  }

  // Newton’s second law, called when we need a force to be calculated.
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  //Update will apply physics to the player.
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    checkEdges();
    acceleration.mult(0);
    velocity.x = 0;
  }

  // Checking if we're going outside the window size or fence in the middle
  void checkEdges() {
    //Each player has different bounds
    if (playerNo == 1)
    {
      //Must take into account slime size and wall size
      if (position.x > width/2 - size/2 - wallPadding) {
        position.x = width/2 - size/2 - wallPadding;
        velocity.x = 0;
      } else if (position.x < size/2) {
        velocity.x = 0;
        position.x = size/2;
      }
    } else
    {
      //P2 is on right side, different x values.
      if (position.x < width/2 + size/2 + wallPadding) {
        position.x = width/2 + size/2 + wallPadding;
        velocity.x = 0;
      } else if (position.x > width - size/2) {
        velocity.x = 0;
        position.x = width - size/2;
      }
    }

    if (position.y > height) {
      velocity.y = 0;
      position.y = height;
    } else if (position.y < size) {
      velocity.y = 0;
      position.y = size;
    }
  }

  void setPlayer(int i)
  {
    playerNo = i;
  }


  //Display a slime with properties dependent on what side that player is on
  void display()
  {
    if (playerNo == 1)
    { 
      fill(255, 0, 0);
      arc(position.x, position.y, size, size, radians(180), radians(360));
      fill(255, 255, 255);
      //Eye
      stroke(2);
      ellipse(position.x+size/3-10, position.y-size/3, 25, 25);
      fill(0);
      //Eyeball
      ellipse(position.x+size/3-5, position.y-size/3, 5, 5);
      text(idInList, position.x+size/3, position.y-size/3);
      text(player_count, position.x, position.y);
    } else
    {
      fill(0, 255, 0);
      arc(position.x, position.y, size, size, radians(180), radians(360));
      fill(255, 255, 255);
      //Eye
      stroke(2);
      ellipse(position.x-size/3+10, position.y-size/3, 25, 25);
      fill(0);
      //Eyeball
      ellipse(position.x-size/3+5, position.y-size/3, 5, 5);
      text(idInList, position.x+size/3, position.y-size/3);
    }
  }

  //Fitness functions
  public void multiplyFitness(int number)
  {
    fitness_value *= number;
  }

  public void addFitness(int number)
  {
    fitness_value += number;
  }


  public void resetFitness()
  {
    fitness_value = 0;
  }

  //Reset function based on player side.
  public void reset()
  {
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    isGameOver = false;

    if (playerNo ==1)
    {
      position = new PVector(random(0, width/2-10), 600);
      velocity = new PVector(0, 0);
      acceleration = new PVector(0, 0);
    } else
    {
      position = new PVector(random(width/2+10, width-size), 600);
      velocity = new PVector(0, 0);
      acceleration = new PVector(0, 0);
    }
  }

  //Mutation function.
  public void applyMutation(float mutation_rate)
  {
    //Hidden layer contains all connections so we iterate through each hidden node
    for (int i = 0; i < 5; i++)
    {
      //16 total connections each neuron - both input and output.
      for (int j = 0; j < 16; j++)
      {
        float chance = random(0, 1);
        // if less than or equal to mutation rate
        if (chance <= mutation_rate)
        {
          // 5% chance to mutate a connection
          Connection c = (Connection)brain.hidden[i].connections.get(j);
          if (random(0, 1) <= 0.05)
          {
            //Change the connection from -1 to 1
            c.weight = random(-1, 1);
            break;
          }
        }
      }
    }
  }
}