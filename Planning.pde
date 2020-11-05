import java.util.*;  // priority queue


// Obstacles
static int maxObs = 100;
int numObs = 50;
Obstacle allObstacles[] = new Obstacle[numObs];

// Nodes
static float cSpace = 10;
static int numNodes = 100;
static int minNodeDist = 5;
ArrayList<Node> allNodes = new ArrayList<Node>();
PriorityQueue<Node> fringe;
int nodeRad = 2;

// path planning
ArrayList<Integer> out;
int startNode = 1;
int endNode = 4;
int prevDirectionNode = startNode;
int directionNode = -1; // used as the node to direct agent if -1, we didn't find a path
boolean first = true;
ArrayList<ArrayList<Integer>> paths = new ArrayList<ArrayList<Integer>>(); // array of arrays. The arrays represent solutions

// Agent info
boolean moveAgent = false; // for starting agent to move along path
Agent agent; 
ArrayList<Agent> agents;

// Multi Agent global data
ArrayList<Integer> dirNode = new ArrayList<Integer>();
ArrayList<Integer> preDirNode = new ArrayList<Integer>();
ArrayList<Agent> a = new ArrayList<Agent>();
ArrayList<Boolean> firsts = new ArrayList<Boolean>();
ArrayList<Integer> startNodes = new ArrayList<Integer>();
ArrayList<Integer> endNodes = new ArrayList<Integer>();


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
  
  //// Run uniform cost search
  //out = UniformCostSearch(startNode, endNode);
  //print(out);
  
  //// Run Uniform cost search and save to list of paths
  //paths.add(out);
  //dirNode.add(0);
  //a.add(new Agent(new Vec2 (allNodes.get(startNode).getPos().x, allNodes.get(startNode).getPos().y)));
  //firsts.add(true);
  startNodes.add(startNode);
  endNodes.add(endNode);
  addAgent(startNode, endNode);
  
}

public void addAgent(int start, int end){
  ArrayList<Integer> pOut = new ArrayList<Integer>();
  pOut = UniformCostSearch(start, end);
    // reset sim if no solution on graph was found
    
    //for (int i = 0; i < paths.size(); i++){
    //  if (paths.get(i).get(0) < 0){
    //    println("invalid Solution");
    //    reset();
    //  }
    //}
    
    if (pOut.get(0) < 0) {
      println("no Solution found for new agent. Try again.");
      println("pOut was : " + pOut);
      // just make new graph if no solution
      int ind = startNodes.size() - 1; // get last element in list and try new node
      int s = (int)random(numNodes-1)+0;
      int e = (int)random(numNodes-1)+0;
      while (s == e) {
        s = (int)random(numNodes-1)+0;
        e = (int)random(numNodes-1)+0;
      }
      startNodes.set(ind, s);
      endNodes.set(ind, e);
      addAgent(s, e);
    } else {
        paths.add(pOut);
        print(paths);
        dirNode.add(0);
        a.add(new Agent(new Vec2 (allNodes.get(start).getPos().x, allNodes.get(start).getPos().y)));
        firsts.add(true);
    }
}

void draw() {
  background(200);
  for(int i = 0; i < numObs; i++) {
    fill(0,0,0);
    circle(allObstacles[i].getPos().x, 
           allObstacles[i].getPos().y, 
           allObstacles[i].getRad()*2 - 2*cSpace);
  }
  // Start node
  fill(0,255,255);
  circle(allNodes.get(startNode).getPos().x, 
         allNodes.get(startNode).getPos().y, 
         cSpace*2);
  
  for (int i = 0; i < a.size(); i++) {
    fill(255);
    circle(a.get(i).pos.x, a.get(i).pos.y, 10*2);
  }
  
  if (moveAgent) {
    for (int i = 0; i < startNodes.size(); i++){
      moveAgents(i);
    }
  }
  //if (moveAgent) {
  //  if (agent.pos.distanceTo(allNodes.get(out.get(directionNode)).getPos()) < 1) {
  //    if (directionNode >= out.size() - 1) {}// dont update pos we are at goal
  //    else {
  //      first = false;
  //      prevDirectionNode = directionNode;
  //      directionNode += 1;
  //      update(1/frameRate);
  //    }
  //  } else {
  //    update(1/frameRate);
  //  }
  //}
   
  // goal node
  for (int i = 0; i < endNodes.size(); i++){
    fill(255,250,0);
    circle(allNodes.get(endNodes.get(i)).getPos().x, 
           allNodes.get(endNodes.get(i)).getPos().y, 
           cSpace*2);
  }
         
  //// render all nodes
  //for (int i = 1; i < numNodes-1; i++){
  //  fill(0,0,0);
  //  circle(allNodes.get(i).getPos().x, 
  //         allNodes.get(i).getPos().y, 
  //         nodeRad*2);
  //}
  
  //// render all edges
  //for (int i = 0; i < numNodes; i++){
  //  for (int j = 0; j < allNodes.get(i).getNeighbors().size(); j++){
  //    fill(0,0,0);
  //    strokeWeight(.1);
  //    stroke(100,100,100);
  //    line(allNodes.get(i).getPos().x, allNodes.get(i).getPos().y, 
  //         allNodes.get(allNodes.get(i).getNeighbors().get(j)).getPos().x,
  //         allNodes.get(allNodes.get(i).getNeighbors().get(j)).getPos().y);
  //  }
  //}
  
  //// reset sim if no solution on graph was found
  //  if (out.get(0) < 0) {
  //    println("no Solution found");
  //    // just make new graph if no solution
  //    reset();
  //  }
  // render solution path nodes
  //for (int i = 0; i < out.size(); i++){
  //  fill(0,0,255);
  //  circle(allNodes.get(out.get(i)).getPos().x,
  //         allNodes.get(out.get(i)).getPos().y,
  //         5);
  //}
  
}

