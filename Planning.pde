import java.util.*;  // priority queue


// Obstacles
static int maxObs = 100;
int numObs = 40;
Obstacle allObstacles[] = new Obstacle[numObs];

// Nodes
static float cSpace = 2;
static int numNodes = 30;
static int minNodeDist = 5;
ArrayList<Node> allNodes = new ArrayList<Node>();
PriorityQueue<Node> fringe;

// path planning
ArrayList<Integer> out;
int startNode = 0;
int endNode = 4;
int prevDirectionNode = startNode;
int directionNode = -1; // used as the node to direct agent if -1, we didn't find a path
boolean first = true;

// Agent info
boolean moveAgent = false; // for starting agent to move along path
Agent agent; 

// setup our frame
void setup(){
  surface.setTitle("Agent Planning" + frameCount);
  size(1080, 720);
  
  // initialize obstacles
  generateRandomObs();
  
  // initialize nodes
  generateRandomNodes(numNodes, allNodes);
  
  // find all valid neighbors and populate their neighbor lists
  generateAllNeighbors();
  
  // Run uniform cost search
  out = UniformCostSearch(startNode, endNode);
  print(out);
  // set our direction node to be the first node to visit from start
  directionNode = 0;
  
  // Create agent corresponding to the start position
  // by assigning agent to just the pos vector, we only get reference and changes made to agent change the position of the node
  agent = new Agent(new Vec2 (allNodes.get(startNode).getPos().x, allNodes.get(startNode).getPos().y));
  
}

void draw() {
  background(200);
  for(int i = 0; i < numObs; i++) {
    fill(0,0,0);
    circle(allObstacles[i].getPos().x, 
           allObstacles[i].getPos().y, 
           allObstacles[i].getRad()*2);
  }
  // Start node
  fill(0,255,255);
  circle(allNodes.get(startNode).getPos().x, 
         allNodes.get(startNode).getPos().y, 
         cSpace*10);
         
  fill(255);
  circle(agent.pos.x, agent.pos.y, 10*2);
         
  if (moveAgent) {
    if (agent.pos.distanceTo(allNodes.get(out.get(directionNode)).getPos()) < 1) {
      if (directionNode >= out.size() - 1) {}// dont update pos we are at goal
      else {
        first = false;
        prevDirectionNode = directionNode;
        directionNode += 1;
        update(1/frameRate);
      }
    } else {
      update(1/frameRate);
    }
  }
   
  // goal node
  fill(255,250,0);
  circle(allNodes.get(endNode).getPos().x, 
         allNodes.get(endNode).getPos().y, 
         cSpace*5);
  for (int i = 1; i < numNodes-1; i++){
    fill(0,0,0);
    circle(allNodes.get(i).getPos().x, 
           allNodes.get(i).getPos().y, 
           cSpace*2);
  }

  for (int i = 0; i < numNodes; i++){
    for (int j = 0; j < allNodes.get(i).getNeighbors().size(); j++){
      fill(0,0,0);
      strokeWeight(.1);
      stroke(100,100,100);
      line(allNodes.get(i).getPos().x, allNodes.get(i).getPos().y, 
           allNodes.get(allNodes.get(i).getNeighbors().get(j)).getPos().x,
           allNodes.get(allNodes.get(i).getNeighbors().get(j)).getPos().y);
    }
  }
  
  for (int i = 0; i < out.size(); i++){
    fill(0,0,255);
    circle(allNodes.get(out.get(i)).getPos().x,
           allNodes.get(out.get(i)).getPos().y,
           5);
  }
  
}

// update agent position
void update(float dt) {
  // special case for first node
  if (!first) {
    Vec2 dir = allNodes.get(out.get(directionNode)).getPos().minus(allNodes.get(out.get(prevDirectionNode)).getPos());
    dir.normalize();
    
    dir.setToLength(40);
    agent.vel = dir;
    agent.pos.add(agent.vel.times(dt));
  } else {
    Vec2 dir = allNodes.get(out.get(directionNode)).getPos().minus(allNodes.get(prevDirectionNode).getPos());
    dir.normalize();
    
    dir.setToLength(40);
    agent.vel = dir;
    agent.pos.add(agent.vel.times(dt));
  }
}


void keyPressed() {
  if (key == 'r'){ 
    // need to reset all values and undraw current graph config
    allObstacles = new Obstacle[numObs];
    allNodes = new ArrayList<Node>();
    first = true;
    moveAgent = false;
    prevDirectionNode = 0;
    setup();
  }
  if (key == ' '){
   moveAgent = !moveAgent; 
  }
}
