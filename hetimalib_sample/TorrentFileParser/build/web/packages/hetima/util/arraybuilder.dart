part of hetima;

class ArrayBuilder {
  int _max = 1024;
  data.Uint8List _buffer8;
  int _length = 0;

  ArrayBuilder() {
    _buffer8 = new data.Uint8List(_max);
  }
  void clear() {
    _length = 0;
  }

  int size() {
    return _length;
  }

  void update(int plusLength) {
    if (_length+plusLength<_max) {
      return;   
    } else {
      int nextMax = _length+plusLength+_max;
      data.Uint8List next = new data.Uint8List(nextMax);
      for(int i=0;i<_length;i++) {
        next[i] = _buffer8[i];
      }
     // _buffer8.clear();
      _buffer8 = null;
      _buffer8 = next;
      _max = nextMax;
    }
  }
  void appendString(String text) {
    List<int> code = convert.UTF8.encode(text);
    update(code.length);
    for (int i = 0; i < code.length; i++) {
      _buffer8[_length] = code[i];
      _length += 1;
    }
  }

  void appendUint8List(data.Uint8List buffer, int index, int length) {
    update(length);
    for (int i = 0; i < length; i++) {
      _buffer8[_length] = buffer[index + i];
      _length += 1;
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
