part of hetima;

class ShuffleLinkedList<X>
{
  List<X> _sequential = new List();
  List<X> _shuffled = new List();

  void addLast(X value) {
    if(_sequential.contains(value)){
      return;
    }
    _sequential.add(value);
    _shuffled.add(value);
  }

  void removeHead() {
    if(_sequential.length <=0) {
      return;
    }
    X value = _sequential.removeAt(0);
    _shuffled.remove(value);
  }

  void shuffle() {
    List<X> items = _shuffled;
    var random = new math.Random();
    for (int i = 0; i < items.length; i++) {
      int n = random.nextInt(items.length);
      Object temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
  }

  int get length => _sequential.length;
  X getShuffled(int index) {
    return _shuffled[index];
  }

  X getSequential(int index) {
    return _sequential[index];
  }
}