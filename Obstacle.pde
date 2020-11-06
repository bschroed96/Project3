public class Obstacle {
  private Vec2 pos;
  private float rad;
  
  public Obstacle() {
    pos = new Vec2(random(1080 - rad*2 - 10)+1, random(720 - rad - 10)+1);
    rad = random(70) + 20;
  }
  
  public Obstacle(float x, float y) {
    pos = new Vec2(x, y);
    rad = 30;
  }
  
  public Vec2 getPos() {
    return pos;
  }
  
  public float getRad() {
    return rad;
  }
}

public void generateRandomObs() {
  for (int i = 0; i < numObs; i++){
    //allObstacles[i] = new Obstacle();
    allObs.add(new Obstacle());    // New arraylist conversion
  }
  Obstacle newObs = new Obstacle();
  for (int i = 0; i < numObs; i++) {
    while (checkObsObsCollision(allObs, newObs)) {
      newObs = new Obstacle();
    }
    allObs.set(i, newObs);
  }
}

public boolean checkObsObsCollision(ArrayList<Obstacle> obslist, Obstacle obs) {
  for (int i = 0; i < numObs; i++){
    float dist = obs.getPos().distanceTo((obslist.get(i).getPos()));
    if (dist < (obslist.get(i).getRad() + obs.getRad())){
      return true;
    }
  }
  return false;
}

public void addObstacle(float x, float y) {
  allObs.add(new Obstacle(x,y));
  numObs += 1;
  generateAllNeighbors();
}
