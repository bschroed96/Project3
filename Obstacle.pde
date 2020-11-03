public class Obstacle {
  private Vec2 pos;
  private float rad;
  
  public Obstacle() {
    pos = new Vec2(random(1080 - rad*2 - 10)+1, random(720 - rad - 10)+1);
    rad = random(50) + 10;
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
    allObstacles[i] = new Obstacle();
  }
  Obstacle newObs = new Obstacle();
  for (int i = 0; i < numObs; i++) {
    while (checkObsObsCollision(allObstacles, newObs)) {
      newObs = new Obstacle();
    }
    allObstacles[i] = newObs;
  }
}

public boolean checkObsObsCollision(Obstacle obslist[], Obstacle obs) {
  for (int i = 0; i < numObs; i++){
    float dist = obs.getPos().distanceTo((obslist[i].getPos()));
    if (dist < (obslist[i].getRad() + obs.getRad())){
      return true;
    }
  }
  return false;
}
