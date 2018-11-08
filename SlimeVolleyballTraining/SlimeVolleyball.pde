import java.util.Collections;
//Main SlimeVolleyball class
//Press 'D' to toggle visualisation of training.


//Physics variables
PVector gravity;
boolean targetActive = false; // show the target if true
boolean showVectors = false;
float c = 0.03; // friction coeficient

//Population, Player and AI variables.
Player[] Players;
int CurrentBestFitness1;
int SessionBestFitness1;

//Genetic Algorithm constants
float CROSS_THRESHOLD = 0.5f;
float MUTATION_RATE = 0.05f;

//Game values
int gameOverTotal = 0;
int roundNumber = 1;
boolean display = false;

//Elite for generation
Player SessionEliteP1;


//Population and UI variables
int populationSize = 100;
int GenerationNumber = 0;
ArrayList<Player> Population1 = new ArrayList<Player>();
ArrayList<Ball> GameBalls = new ArrayList<Ball>();
Wall middle;

void setup() {
  //Initialize initial game objects and world values.
  size(900, 500);
  background(255);
  middle = new Wall();
  gravity = new PVector(0, 2);

  //Max possible frames for fast training calculations.
  frameRate(99999999);

  //Construct balls for each game
  for (int i=0; i < populationSize/2; i++)
  {
    float chance = random(0, 1);
    if (chance >= 0.5)
    {
      GameBalls.add(new Ball(width/2-20, random(height/5)));
      GameBalls.get(i).setMass(5);
    }
    {
      GameBalls.add(new Ball(width/2+20, random(height/5)));
      GameBalls.get(i).setMass(5);
    }
  }

  //Initialise the population, they will have initial player ids that checks its position in the list.
  //Also setting which side they'll be on (1 or 2).
  for (int i=0; i < populationSize; i++)
  {
    if (i%2 == 0)
    {
      Population1.add(new Player(1, i));
      Population1.get(i).setMass(5);
    } else
    {
      Population1.add(new Player(2, i));
      Population1.get(i).setMass(5);
    }
  }

  //A two player arraylist to reference easier each iteration.
  Players = new Player[2];

  //Dummy initialization, changes after Generation 0 is complete.
  SessionEliteP1 = Population1.get(0);
}

