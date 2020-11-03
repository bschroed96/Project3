public class Agent {
  public Vec2 pos;
  public Vec2 vel;
  public Vec2 acc;
  public int rad;
  
  public Agent(Vec2 pos) {
    this.pos = pos;
    vel = new Vec2(0,0);
    acc = new Vec2(0,0);
  }
  
  
}
