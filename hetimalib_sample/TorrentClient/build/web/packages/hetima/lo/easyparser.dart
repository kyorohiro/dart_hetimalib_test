part of hetima;

class EasyParser {
  int index = 0;
  List<int> stack = new List();
  HetimaBuilder buffer = null;
  EasyParser(HetimaBuilder builder) {
    buffer = builder;
  }

  void push() {
    stack.add(index);
  }

  void back() {
    index = stack.last;
  }

  int pop() {
    int ret = stack.last;
    stack.remove(ret);
    return ret;
  }

  int last() {
    return stack.last;
  }

  async.Future<List<int>> getPeek(int length) {
    return buffer.getByteFuture(index, length);
  }

  async.Future<List<int>> nextBuffer(int length) {
    async.Completer<List<int>> completer = new async.Completer();
    buffer.getByteFuture(index, length).then((List<int> v) {
      index += v.length;
      completer.complete(v);
    }).catchError((e){
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<String> nextString(String value) {
    async.Completer completer = new async.Completer();
    List<int> encoded = convert.UTF8.encode(value);
    buffer.getByteFuture(index, encoded.length).then((List<int> v) {
      if (v.length != encoded.length) {
        completer.completeError(new EasyParseError());
        return;
      }
      int i=0;
      for (int e in encoded) {
        if (e != v[i]) {
          completer.completeError(new EasyParseError());
          return;
        }
        i++;
        index++;
      }
      completer.complete(value);
    });
    return completer.future;
  }

  async.Future<int> nextBytePattern(EasyParserMatcher matcher) {
    async.Completer completer = new async.Completer();
    buffer.getByteFuture(index, 1).then((List<int> v) {
      if(v.length < 1) {
        throw new EasyParseError();        
      }
      if (matcher.match(v[0])) {
        index++;
        completer.complete(v[0]);
      } else {
        throw new EasyParseError();
      }
    });
    return completer.future;
  }

  async.Future<List<int>> nextBytePatternWithLength(EasyParserMatcher matcher, int length) {
    async.Completer completer = new async.Completer();
    buffer.getByteFuture(index, length).then((List<int> va) {
      if(va.length < length) {
        completer.completeError(new EasyParseError());
      }
      for (int v in va) {
        bool find = false;
        find = matcher.match(v);
        if (find == false) {
          completer.completeError(new EasyParseError());
        }
        index++;
      }
      completer.complete(va);
    });
    return completer.future;
  }

  
  async.Future<List<int>> nextBytePatternByUnmatch(EasyParserMatcher matcher) {
    async.Completer completer = new async.Completer();
    List<int> ret = new List<int>();
    async.Future<Object> p() {
      return buffer.getByteFuture(index, 1).then((List<int> va) {
        if(va.length<1) {
          completer.complete(ret);          
        }
        else if(matcher.match(va[0])) {
          ret.add(va[0]);
          index++;
          return p();
        } else if(buffer.immutable) {
          completer.complete(ret);
        } else {
          completer.complete(ret);
        }
        
      });
    };
    p();
    return completer.future;
  }

}

abstract class EasyParserMatcher {
  bool match(int target);
}

class EasyParserIncludeMatcher extends EasyParserMatcher {
  List<int> include = null;
  EasyParserIncludeMatcher(List<int> i) {
    include = i;
  }

  bool match(int target) {
    return include.contains(target);
  }
}

class EasyParseError extends Error {
  EasyParseError();
}
