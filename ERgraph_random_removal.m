#!/usr/bin/python
import igraph, random, bisect
import matplotlib.pyplot as plt

trials = 100
N = 1000
p = 0.01 # ( as p >= 1/(n-1), the graph will have a giant component initially)

division=100 # No. of divisions of the occupation probability scale

# Limits to vary the occupation probability within
upper_limit=division
lower_limit=0

vertices = list() # Array to store the vertices of the edges to be removed 
divs = list() # Array to store the occupation probability values (independent variable).
sizes = list() # Array to store the sizes of the giant components (dependent variable). 

# Setting up the X axis values-- the independent variable- obtained by scaling the loop counter 't' using the 'division' parameter.
divs = [float(x)/division for x in range(lower_limit, upper_limit,1)]
l_div=divs.__len__()

for i in range(0, trials):
  # Set up a random ER graph that's connected: 
  g = igraph.Graph.Erdos_Renyi(N,p)
  size1 = max(g.components("STRONG").sizes())

  # Running over the occupation probability percentage figures from the lower_limit, to the upper_limit, as per the divs array.
  for t in range(0, l_div, 1): 
    y = g.copy() # Re-generating a new copy of the random graph generated in this trial, as the old copy will have some nodes removed.

    for x in range(0, N): # x is also to be used as a vertex ID- which ranges from 0 to n-1, both included, in igraph.
      # If a random number is greater than the occupation probability, as from the divs list, add the vertex to the list of vertices to be removed. Else, do nothing.
      if random.random() >= divs[t]: 
        vertices.append(x)
    
    # Delete the randomly selected vertices. 
    if vertices.__len__() != 0: 
      y.delete_vertices(vertices)
    
    # Append the relative size of the giant component wrt the initial size, for that probability of removal, to the 'sizes' list/ 
    current_sizes=y.components("STRONG").sizes()
    if current_sizes: # Probabilistically, the entire graph can get deleted for low occupation probabilities.
      size=float(max(current_sizes))/size1 * 100
    else: 
      size=0

    # For the first trial, set up the sizes array. For all the consequtive ones, add the size values-to be normalised in the end.
    if i == 0: 
      sizes.append(size)
    else: 
      sizes[t]+=size

    # Need to refresh the list of vertices before re-computing for the next occupation probability value.
    del vertices[:]
  
length = sizes.__len__()
str1 = ""

# Normalizes the giant component sizes over the number of trials & forms a string to write the data of threshold Q v/s giant component sizes
for x in range(0, length, 1):
 sizes[x] = float(sizes[x])/trials

print 1/float(N*p) # Theoretical Qc for ER model (Poisson approximation): 1/<k> or 1/(N*p)

# Plots the graph of relative giant component size v/s occupation probability values. 
fig = plt.figure()
ax = fig.add_subplot(111)
ax.set_xlabel('Occupation probability')
ax.set_ylabel('Relative size of giant component')
ax.set_title('Giant component size wrt occupation probability')
plt.plot(divs,sizes)
plt.show()
