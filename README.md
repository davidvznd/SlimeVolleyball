# The Complete Slime Volleyball AI
Download link to AI: https://drive.google.com/open?id=1klDF5lTysELwB9Oeya7r48dj8DjWSIOy

//If wanting to see how the training code works, press 'D' to show the training being rendered.

# The Neural Network
Soon...

# Machine Learning - The Genetic Algorithm
All the display code can be enabled using the 'D' key, but prepare for the 50 1v1's that appear.
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