void draw() {
  background(255);
  fill(0);
  textSize(20);

  //Used to determine if all games being run are over
  gameOverTotal = 0;

  //Running and updating 50 games at once, through a for loop and updating each pair of players as well as the designated ball.
  for (int i = 0; i < populationSize; i+=2)
  {
    //Get the two players from the population array. 
    Players[0] = Population1.get(i);
    Players[1] = Population1.get(i+1);

    //Check if the game is over for this pair, add them to total.
    if (Population1.get(i).isGameOver)
    {
      if (Population1.get(i+1).isGameOver)
      {
        gameOverTotal +=2;
        continue;
      }
    }

    //Code only occurs when ball gets stuck on wall, move over to a player's side if not moving.
    if (GameBalls.get(i/2).velocity.x <= 0.1 && GameBalls.get(i/2).velocity.x >= -0.1)
    {
      GameBalls.get(i/2).velocity.x += 0.1;
    }

    //Player 1 inputs - Parameters: P1 X, P1 Y, P1 Velocity X, P1 Velocity Y,  Ball X, Ball Y, Velocity Ball X, Velocity Ball Y, Opp X, Opp Y, Opp Velocity X, Opp Velocity Y
    //Maps the data from -1 to 1 based on their side: using normaliseValue function.
    float[] oneInput = new float[]{
      normaliseValue((Players[0].position.x), Players[0].size/2, ((width/2)-(Players[0].size/2) - (Players[0].wallPadding)), -1, 1), 
      normaliseValue((Players[0].position.y), height-100, height, 1, -1), 
      normaliseValue(Players[0].velocity.x, -10, 10, -1, 1), 
      normaliseValue(Players[0].velocity.y, -10, 10, -1, 1), 
      normaliseValue(GameBalls.get(i/2).position.x, GameBalls.get(i/2).size/2, width-GameBalls.get(i/2).size/2, 1, -1), 
      normaliseValue(GameBalls.get(i/2).position.y, GameBalls.get(i/2).size/2, height-GameBalls.get(i/2).size/2, -1, 1), 
      normaliseValue(GameBalls.get(i/2).velocity.x, -13, 13, 1, -1), 
      normaliseValue(GameBalls.get(i/2).velocity.y, -19, 19, -1, 1), 
      normaliseValue((Players[1].position.x), (width/2) + (Players[1].size/2) + (Players[1].wallPadding), (width - (Players[1].size/2)), 1, -1), 
      normaliseValue((Players[1].position.y), height-100, height, 1, -1), 
      normaliseValue(Players[1].velocity.x, -10, 10, -1, 1), 
      normaliseValue(Players[1].velocity.y, -10, 10, -1, 1)
    };

    //Player 2 Inputs - Notice that inputs are based on the perspective of the AI, so if player is on P2 side the inputs will be mirrored (Only care about X values). 
    //We are essentially mirroring the X on the P2 side. Now we represent being close to the pole as 1, and the back as -1 for both players.
    //This allows us to train the AI, regardless of what side they're on.
    float[] twoInput = new float[]{
      normaliseValue((Players[1].position.x), (width/2) + (Players[1].size/2) + (Players[1].wallPadding), (width - (Players[1].size/2)), 1, -1), 
      normaliseValue((Players[1].position.y), height-100, height, 1, -1), 
      normaliseValue(Players[1].velocity.x, -10, 10, -1, 1), 
      normaliseValue(Population1.get(i+1).velocity.y, -10, 10, -1, 1), 
      normaliseValue(GameBalls.get(i/2).position.x, GameBalls.get(i/2).size/2, width-GameBalls.get(i/2).size/2, -1, 1), 
      normaliseValue(GameBalls.get(i/2).position.y, GameBalls.get(i/2).size/2, height-GameBalls.get(i/2).size/2, -1, 1), 
      normaliseValue(GameBalls.get(i/2).velocity.x, -13, 13, -1, 1), 
      normaliseValue(GameBalls.get(i/2).velocity.y, -19, 19, -1, 1), 
      normaliseValue((Players[0].position.x), Players[0].size/2, ((width/2)-(Players[0].size/2) - (Players[0].wallPadding)), -1, 1), 
      normaliseValue((Players[0].position.y), height-100, height, 1, -1), 
      normaliseValue(Players[0].velocity.x, -10, 10, -1, 1), 
      normaliseValue(Players[0].velocity.y, -10, 10, -1, 1)
    };  

    //Output information for both AI.
    float[] output1 = Players[0].brain.feedForward(oneInput);
    float[] output2 = Players[1].brain.feedForward(twoInput);

    //Checking if players are in air
    if (Population1.get(i).position.y >= height)
    {
      Population1.get(i).jump = false;
    }
    if (Population1.get(i+1).position.y >= height)
    {
      Population1.get(i+1).jump = false;
    }

    //Player 1 Movement Code - Only enters if they meet the threshold.
    //Jump
    if (Population1.get(i).jump == false && output1[0] > 0.75f) {
      P1Jump(Population1.get(i));
    }
    //Forward which is right on P1 side
    if (output1[1] > 0.75f) {
      Population1.get(i).velocity.x += 10.0f;
    }
    //Back which is left on P1 side
    if (output1[2] > 0.75f) {
      Population1.get(i).velocity.x -= 10.0f;
    }

    //Player 2 Movement code - Enters when threshold met.
    //Jump
    if (Population1.get(i+1).jump == false && output2[0] > 0.75f) {
      P2Jump(Population1.get(i+1));
    }
    //Forward which is left for P2
    if (output2[1] > 0.75f) {
      Players[1].velocity.x -= 10f;
    }
    //Back which is right for P2.
    if (output2[2] > 0.75f) {
      Players[1].velocity.x += 10f;
    }

    //Physics applied to players from the world - gravity, friction.
    Population1.get(i).applyForce(gravity);
    Population1.get(i+1).applyForce(gravity);
    Population1.get(i).update();
    Population1.get(i+1).update();
    PVector friction1 = Population1.get(i).velocity.copy();
    PVector friction2 = Population1.get(i+1).velocity.copy();
    friction1.mult(-1);
    friction1.normalize();
    friction1.mult(c);
    friction2.mult(-1);
    friction2.normalize();
    friction2.mult(c);
    Population1.get(i).applyForce(friction1);
    Population1.get(i+1).applyForce(friction2);


    //Physics for the ball.
    PVector friction = GameBalls.get(i/2).velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(c);
    GameBalls.get(i/2).applyForce(friction);
    GameBalls.get(i/2).applyForce(gravity);

    //Check collisions for each item - players and wall
    GameBalls.get(i/2).checkCollision(Population1.get(i));
    GameBalls.get(i/2).checkCollision(Population1.get(i+1));
    GameBalls.get(i/2).checkCollision(middle);
    GameBalls.get(i/2).update();
    ballSideCheck(GameBalls.get(i/2));

    //Display the training room if we toggled the display.
    if (display)
    {
      game_display(i);
    }

    //Game end condition - if ball hits the floor.
    if (GameBalls.get(i/2).position.y + GameBalls.get(i/2).size >= height)
    {
      //Ball landed on AI 2 side
      if (GameBalls.get(i/2).position.x + GameBalls.get(i/2).size> width/2 + middle.sizeX/2)
      {
        if (GameBalls.get(i/2).count >= 1)
        {
          //Add values that will be used for fitness - Points for winning, rally length.
          Population1.get(i).internal_score +=2;
          Population1.get(i).player_count += GameBalls.get(i/2).count/2;
        }
      } else
      {
        //Otherwise landed on AI 1 side.
        if (GameBalls.get(i/2).count >= 1)
        {
          //Add values that will be used for fitness - Points for winning, rally length.
          Population1.get(i+1).internal_score +=2;
          Population1.get(i+1).player_count += GameBalls.get(i/2).count/2;
        }
      }
      //Game is over for these two AI.
      Population1.get(i).isGameOver = true;
      Population1.get(i+1).isGameOver = true;
    }
  }

  //When match is over for all AI in population.
  if (gameOverTotal == populationSize)
  {
    //Check if generation is ending - when 6 rounds have been played.
    if (roundNumber >= 6)
    {
      //Each pair is given their fitness.
      for (int i=0; i < populationSize-1; i+=2)
      {
        //Add win scores and multiply by the rally count to produce fitness.
        Population1.get(i).addFitness(Population1.get(i).internal_score);
        Population1.get(i).multiplyFitness(Population1.get(i).player_count);

        Population1.get(i+1).addFitness(Population1.get(i+1).internal_score);
        Population1.get(i+1).multiplyFitness(Population1.get(i+1).player_count);
      }

      //Finding top 5 elites - put into an array to be added to the next generation.
      ArrayList<Player> bestElites = new ArrayList<Player>(); 
      for (int i=0; i < populationSize-1; i++)
      {
        if (i < 5)
        {
          bestElites.add(Population1.get(i));
        }
        for (int j = 0; j < bestElites.size()-1; j++)
        {
          if (Population1.get(i).fitness_value > bestElites.get(j).fitness_value)
          {
            bestElites.get(j).brain = Population1.get(i).brain;
            break;
          }
        }
      }

      //Gets the fittest elite.
      Player CurrentElite = Population1.get(0);
      for (int i=0; i < populationSize-1; i++)
      {
        if (Population1.get(i).fitness_value >= CurrentElite.fitness_value)
        {
          CurrentElite = Population1.get(i);
        }
      }

      //Generate the mating pool to do a roulette style breeding based on fitness/performance.
      ArrayList<Player> matingPoolP1 = new ArrayList<Player>();
      matingPoolP1 = generateMatingPool(Population1);

      //Debugging
      print("Mating Pool 1 Size: " + matingPoolP1.size() + "\n");


      //Crossover and Mutation for P1 Population.
      for (int i = 0; i < populationSize; i++)
      {
        Player P1Parent1;
        Player P1Parent2;
        //New population will have the top 5 elites, 5 of the fittest elite, 80 from mating pool and 10 completely random.
        if (i < 5)
        {
          //Add top 5 into new generation
          Population1.get(i).brain = bestElites.get(i).brain;
          continue;
        } else if (i >= 5 && i < 10)
        {
          //Add elite of this gen 5 times with mutation
          Population1.get(i).brain = CurrentElite.brain;
          Population1.get(i).applyMutation(MUTATION_RATE);
          continue;
        } else if (i < (int)populationSize*0.9 && i >= 10)
        {
          //Set up the parents based on the mating pool and move on to crossover/mutation code.
          P1Parent1 = matingPoolP1.get(int(random(matingPoolP1.size()-1)));
          P1Parent2 = matingPoolP1.get(int(random(matingPoolP1.size()-1)));
        } else
        {
          //Add 10 random new AI to population
          Population1.get(i).brain = new Network(12, 4, 3);
          continue;
        }
        //Ensuring we don't get stuck in a while loop.
        int breakpoint = 100;
        //If they're the same, make them not the same.
        while (P1Parent1.idInList == P1Parent2.idInList || breakpoint > 0)
        {

          if (i < (int)populationSize*0.9)
          {
            P1Parent2 = matingPoolP1.get(int(random(matingPoolP1.size())));
            breakpoint -=1;
          }
        }

        if (Population1.get(i).fitness_value >= CurrentElite.fitness_value)
        {
          CurrentElite = Population1.get(i);
        }

        //Hard coded since we won't be changing values anytime soon
        int hiddenlength = 5;
        int hiddenconnections = 16; //13 + 3

        //For each connection, we will determine if we get Parent 1 or Parent 2 weight 
        //Since all conections can be accessed by iterating hidden neurons, we iterate through each one to update the brain of each slime.
        for (int j = 0; j < hiddenlength; j++)
        {
          //Get each connection of a hidden neuron, change the connection to either parent 1 or 2
          HiddenNeuron[] hidden = Population1.get(i).brain.hidden;
          for (int k = 0; k < hiddenconnections; k++)
          {
            //50% chance to get the weight of parent 1 or parent 2
            if (random(0, 1) > CROSS_THRESHOLD)
            {
              Connection pc = (Connection) P1Parent1.brain.hidden[j].connections.get(k);
              Connection c = (Connection) hidden[j].connections.get(k);
              c.weight = pc.weight;
            } else
            {
              Connection pc = (Connection) P1Parent2.brain.hidden[j].connections.get(k);
              Connection c = (Connection) hidden[j].connections.get(k);
              c.weight = pc.weight;
            }
          }
        }
        //All children are given a chance to mutate a connection.
        Population1.get(i).applyMutation(MUTATION_RATE);
      }

      //Debugging code to print current/best elite.
      CurrentBestFitness1 = CurrentElite.fitness_value;

      //Save code when we have found a new session best.
      if (SessionBestFitness1 <= CurrentBestFitness1)
      {
        print("SAVING ELITE TO FILE\n");
        //Save function
        saveToFileP1(CurrentElite);
        //Save value for debugging
        SessionBestFitness1 = CurrentBestFitness1;
        SessionEliteP1 = CurrentElite;
        Population1.get((int)random(0, Population1.size())).brain = CurrentElite.brain;
      }

      //More debugging for each generation.
      print("current best P1: " + CurrentBestFitness1 + "\n");
      print("session best P1: " + SessionBestFitness1+ "\n");

      //We also create save files every 100th generation.
      if (GenerationNumber%100 == 0)
      {
        saveToFile(CurrentElite);
      }
   
      //More debugging to denote end of generation
      print("End of Generation: " + GenerationNumber+"\n");
      GenerationNumber+=1;

      //We shuffle the array to find new opponents.
      Collections.shuffle(Population1);
      //Call new generation function.
      NewGeneration();
    } else
    {
      //If we haven't finished the genereation, create another round
      roundNumber += 1;
      NewRound();
    }
  }
}

