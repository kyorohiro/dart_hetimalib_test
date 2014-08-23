part of hetima;

class ArrayBuilder extends HetimaBuilder {
  int _max = 1024;
  data.Uint8List _buffer8;
  int _length = 0;

  async.Completer completer = new async.Completer();
  List<int> completerResult = null;
  int completerResultLength = 0;

  ArrayBuilder() {
    _buffer8 = new data.Uint8List(_max);
  }

  async.Future<List<int>> getByteFuture(int index, int length) {
    completerResult = new List();
    completerResultLength = length;

    if (completer.isCompleted) {
      completer = new async.Completer();
    }

    int v = index;
    for (index; index < size() && index < (length + v); index++) {
      completerResult.add(get(index));
    }


    if ((completerResultLength <= completerResult.length)||(immutable)) {
      completer.complete(completerResult);
      completerResult = null;
      completerResultLength = 0;
    }

    return completer.future;
  }

  int get(int index) {
    return 0xFF & _buffer8[index];
  }

  void clear() {
    _length = 0;
  }

  int size() {
    return _length;    
  }

  async.Future<int> getLength() {
    async.Completer<int> completer = new async.Completer();
    completer.complete(_length);
    return completer.future;
  }

  void update(int plusLength) {
    if (_length + plusLength < _max) {
      return;
    } else {
      int nextMax = _length + plusLength + _max;
      data.Uint8List next = new data.Uint8List(nextMax);
      for (int i = 0; i < _length; i++) {
        next[i] = _buffer8[i];
      }
      // _buffer8.clear();
      _buffer8 = null;
      _buffer8 = next;
      _max = nextMax;
    }
  }

  void fin() {
    if (completerResult != null) {
      completer.complete(completerResult);
      completerResult = null;
      completerResultLength = 0;
    }
    immutable = true;
  }

  void appendByte(int v) {
    if(immutable) {
      return;
    }
    update(1);
    _buffer8[_length] = v;
    _length += 1;

    if (!completer.isCompleted && completerResult != null) {
      completerResult.add(v);
    }

    if (completerResult != null && completerResultLength <= completerResult.length) {
      completer.complete(completerResult);
      completerResult = null;
      completerResultLength = 0;
    }
  }

  void appendString(String text) {
    List<int> code = convert.UTF8.encode(text);
    update(code.length);
    for (int i = 0; i < code.length; i++) {
      appendByte(code[i]);
    }
  }

  void appendUint8List(data.Uint8List buffer, int index, int length) {
    update(length);
    for (int i = 0; i < length; i++) {
      appendByte(buffer[index + i]);
    }
  }

  void appendIntList(List<int> buffer, int index, int length) {
    update(length);
    for (int i = 0; i < length; i++) {
      appendByte(buffer[index + i]);
    }
  }

  List toList() {
    return _buffer8.sublist(0, _length);
  }

  data.Uint8List toUint8List() {
    return new data.Uint8List.fromList(toList());
  }

  String toText() {
    return convert.UTF8.decode(toList());
  }

}
