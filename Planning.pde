import java.util.*;  // priority queue


// Obstacles
static int maxObs = 100;
int numObs = 50;
Obstacle allObstacles[] = new Obstacle[numObs];
ArrayList<Obstacle> allObs = new ArrayList<Obstacle>();

// Nodes
static float cSpace = 10;
static int numNodes = 10;
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

// booleans for environemtn control
boolean addOb = false;
boolean addAg = false;
int numClicks = 0; // This is for adding agents, first click is agent, second click is new goal. 
Vec2 startEndPos[] = new Vec2[2];

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
  
  startNodes.add(startNode);
  endNodes.add(endNode);
  addAgent(startNode, endNode);
  
}

void draw() {
  background(200);
  for(int i = 0; i < numObs; i++) {
    fill(0,0,0);
    circle(allObs.get(i).getPos().x, 
           allObs.get(i).getPos().y, 
           allObs.get(i).getRad()*2 - 2*cSpace);
  }
  
  for (int i = 0; i < a.size(); i++) {
    fill(255);
    circle(a.get(i).pos.x, a.get(i).pos.y, 10*2);
  }
  
  if (moveAgent) {
    for (int i = 0; i < startNodes.size(); i++){
      moveAgents(i);
    }
  }
   
  // goal node
  for (int i = 0; i < endNodes.size(); i++){
    fill(255,250,0);
    circle(allNodes.get(endNodes.get(i)).getPos().x, 
           allNodes.get(endNodes.get(i)).getPos().y, 
           cSpace*2);
  }
  
  // renderNodes();
  renderEdges();
  //renderSolution();
}

void renderEdges() {
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
}

void renderSolution() {
  // render solution path nodes
  for (int i = 0; i < out.size(); i++){
    fill(0,0,255);
    circle(allNodes.get(out.get(i)).getPos().x,
           allNodes.get(out.get(i)).getPos().y,
           5);
  }  
}

void renderNodes() {
  for (int i = 1; i < numNodes-1; i++){
    fill(0,0,0);
    circle(allNodes.get(i).getPos().x, 
           allNodes.get(i).getPos().y, 
           nodeRad*2);
  }
}

void mousePressed() {
   if (addOb) {
     float x = mouseX;
     float y = mouseY;
     addObstacle(x,y);
    
     resetAllNeighbors();
     generateAllNeighbors();
     updateAgentPaths();
   }
   
   if (addAg && numClicks < 2) {
     float x = mouseX;
     float y = mouseY;
     int start = -1;
     int end = -1;
     //addNode(x,y);
     if (numClicks == 0) { // add start position to array
       startEndPos[numClicks] = new Vec2(x,y);
       numClicks += 1;
     } else if (numClicks == 1) { // add end position to array
         startEndPos[numClicks] = new Vec2(x,y);
         
         addNode(startEndPos[0].x, startEndPos[0].y); // create new nodes for start and goal
         addNode(startEndPos[1].x, startEndPos[1].y);
         start = allNodes.size() - 2;
         end = allNodes.size() - 1;
         startNodes.add(start);
         endNodes.add(end);
         resetAllNeighbors();
         generateAllNeighbors();
         //updateAgentPaths();
      
         numClicks = 0;
         
         ArrayList<Integer> pOut = new ArrayList<Integer>(); ///////// path isn't being calcualted right when two /////////////
         println("start is : " + start + " end is : " + end);
         
         pOut = UniformCostSearch(start, end);
         println("added path" +pOut);
         
        if (pOut.get(0) < 0) 
        {
          println("no solution found, pick new points");
          startNodes.remove(startNodes.size()-1);
          endNodes.remove(endNodes.size()-1);
        } 
        else 
        {
          paths.add(pOut);
          print(paths);
          dirNode.add(0);
          a.add(new Agent(new Vec2 (startEndPos[0].x, startEndPos[0].y)));
          firsts.add(true);
        }
        
     }
   } 
}


void keyPressed() {
  if (key == 'r'){ 
    reset();
  }
  if (key == ' '){
   moveAgent = !moveAgent; 
  }
  
  if (key == 'o') {
    addOb = !addOb;
    addAg = false;
  }
  
  if (key == 'i') {
    addAg = !addAg;
    addOb = false;
  }
  
  if (key == 'a') {
    int start = (int)random(numNodes-1)+1;
    int end = (int)random(numNodes-2)+3;
    startNodes.add(start);
    endNodes.add(end);
    addAgent(start, end);
  }
}

public void reset() {
      // need to reset all values and undraw current graph config
    allObstacles = new Obstacle[numObs];
    allObs = new ArrayList<Obstacle>();// reset 
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
