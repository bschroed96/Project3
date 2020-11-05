// returns a list of the nodes in order of traversal needed to go from start to goal.
// uses the previousNode structure in Node class

public ArrayList<Integer> UniformCostSearch(int startNode, int goalNode) {
  fringe = new PriorityQueue<Node> (10, new NodeComparator());
  
  // The start node has no previous node
  allNodes.get(startNode).setPrevNode(-2);
  int prevNode = startNode;
  Node curNode =  allNodes.get(startNode);

  // just for first add to fringe unroll loop
  for (int i = 0; i < curNode.getNeighbors().size(); i++){
    int neighborIndex = curNode.getNeighbors().get(i);

    // distance from the start node to neighbor node. This will determine which is minimal
    float dist = curNode.getPos().distanceTo(allNodes.get(neighborIndex).getPos());
    allNodes.get(neighborIndex).setDistFromStart(dist);  
   
    allNodes.get(neighborIndex).setFringe();      // set to be in fringe. If it is in the fringe, we don't want to try and update it's value later
    // if we add something to the fringe, we need to set the previous node. i.e. if we are at node 1 and have neighbor 2, neighbor 2 needs to have prevNode =1 before going into fringe.
    allNodes.get(neighborIndex).setPrevNode(startNode);
    fringe.add(allNodes.get(neighborIndex));
  }
  
  
  // the start node has been visited.
  allNodes.get(startNode).setVisited();
  
  // explore minimal item in fringe set
  while (fringe.size() > 0) {
    // print("exploring next node");
    curNode = fringe.poll();
    
    // pull from fringe means we visited node.
    allNodes.get(curNode.getIndex()).setVisited();
    
    if (curNode.getIndex() == goalNode) {
      break;
    }
      
    for (int i = 0; i < curNode.getNeighbors().size(); i++){
      int neighborIndex = curNode.getNeighbors().get(i);
        
      // distance from the start node to neighbor node. This will determine which is minimal
      float dist = curNode.getPos().distanceTo(allNodes.get(neighborIndex).getPos());
        
      // get current distance from start, which is needed to create total distance
      float curDist = curNode.getDistFromStart();
        
      // check if visited, if the updated new cost is lower, replace value ALSO if it is already in the fringe, don't want to double update val
      if (allNodes.get(neighborIndex).getVisited() || allNodes.get(neighborIndex).getFringe()) { 
        if (allNodes.get(neighborIndex).getDistFromStart() > (dist + curDist)){
          allNodes.get(neighborIndex).setPrevNode(curNode.getIndex());
          allNodes.get(neighborIndex).resetDistFromStart(dist + curDist);
        }
        continue; 
      }

      allNodes.get(neighborIndex).setDistFromStart(dist + curDist);
      prevNode = curNode.getIndex();  
      allNodes.get(neighborIndex).setPrevNode(prevNode);  // sets to previous node

      allNodes.get(neighborIndex).setFringe();
      fringe.add(allNodes.get(neighborIndex));
      
    }
  }
  
  ArrayList<Integer> path = new ArrayList<Integer>();
  // fail to find path return -1
  if (curNode.getIndex() != goalNode) {
    path.add(-1);
    return path;
  } else {
  
  //for (int i = 0; i < numNodes; i++){
  //  print("node " + allNodes.get(i).getIndex() + " has a previous node of " + allNodes.get(i).getPrevNode() + "\n");
  //}
  
  while(allNodes.get(curNode.getIndex()).getPrevNode() != -2) {
    path.add(curNode.getIndex());
    curNode = allNodes.get(curNode.getPrevNode());
    // resolves cases where paths become much too long/looping in graph. Not sure why...
    if (path.size() > numNodes - 1){
      path = new ArrayList<Integer>();
      path.add(-2);
      return path;
    }
  }
  // reverse path order
  ArrayList<Integer> finalPath= new ArrayList<Integer>();
  for (int i = path.size() -1; i >= 0; i--){
    finalPath.add(path.get(i));
  }
  return finalPath;
  }
}
