part of hetima;

abstract class HetiSocketBuilder {
  HetiSocket createClient();
  async.Future<HetiServerSocket> startServer(String address, int port) ;
}

abstract class HetiServerSocket {
  async.Stream<HetiSocket> onAccept();
}

abstract class HetiSocket {
  int lastUpdateTime = 0;
  ArrayBuilder buffer = new ArrayBuilder();
  async.Future<HetiSocket> connect(String peerAddress, int peerPort) ;
  async.Future<HetiSendInfo> send(List<int> data);
  async.Stream<HetiReceiveInfo> onReceive();
  void close() {
    buffer.immutable = true;
  }
  void updateTime() {
    lastUpdateTime = (new DateTime.now()).millisecondsSinceEpoch;
  }
}

class HetiSendInfo {
  int resultCode = 0;
  HetiSendInfo(int _resultCode) {
    resultCode = _resultCode;
  }
}

class HetiReceiveInfo {
  List<int> data;
  HetiReceiveInfo(List<int> _data) {
    data = _data;
  }
}
