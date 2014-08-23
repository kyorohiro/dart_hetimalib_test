part of hetima;

class HetiTest
{
  Map<String,HetiTestTicket> ticketMap = new Map();
  int endNum = 0;
  String _id = "";
  HetiTest(String id) {
    _id = id;
  }

  HetiTestTicket test(String id, int timeout_ms) {
    if(ticketMap.containsKey(id)) {
      throw new Error();
    }
    HetiTestTicket ticket = new HetiTestTicket(id);
    ticketMap[id] = ticket;
    ticket.onFin().then((bool r){
      endNum++;
      if(ticketMap.length == endNum) {
        print("################");
        print("### " + _id);
        for(String k in ticketMap.keys) {
          print(ticketMap[k].toString());
        }
      }
    });
    return ticket;
  }
  
}

class HetiTestTicket {
  async.Completer<bool> _completer = new async.Completer<bool>();
  String _id = "";
  bool _result = true;
  bool _isFin = false;
  String _message = "";
  HetiTestTicket(String id) {
    _id = id;
  }

  void assertTrue(String message, bool isPassed) {    
    if(!isPassed && _result == true) {
      _result = false;
      _message = message;
    }
  }

  String toString() {
    if(_isFin == false&& _result == true) {
      return "["+_id+"]"+"TIMEOUT";
    } else {
      return "["+_id+"]"+(_result==true?"OK":"NG")+":"+_message;
    }
  }

  void fin() {
    _isFin = true;
    if(!_completer.isCompleted) {
      _completer.complete(_result);
    }
  }

  async.Future<bool> onFin() {
    return _completer.future;
  }
}