//Jump function for Player 1
void P1Jump(Player player1)
{
  if (player1.jump == false)
  {
    PVector jump = new PVector(0, 50f);
    player1.applyForce(jump.mult(-1));
    player1.jump = true;
  }
}

//Jump function for Player 2
void P2Jump(Player player2)
{
  if (player2.jump == false)
  { 
    PVector jump = new PVector(0, 50f);
    player2.applyForce(jump.mult(-1));
    player2.jump = true;
  }
}

//Toggles display of training.
void keyReleased() {
  if (keyCode == 'D') {
    if (display)
    {
      display = false;
    } else
    {
      display = true;
    }
  }
}

//Code when starting the NewGeneration
void NewGeneration()
{
  //Start a new round as well as returning to defaults
  NewRound();
  roundNumber = 1;
  //We also reset all stats of current generation for each population member
  for (int i = 0; i < populationSize; i++)
  {
    Population1.get(i).resetFitness();
    Population1.get(i).internal_score =0;
    Population1.get(i).ballCollisions=0;
    Population1.get(i).player_count=0;
  }
  //...as well as stats on the ball.
  for (int i = 0; i < populationSize/2; i++)
  {
    GameBalls.get(i).count = 0;
  }
}

//Function to call for a new round
void NewRound()
{  
  //Ball is sent back to the initial position and moves based on a random initial x velocity (left or right).
  for (int i = 0; i < populationSize/2; i++)
  {
    float chance = random(0, 1);
    if (chance >= 0.5)
    {
      GameBalls.get(i).velocity = new PVector(4, -5);
      GameBalls.get(i).position = new PVector(width/2 + 20, 100);
    } else
    {
      GameBalls.get(i).velocity = new PVector(-4, -5);
      GameBalls.get(i).position = new PVector(width/2 - 20, 100);
    }
    GameBalls.get(i).acceleration = new PVector(0, 0);
    GameBalls.get(i).side = 2;
  }
  
  //Reset the population to default start code as well as ensuring that idInList is correct, mainly helpful for when we go to a new generation.
  for (int i = 0; i < populationSize; i+=2)
  {
    Population1.get(i).setPlayer(1);
    Population1.get(i).reset();
    Population1.get(i+1).setPlayer(2);
    Population1.get(i+1).reset();
    Population1.get(i).idInList = i;
    Population1.get(i+1).idInList = i+1;
  }
}

