# Topologies

Gossip and Push-sum simulator

## Instructions

### Expected Input

1. **Number of nodes** Non-negative integer
2. **Topology** It must belong to the following list:
  - line
  - full
  - rand2D
  - 3D
  - impLine
  - Torus
  - Algorithm
  - gossip
  - push-sum

### Sample

#### Input

For input n = 1200, topology = Imperfect Line and  algorithm= Push sum
```
Elixir lib/topologies.ex 1200 impLine push-sum
```

#### Output

```
Convergence time for push-sum for 1200 nodes was achieved in 1781 Milliseconds
```

## Explanation

### Gossip Algorithm

A random first node is picked by the main process to initiate the Gossip algorithm. We make a list of all adjacent nodes to this initial node and pick a new random node amongst these and transmit the message. A node stops transmitting the message once it has heard the rumor more than 10 times. If a node receives a message after the 10th time, a new random node is picked from the list of all nodes and the propagation continues. We perform this process continuously for all nodes until convergence is achieved. 

Convergence is achieved when all nodes in the topology have received the message at least once.

### Push Sum Algorithm

A random node is picked by the main process for push sum algorithm. 
Initially, state and weight are defined as s = xi = i (that is actor number i has value i, play with other distribution if you so desire) and w = 1. While sending the message half of the s and w are sent to another node, which are the added to their current s and w.
A node stops transmitting the message once the ratio (s/w) do not change more than 10^(-10) in 3 consecutive rounds. In this case, a random node is chosen again  from the list of all nodes and Push-Sum  algorithm is continued. 

Convergence is achieved when all nodes in the topology receives the message at least once.

### Building Topologies

Full  Network: Every  actor  is  a  neighbor  of  all  other  actors.   That  is, every actor can talk directly to any other actor.
3D Grid: Actors form a 3D grid.  The actors can only talk to the grid neighbors.
Random 2D  Grid: Actors  are  randomly  position  at  x,y  coordinates on a [0-1.0]X[0-1.0] square.  Two actors are connected if they are within 1 distance to other actors.
Torus: Actors  are  arranged  in  a  sphere.   That  is,  each  actor  has  4 neighbors (similar to the 2D grid) but both directions are closed to form circles.
Line: Actors are arranged in a line.  Each actor has only 2 neighbors (one left and one right, unless you are the first or last actor).
Imperfect Line: Line arrangement but one random other neighbor is selected from the list of all actors.


### Graphs

For both graphs:
- X - Axis -> Size of network (number of nodes)
- Y - Axis -> Convergence time (in milliseconds)

![Gossip Algorithmt](https://github.com/FatemaSaifee/GossipAlgorithm/topologies/images/g1 "Logo Title Text 1")


#### Inference from Gossip Algorithm graph:

1. The convergence time for **Line** topology increases exponentially to the order of **y ≈ kn**, for even smaller number of nodes. (k is any constant)
2. The convergence time for **Imperfect Line** topology seems exponential but is closer (but not equal to) to the order of **y ≈ n2** with a slight increase in nodes when compared to line. 
3. The convergence time for **full** and **3D** topologies increase faster than linear time almost(but not equal to) to the order of **y ≈ n * log n**
4. The convergence time for **2D** and Torus topologies increase in a clear linear fashion to the order of **y ≈ kn**, where k is any constant.
5. An important observation in case of **Imperfect Line** is that the convergence time does not always increase with increase in number of nodes. As the third neighbor is picked randomly from the list of all nodes, the convergence time is heavily dependant on which node is picked to be the third neighbor.

![Push-Sum Algorithmt](https://github.com/FatemaSaifee/GossipAlgorithm/topologies/images/g2 "Logo Title Text 1")


### Inference from Push Sum Algorithm graph:

1. The convergence time for **Line** topology is the highest and is exponential to the order of **y ≈ mn** as number of nodes increase. (For any constant m)
2. The convergence time for **Torus** topology increase in a clear linear fashion to the order of **y ≈ Kn**, where K is any big constant.
3. The convergence time for **2D** topology increase in a clear linear fashion to the order of **y ≈ kn**, where k is any small constant.
4. The convergence time for **full** and **3D** topologies increase faster than linear time almost(but not equal to) to the order of **y ≈ n * log n**
5. An important observation in case of **Imperfect Line** is that the convergence time does not always increase with increase in number of nodes. As the third neighbor is picked randomly from the list of all nodes, the convergence time is heavily dependant on which node is picked to be the third neighbor.


### Largest network managed

1. Full  Network: 
  - Gossip: 500_000 
  - Push sum: 500_000
2. 3D Grid: 
  - Gossip: 500_000
  - Push sum: 500_000
3. Random 2D  Grid: 
  - Gossip: 5_000_000
  - Push sum: 5_000_000
4. Torus:
  - Gossip: 5_000_000
  - Push sum: 5_000_000
5. Line: 
  - Gossip: 2_000
  - Push sum: 2_000
6. Imperfect Line: 
  - Gossip: 2_000
  - Push sum: 5_000


**Note:**
* Please refer to Report.pdf for how to run and detailed analysis of Gossip and Push-Sum simulators.
* Also refer to bonusproject2.zip for implementation of node failure and its analysis.
* Please refer to graphs.py for graph generation of the various topologies.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `topologies` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:topologies, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/topologies](https://hexdocs.pm/topologies).
