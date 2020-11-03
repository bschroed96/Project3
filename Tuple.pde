public class Tuple {
  private int key;
  private float value;
  
  public Tuple(){
    key = -1;
    value = -1;
  }
  
  public Tuple(int key) {
    this.key = key;
  }
  
  public Tuple(int key, float value) {
    this.key = key;
    this.value = value;
  }
  
  public int getKey() {
    return key;
  }
  
  public float getValue() {
    return value;
  }
}

public class TupleList {
  private ArrayList<Tuple> tupleList;
  
  public TupleList() {
    tupleList = new ArrayList<Tuple>();
  }
  
  public void addTuple(int key, float val) {
    tupleList.add(new Tuple(key, val));
  }
  
  public void updateVal(int key, float newVal) {
    for (int i = 0; i < tupleList.size(); i++){
      if (tupleList.get(i).getKey() == key) {
        tupleList.set(i, new Tuple(key, newVal));
      }
    }
  }
  
  // returns -1 if key DNE
  public float getVal(int key) {
    for (int i = 0; i < tupleList.size(); i++) {
      if (tupleList.get(i).getKey() == key) {
        return tupleList.get(i).getValue();
      }
    }
    return -1;
  }
}