//Function that creates copies of AI in a list, where the amount each population occupies is based on their fitness.
//This pool is used to determine parents for breeding the new generation.
ArrayList<Player> generateMatingPool(ArrayList<Player> population)
{
  ArrayList<Player> pool = new ArrayList<Player>();
  //for current population
  for (int i=0; i < population.size(); i++)
  {
    Player sample = population.get(i);
    //based on fitness create roulette wheel for each
    if (sample.fitness_value <= 0)
    {
      continue;
    }
    for (int j=0; j < (int) sample.fitness_value; j++)
    {
      pool.add(sample);
    }
  }

  return pool;
}

//Save function for every 100th generation
void saveToFile(Player elite) {
  //Saving to file
  String[] connectionsList1;
  String connectionData1="";

  // Have the hidden layer calculate its output
  for (int i = 0; i < elite.brain.hidden.length; i++) {
    //16 connections for hidden layer - 12 input + 3 output. We can get all the weights from the hidden layer.
    for (int j = 0; j < elite.brain.hidden[i].connections.size(); j++)
    {
      //We can grab connections weight like this.
      Connection c = (Connection) elite.brain.hidden[i].connections.get(j);
      //Concat to string along with a , in between each to create a list of connections to add to our game code.
      connectionData1 = connectionData1.concat(Float.toString(c.getWeight())+",");
    }
  }
  connectionsList1 = split(connectionData1, ",");
  print("connections1-Generation" + GenerationNumber +"- Fitness"+ SessionEliteP1.fitness_value + ".txt\n");
  saveStrings("Generation" + GenerationNumber +"- Fitness"+ elite.fitness_value + ".txt", connectionsList1);
}