// generalized version wihch will update a specific agent based on local data passed, not global data
void moveAgents(int index){
  //println(a.get(index).pos);
  //println(paths.get(index));
  //println(paths);
  //println(allNodes.get(paths.get(index).get(0)));
    if (a.get(index).pos.distanceTo(allNodes.get(paths.get(index).get(dirNode.get(index))).getPos()) < 1) {
      if (dirNode.get(index) >= paths.get(index).size() - 1) {}// dont update pos we are at goal
      else {
        firsts.set(index, false);
        if (preDirNode.size() <= 0) {
          preDirNode.add(dirNode.get(index));
        } else {
          preDirNode.set(index, dirNode.get(index));
        }
        dirNode.set(index, dirNode.get(index) + 1);
        updateAgent(1/frameRate, index, paths.get(index));
      }
    } else {
      updateAgent(1/frameRate, index, paths.get(index));
    }
}
    
// dirNode and preDirNode need to be kept in arrays to hold updated values
// if path, dirNode, preDirNode, a, and firsts are globals, don't need to pass to func. only index and dt
// path needs to be paths.get(index)
void updateAgent(float dt, int index, ArrayList<Integer> path) { // index of which agent we are updating
  hitInfo intersect = new hitInfo();
  int indexOfFurthestPathNode = -1;
  for (int i = 0; i < path.size(); i++){
    intersect = agentIntersectsObs(a.get(index), path.get(i));
    if (!intersect.hit) {
      indexOfFurthestPathNode = i;  // highest i value represents the furthest index of path node which can be reached from current agent position
    }
  }
  
  //worst case, we need to completely reach the path at index i. So, we can set the prevDirectioNode to i, and directionNode to i + 1
  if (indexOfFurthestPathNode >= 0) {
    dirNode.set(index, indexOfFurthestPathNode);
    Vec2 dir = allNodes.get(path.get(dirNode.get(index))).getPos().minus(a.get(index).pos);
    dir.normalize();
    
    dir.setToLength(40);
    a.get(index).vel = dir;
    a.get(index).pos.add(a.get(index).vel.times(dt));
  }
  
  // special case for first node
  else if (!firsts.get(index)) {
    
    Vec2 dir = allNodes.get(path.get(dirNode.get(index))).getPos().minus(allNodes.get(path.get(preDirNode.get(index))).getPos());
    dir.normalize();
    
    dir.setToLength(40);
    a.get(index).vel = dir;
    a.get(index).pos.add(a.get(index).vel.times(dt));
  } else {
    
    Vec2 dir = allNodes.get(path.get(dirNode.get(index))).getPos().minus(allNodes.get(preDirNode.get(index)).getPos());
    dir.normalize();
    
    dir.setToLength(40);
    a.get(index).vel = dir;
    a.get(index).pos.add(a.get(index).vel.times(dt));
  }
}

// update agent position
void update(float dt) {
  hitInfo intersect = new hitInfo();
  int indexOfFurthestPathNode = -1;
  for (int i = 0; i < out.size(); i++){
    intersect = agentIntersectsObs(agent, out.get(i));
    if (!intersect.hit) {
      indexOfFurthestPathNode = i;  // highest i value represents the furthest index of path node which can be reached from current agent position
    }
  }
  
  //worst case, we need to completely reach the path at index i. So, we can set the prevDirectioNode to i, and directionNode to i + 1
  if (indexOfFurthestPathNode >= 0) {
    directionNode = indexOfFurthestPathNode;
    Vec2 dir = allNodes.get(out.get(directionNode)).getPos().minus(agent.pos);
    dir.normalize();
    
    dir.setToLength(40);
    agent.vel = dir;
    agent.pos.add(agent.vel.times(dt));
  }
  
  // special case for first node
  else if (!first) {
    
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
    reset();
  }
  if (key == ' '){
   moveAgent = !moveAgent; 
  }
  
  if (key == 'a') {
    int start = (int)random(numNodes-1)+1;
    int end = (int)random(numNodes-2)+3;
    startNodes.add(start);
    endNodes.add(end);
    addAgent(start, end);
  }
}

public hitInfo agentIntersectsObs(Agent agent, int nextNode){
  Vec2 dir = allNodes.get(nextNode).getPos().minus(agent.pos);
  float dist = allNodes.get(nextNode).getPos().distanceTo(agent.pos);
  dir.normalize();
  hitInfo stillIntersects = new hitInfo();
  
  for (int i = 0; i < numObs; i++){
    stillIntersects = rayCircleIntersect(allObstacles[i].getPos(),
                       allObstacles[i].getRad(),
                       agent.pos,
                       dir,
                       dist);
    if (stillIntersects.hit){break;}
  }
  return stillIntersects;
}

public void reset() {
      // need to reset all values and undraw current graph config
    allObstacles = new Obstacle[numObs];
    allNodes = new ArrayList<Node>();
    
    // reset all list items
    dirNode = new ArrayList<Integer>();
    preDirNode = new ArrayList<Integer>();
    a = new ArrayList<Agent>();
    firsts = new ArrayList<Boolean>();
    paths = new ArrayList<ArrayList<Integer>>();
    moveAgent = false;
    startNodes = new ArrayList<Integer>();
    endNodes= new ArrayList<Integer>();
    setup();
}
