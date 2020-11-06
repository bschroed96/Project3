public class Agent {
  public Vec2 pos;
  public Vec2 vel;
  public Vec2 acc;
  public int rad;
  public Node node;
  
  public Agent(Vec2 pos) {
    this.pos = pos;
    vel = new Vec2(0,0);
    acc = new Vec2(0,0);
    node = new Node(this.pos);
  }
}

public boolean agentAgentCollision(Agent a1, Agent a2) { // pass index so we don't compare to self
  return (a1.pos.distanceTo(a2.pos) < cSpace*2);
}

public void addAgent(int start, int end){
  ArrayList<Integer> pOut = new ArrayList<Integer>();
  pOut = UniformCostSearch(start, end);
    // reset sim if no solution on graph was found
    
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
        println("the prevDirNode size in add agent is: " + preDirNode.size());
        dirNode.add(0);
        a.add(new Agent(new Vec2 (allNodes.get(start).getPos().x, allNodes.get(start).getPos().y)));
        firsts.add(true);
    }
}

public void updateAgentPaths() {
  ArrayList<Integer> pOut = new ArrayList<Integer>();
  for (int i = 0; i < startNodes.size(); i++){
    pOut = UniformCostSearch(startNodes.get(i), endNodes.get(i));
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
        paths.set(i, pOut);
        //print(paths);
        dirNode.set(i, 0);
    }
  }
}


public hitInfo agentIntersectsObs(Agent agent, int nextNode){
  Vec2 dir = allNodes.get(nextNode).getPos().minus(agent.pos);
  float dist = allNodes.get(nextNode).getPos().distanceTo(agent.pos);
  dir.normalize();
  hitInfo stillIntersects = new hitInfo();
  
  for (int i = 0; i < numObs; i++){
    stillIntersects = rayCircleIntersect(allObs.get(i).getPos(),
                       allObs.get(i).getRad(),
                       agent.pos,
                       dir,
                       dist);
    if (stillIntersects.hit){break;}
  }
  return stillIntersects;
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
    //println("The first case is being used");
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
  } 
}

// generalized version wihch will update a specific agent based on local data passed, not global data
void moveAgents(int index){
    
    // to avoid another agent, set temporary velocity to cspace vector avoiding agent

    if (a.get(index).pos.distanceTo(allNodes.get(paths.get(index).get(dirNode.get(index))).getPos()) < 1) {
      if (dirNode.get(index) >= paths.get(index).size() - 1) {}// dont update pos we are at goal
      else {
        firsts.set(index, false);
        if (preDirNode.size() <= 0) {
          println("adding to predirnode " );
          preDirNode.add(dirNode.get(index));
        } else {
          preDirNode.set(index, dirNode.get(index));
        }
        dirNode.set(index, dirNode.get(index) + 1);
        updateAgent(1/frameRate, index, paths.get(index));
      }
    } else {
      //println("going to else statemtn");
      updateAgent(1/frameRate, index, paths.get(index));
    }
}
   