//Save function for when training finds a new AI with the greatest fitness of the session.
void saveToFileP1(Player elite)
{
  //Saving to file
  String[] connectionsList1;
  String connectionData1="";

  // Have the hidden layer calculate its output
  for (int i = 0; i < elite.brain.hidden.length; i++) {
    //16 connections for hidden layer - 12 input + 3 output. We can get all the weights from the hidden layer.
    for (int j = 0; j < elite.brain.hidden[i].connections.size(); j++)
    {
      //We can grab a neurons data like this.
      Connection c = (Connection) elite.brain.hidden[i].connections.get(j);
      //Concat to string along with a , in between each to create a list of connections to add to our game code.
      connectionData1 = connectionData1.concat(Float.toString(c.getWeight())+",");
    }
  }
  connectionsList1 = split(connectionData1, ",");
  print("saving fitness:" + SessionBestFitness1);
  saveStrings("SBConn1Generation" + GenerationNumber +"- FITNESS"+ elite.fitness_value + ".txt", connectionsList1);
}

//Function that deals with counting rally and the determining the current side the ball is currently on.
void ballSideCheck(Ball theBall)
{
  //Right side of the window
  if (width/2 + 10> theBall.position.x)
  {
    int current = theBall.side;
    //If it's currently on the left side
    if (current == 0)
    {
      //Change the value to the right side and +1 to rally count.
      theBall.side = 1;
      theBall.count+=1;
    }
    if (current == 2)
    {
      //Otherwise if this is the first point of rally, just change the side.
      theBall.side = 1;
    }
  }
  //Left side of the window
  if (width/2 -10 < theBall.position.x)
  {
    int current = theBall.side;
    //If it's currently on the right side
    if (current == 1)
    {
      //Change the value to the left side and +1 to rally count.
      theBall.side = 0;
      theBall.count+=1;
    }
    if (current == 2)
    {
      //Otherwise if this is the first point of rally, just change the side.
      theBall.side = 0;
    }
  }
}

//This will convert the value based on old range to new range
float normaliseValue(float value, float oldRangeLow, float oldRangeHigh, float newRangeLow, float newRangeHigh)
{
  //NewValue = (((newRangeHigh-newRangeLow)*(oldValue-oldRangeLow))/oldRangeHigh-oldRangeLow) + newRangeLow
  float newValue;
  float upper;
  float lower;
  upper = (newRangeHigh-newRangeLow)*(value-oldRangeLow);
  lower = oldRangeHigh-oldRangeLow;
  newValue = (upper/lower) + newRangeLow;
  return newValue;
}

//Function only called if display is on, otherwise don't display anything.
void game_display(int i)
{
  middle.display();
  Population1.get(i).display();
  Population1.get(i+1).display();
  GameBalls.get(i/2).display();
}