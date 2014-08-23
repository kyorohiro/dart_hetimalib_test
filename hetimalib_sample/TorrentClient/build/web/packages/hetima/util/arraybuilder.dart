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

  void appendByte(int v) {
    update(1);
    _buffer8[_length] = v;
    _length += 1;    
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

  void appendIntList(List<int> buffer, int index, int length) {
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
  
  static final int BYTEORDER_BIG_ENDIAN = 1;
  static final int BYTEORDER_LITTLE_ENDIAN = 0;

  static List<int> parseLongByte(int value, int byteorder) {
    List<int> ret = new List(8);
    if(byteorder == BYTEORDER_BIG_ENDIAN) {
      ret[0] = (value>>56&0xff);
      ret[1] = (value>>48&0xff);
      ret[2] = (value>>40&0xff);
      ret[3] = (value>>32&0xff);
      ret[4] = (value>>24&0xff);
      ret[5] = (value>>16&0xff);
      ret[6] = (value>> 8&0xff);
      ret[7] = (value>> 0&0xff);
    } else {
      ret[0] = (value>> 0&0xff);
      ret[1] = (value>> 8&0xff);
      ret[2] = (value>>16&0xff);
      ret[3] = (value>>24&0xff);
      ret[4] = (value>>32&0xff);
      ret[5] = (value>>40&0xff);
      ret[6] = (value>>48&0xff);
      ret[7] = (value>>56&0xff);
   }
    return ret;
  }

  static List<int> parseIntByte(int value, int byteorder) {
    List<int> ret = new List(4);
    if(byteorder == BYTEORDER_BIG_ENDIAN) {
      ret[0] = (value>>24&0xff);
      ret[1] = (value>>16&0xff);
      ret[2] = (value>> 8&0xff);
      ret[3] = (value>> 0&0xff);
    } else {
      ret[0] = (value>> 0&0xff);
      ret[1] = (value>> 8&0xff);
      ret[2] = (value>>16&0xff);
      ret[3] = (value>>24&0xff);      
    }
    return ret;
  }

  static List<int> parseShortByte(int value, int byteorder) {
    List<int> ret = new List(4);
    if(byteorder == BYTEORDER_BIG_ENDIAN) {
      ret[0] = (value>>8&0xff);
      ret[1] = (value>>0&0xff);
    } else {
      ret[0] = (value>> 0&0xff);
      ret[1] = (value>> 8&0xff);
    }
    return ret;
  }

  static int parseShort(List<int> value, int start, int byteorder) {
     int ret = 0;
     if(byteorder == BYTEORDER_BIG_ENDIAN) {
       ret = ret | ((value[0+start]&0xff)<<8);
       ret = ret | ((value[1+start]&0xff)<<0);
     } else {
       ret = ret | ((value[1+start]&0xff)<<8);
       ret = ret | ((value[0+start]&0xff)<<0);
     }
     return ret;
   }
  static int parseInt(List<int> value, int start, int byteorder) {
     int ret = 0;
     if(byteorder == BYTEORDER_BIG_ENDIAN) {
       ret = ret | ((value[0+start]&0xff)<<24);
       ret = ret | ((value[1+start]&0xff)<<16);
       ret = ret | ((value[2+start]&0xff)<<8);
       ret = ret | ((value[3+start]&0xff)<<0);
     } else {
       ret = ret | ((value[3+start]&0xff)<<24);
       ret = ret | ((value[2+start]&0xff)<<16);
       ret = ret | ((value[1+start]&0xff)<<8);
       ret = ret | ((value[0+start]&0xff)<<0);
     }
     return ret;
   }
  static int parseLong(List<int> value, int start, int byteorder) {
     int ret = 0;
     if(byteorder == BYTEORDER_BIG_ENDIAN) {
       ret = ret | ((value[0+start]&0xff)<<56);
       ret = ret | ((value[1+start]&0xff)<<48);
       ret = ret | ((value[2+start]&0xff)<<40);
       ret = ret | ((value[3+start]&0xff)<<32);
       ret = ret | ((value[4+start]&0xff)<<24);
       ret = ret | ((value[5+start]&0xff)<<16);
       ret = ret | ((value[6+start]&0xff)<<8);
       ret = ret | ((value[7+start]&0xff)<<0);
     } else {
       ret = ret | ((value[7+start]&0xff)<<56);
       ret = ret | ((value[6+start]&0xff)<<48);
       ret = ret | ((value[5+start]&0xff)<<40);
       ret = ret | ((value[4+start]&0xff)<<32);
       ret = ret | ((value[3+start]&0xff)<<24);
       ret = ret | ((value[2+start]&0xff)<<16);
       ret = ret | ((value[1+start]&0xff)<<8);
       ret = ret | ((value[0+start]&0xff)<<0);
     }
     return ret;
   }

}
