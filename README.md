# The Complete Slime Volleyball AI
Download link to AI: https://drive.google.com/open?id=1klDF5lTysELwB9Oeya7r48dj8DjWSIOy

The current files showcases a genetic algorithm in action, with the simulation showcasing 100 AI playing against each other and gettng better through generations. 

If wanting to see visually how it works, press 'D' to toggle showing the training being rendered. 
NOTE that visuals slow down the logic and means it'll take longer to simulate the generations.

# The Neural Network
Soon...

# Machine Learning - The Genetic Algorithm
I will try to explain the overall structure of the training, and how new generations and their population is generated.
The training is outlined below:
  - 100 in a population split into pairs 
  - 'n' number of rounds are played
  - Fitness is scored based on certain properties. I chose the rally count and total wins to have elites be good at winning and can keep the ball up.
  - The population is then culled and repopulated back to 100 by... reusing the top 5 elites, cloning 5 of the fittest elite, generating 80 from the mating pool (through a roulette style - higher fitness = higher chance to be a parent) and lastly having 10 completely random offspring.
  - The cycle continues until we feel like there has been enough training or fitness has stalled for too long.
  
  In depth will be added soon.
  
# How it was done
Soon.

# End Notes
Soon..
