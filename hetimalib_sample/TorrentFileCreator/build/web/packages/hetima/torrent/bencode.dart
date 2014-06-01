part of hetima;

class Bencode 
{
  static Bencoder _encoder = new Bencoder();
  static Bdecoder _decoder = new Bdecoder();

  static data.Uint8List encode(Object obj) 
  {
     return _encoder.enode(obj);
  }

  static Object decode(data.Uint8List buffer) 
  {
    return _decoder.decode(buffer);
  }
}

class Bdecoder {
  int index;
  Object decode(data.Uint8List buffer) 
  {
    index = 0;
    return decodeBenObject(buffer);
  }

  Object decodeBenObject(data.Uint8List buffer) { 
    if( 0x30 <= buffer[index] && buffer[index]<=0x39) {//0-9
      return decodeBytes(buffer);
    } else if(0x69 == buffer[index]) {// i 
      return decodeNumber(buffer);
    } else if(0x6c == buffer[index]) {// l
      return decodeList(buffer);
    } else if(0x64 == buffer[index]) {// d
      return decodeDiction(buffer);
    }
    throw new ParseError("benobject", buffer, index);
  }

  Map decodeDiction(data.Uint8List buffer) {
    Map ret = new Map();
    if(buffer[index++] != 0x64) {
      throw new ParseError("bendiction", buffer, index);
    }

    ret = decodeDictionElements(buffer);

    if(buffer[index++] != 0x65) {
      throw new ParseError("bendiction", buffer, index);
    }
    return ret;
  }

  Map decodeDictionElements(data.Uint8List buffer) {
    Map ret = new Map();
    while(index<buffer.length && buffer[index] != 0x65) {
      data.Uint8List keyAsList = decodeBenObject(buffer);
      String key = convert.UTF8.decode(keyAsList.toList());
      ret[key] = decodeBenObject(buffer);
    }
    return ret;
  }

  List decodeList(data.Uint8List buffer) {
    List ret = new List();
    if(buffer[index++] != 0x6c) {
      throw new ParseError("benlist", buffer, index);
    }
    ret = decodeListElemets(buffer);
    if(buffer[index++] != 0x65) {
      throw new ParseError("benlist", buffer, index);
    }
    return ret;
  }

  List decodeListElemets(data.Uint8List buffer) {
    List ret = new List();
    while(index<buffer.length && buffer[index] != 0x65) {
      ret.add(decodeBenObject(buffer));
    }
    return ret;
  }

  num decodeNumber(data.Uint8List buffer) {
    if(buffer[index++] != 0x69) {
      throw new ParseError("bennumber", buffer, index);
    }
    int returnValue = 0;
    while(index<buffer.length && buffer[index] != 0x65) {
      if(!(0x30 <= buffer[index] && buffer[index]<=0x39)) {
        throw new ParseError("bennumber", buffer, index);
      }
      returnValue = returnValue*10+(buffer[index++]-0x30);
    }
    if(buffer[index++] != 0x65) {
      throw new ParseError("bennumber", buffer, index);
    }
    return returnValue;
  }

  data.Uint8List decodeBytes(data.Uint8List buffer) {
    int length = 0;
    while(index<buffer.length && buffer[index] != 0x3a) {
      if(!(0x30 <= buffer[index] && buffer[index]<=0x39)) {
        throw new ParseError("benstring", buffer, index);
      }
      length = length*10+(buffer[index++]-0x30);
    }
    if(buffer[index++] != 0x3a) {
      throw new ParseError("benstring", buffer, index);
    }
    data.Uint8List ret = new data.Uint8List.fromList(buffer.sublist(index, index+length));
    index += length;
    return ret;
  }
}

class Bencoder {
  ArrayBuilder builder = new ArrayBuilder();
 

  data.Uint8List enode(Object obj) {
    builder.clear();
    _innerEenode(obj);
    return builder.toUint8List();
  }

  void encodeString(String obj) {
    List<int> buffer = convert.UTF8.encode(obj);
    builder.appendString(""+buffer.length.toString()+":"+obj);
  }

  void encodeNumber(num num) {
    builder.appendString("i"+num.toString()+"e");
  }

  void encodeDictionary(Map obj) {
    Iterable<String> keys = obj.keys;
    builder.appendString("d");
    for(var key in keys) {
      encodeString(key);
      _innerEenode(obj[key]);
    }
    builder.appendString("e");
  }

  void encodeList(List list) {
    builder.appendString("l");
    for(int i=0;i<list.length;i++) {
      _innerEenode(list[i]);
    }
    builder.appendString("e");
  }

  void _innerEenode(Object obj) {
    if(obj is num) {
      encodeNumber(obj);
    } else if(identical(obj, true)) {
      encodeString("true");
    } else if(identical(obj, false)) {
      encodeString("false");
    } else if(obj == null) {
      encodeString("null");
    } else if(obj is String) {
      encodeString(obj);    
    } else if(obj is List) {
      encodeList(obj);
    } else if(obj is Map) {
      encodeDictionary(obj);
    }
  }
}

class ParseError implements Exception {
  
  String log = "";
  ParseError(String s, data.Uint8List buffer, int index) {
    log = s+"#"+buffer.toList().toString() +"index="+index.toString()+":"+ super.toString();
  }

  String toString() {
    return log;
  }
}
