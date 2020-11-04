import java.util.ArrayList; // import the ArrayList class
import javafx.util.Pair;
import java.util.*;  // priority queue

static int MINNEIGHBORS = 20;

// all nodes will be referenced from the allNodes ArrayList. i.e. distance from 4 to 39 is relative to the allNodes index positions

public class Node {
  private Vec2 pos; 
  private ArrayList<Integer> neighborNodes;
  private TupleList distToNeighbors;
  private int numNeighbors;
  private float heuristic;
  private int prevNode;    // represent previous node as it's index in the allNodes array
  private float distFromStart;  // used for UCS will represent total cost from start to node, which is used in comparator of priority queue
  private int index;
  private boolean visited;
  private boolean fringe;
  
  public Node() {
    neighborNodes = new ArrayList<Integer>();
  }
  public Node(Vec2 pos) {
    this.pos = pos;
  }
  
  public Node(float x, float y) {
    pos = new Vec2(-1,-1);
    pos.x = x;
    pos.y = y;
    neighborNodes = new ArrayList<Integer>();
    TupleList distToNeighbors = new TupleList();
    heuristic = -1;
    prevNode = -1;
    distFromStart = -1;
    visited = false;
  }
  
    public Node(float x, float y, int index) {
    pos = new Vec2(-1,-1);
    pos.x = x;
    pos.y = y;
    neighborNodes = new ArrayList<Integer>();
    TupleList distToNeighbors = new TupleList();
    heuristic = -1;
    prevNode = -1;
    distFromStart = -1;
    this.index = index;
    visited = false;
  }
  
  public void setPrevNode(int prev) {
    prevNode = prev;
  }
  
  public int getPrevNode(){
    return prevNode;
  }
  
  public Vec2 getPos(){
    return pos;
  }
  
  public float getHeuristic(){
    return heuristic;
  }
  
  public void setDistFromStart(float dist) {
    if (distFromStart < 0) {
      distFromStart = dist;
    } else {
      distFromStart += dist;
    }
  }
  
  public void resetDistFromStart(float dist) {
    if (distFromStart < 0) {
      distFromStart = dist;
    } else {
      distFromStart = dist;
    }
  }
  
  public float getDistFromStart() {
    return distFromStart;
  }
  
  public int getIndex() {
    return index;
  }
  
  public void setVisited() {
    visited = true;
  }
  
  public boolean getVisited() {
    return visited;
  }
  
  public void setFringe() {
    fringe = true;
  }
  
  public boolean getFringe() {
    return fringe;
  }
  
  // pass index of neighbor
  // should neighbors be represented as their actual nodes or just indexes into allNodes array.
  // neighbors should be represented as arraylist of indexes. All nodes will be referenced from the master allNodes array
  
  // 
  public ArrayList<Integer> getNeighbors() {
    return neighborNodes;
  }
  
  public void setNeighborDist(int neighbor) {  // pass index of neighbor node in allNodes. Will calculate distance and create tuple
    // calculate distance to pass to new tuple of neighbor node and corresponding distance
    float dist = pos.distanceTo((allNodes.get(neighbor).getPos()));
    distToNeighbors.addTuple(neighbor, dist);
  }
  
  // find all neighbors of node
  public ArrayList<Integer> findNeighbors() {
    hitInfo hit = new hitInfo();
    for (int i = 0; i < allNodes.size(); i++){
      if (allNodes.get(i) == this) {continue;} // need to continue when comparing to self
      Node curNode = allNodes.get(i);
      for (int j = 0; j < numObs; j++){
        Obstacle curObs = allObstacles[j];
        Vec2 dir = curNode.getPos().minus(this.pos).normalized();
        float dist = this.pos.distanceTo(curNode.getPos());
        hit = rayCircleIntersect(curObs.getPos(),
                                 curObs.getRad(),
                                 this.pos,
                                 dir,
                                 dist);
        if (hit.hit) {break;}
                                 
      }
      if (!hit.hit) {
        neighborNodes.add(i);
      }
    }
    
    return neighborNodes;
  }
  
  
}


////////////////////////////////////////////////////////////////
// =================== Node Priority Queue ===================//
////////////////////////////////////////////////////////////////
// lowest value get priority
public class NodeComparator implements Comparator<Node> {
  public int compare(Node n1, Node n2) {
    if (n1.getDistFromStart() > n2.getDistFromStart()) {
      return 1;
    } else {return -1;}
  }
}

//////////////////////////////////////////////////////////////////////////////
// ========================= Extra Node Functions ========================= //
//////////////////////////////////////////////////////////////////////////////
// Generate random nodes function
// ! will either place nodes inside or outside of obs
// get working with random outside placements. Then work on a function which brings them to the edge of obstacles, allowing nearly optimal paths
public ArrayList<Node> generateRandomNodes(int nodes, ArrayList<Node> list) {
  for (int i = 0; i < nodes; i++){
    Node randNode = new Node(random(1080) + 1, random(720) + 1, i);
    boolean nodesIntersect = checkNodeNodeCollision(list, randNode);
    while (checkObsCollision(allObstacles, randNode) || nodesIntersect) {
      randNode = new Node(random(1078) + 1, random(718) + 1, i);
      nodesIntersect = checkNodeNodeCollision(list, randNode);
    }
    list.add(randNode);
  }
  return list;
}

// Check for collisions with obstacles

public boolean checkObsCollision(Obstacle obslist[], Node point) {
  for (int i = 0; i < numObs; i++){
    float dist = point.getPos().distanceTo((obslist[i].getPos()));
    if (dist < (obslist[i].getRad() + cSpace)){
      return true;
    }
  }
  return false;
}

// Check for proximity to other nodes
// should not be too close to other nodes/intersect with them

public boolean checkNodeNodeCollision(ArrayList<Node> nodelist, Node newNode) {
  for (int i = 0; i < nodelist.size(); i++){
    float dist = newNode.getPos().distanceTo(nodelist.get(i).getPos());
    if (dist < 2*cSpace + minNodeDist) {
      return true;
    }
  }
  return false;
}


// Generate all neighbors
public void generateAllNeighbors() {
  for (int i = 0; i < numNodes; i++){
    allNodes.get(i).findNeighbors();
  }
}
