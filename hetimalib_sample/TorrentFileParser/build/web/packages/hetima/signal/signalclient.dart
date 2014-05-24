part of hetima_cl;

class SignalClient {
  static core.int NULL = -1;
  static core.int CONNECTING = 0;// The connection is not yet open.
  static core.int OPEN = 1;// The connection is open and ready to communicate.
  static core.int CLOSING = 2;// The connection is in the process of closing.
  static core.int CLOSED = 3;// The connection is closed or couldn't be opened.

  core.String _websocketUrl = "ws://localhost:8082/websocket";
  html.WebSocket _websocket;

  async.StreamController<core.List<core.String>> _signalFindPeer = new async.StreamController.broadcast();
  async.StreamController<SignalMessageInfo> _signalReceiveMessage = new async.StreamController.broadcast();
  async.StreamController<core.String> _signalClose = new async.StreamController();

  async.Future connect() {
    async.Completer<html.Event> _connectWork = new async.Completer();

    _websocket = new html.WebSocket(_websocketUrl);
    _websocket.binaryType = "arraybuffer";
    _websocket.onOpen.listen((html.Event e) {
      _connectWork.complete(e);
    });
    _websocket.onMessage.listen(onMessage);
    _websocket.onError.listen((html.Event e) {
      notifyOnClose("close websocket");      
    });
    _websocket.onClose.listen((html.CloseEvent e) {
      notifyOnClose("close websocket");
    });
    return _connectWork.future;
  }

  void onMessage(html.MessageEvent e) {
    core.print("type=" + e.type + "," + e.data.runtimeType.toString());
    if (e is core.String) {
      core.print("data=" + e.data);
    }
    else if (e.data is data.ByteBuffer) {
      data.ByteBuffer bbuffer = e.data;
      data.Uint8List buffer = new data.Uint8List.view(bbuffer);
      _onReceiveSignalMessage(Bencode.decode(buffer));      
    }
    else if (e.data is data.Uint8List) {
      data.Uint8List buffer = e.data;
      _onReceiveSignalMessage(Bencode.decode(buffer));
    }
  }

  void _onReceiveSignalMessage(core.Map message) {
    core.print("receive signal message");
    core.String log = convert.JSON.encode(message);
    core.int max = 40;if(log.length <max) {max =log.length;}
    core.print("---" + convert.JSON.encode(message).substring(0,max));    

    if (convert.UTF8.decode(message["action"]) == "join") {
      if (convert.UTF8.decode(message["mode"]) == "response") {
        core.List peersAsBytes = message["peers"];
        core.List<core.String> peers = new core.List();
        for (core.int i = 0; i < peersAsBytes.length; i++) {
          peers.add(convert.UTF8.decode(peersAsBytes[i]));
          core.print("" + convert.UTF8.decode(peersAsBytes[i]));
        }

        notifyUpdatePeer(peers);
      } else {
        core.print("" + convert.UTF8.decode(message["from"]));
        core.List<core.String> peers = new core.List();
        peers.add(convert.UTF8.decode(message["from"]));
        notifyUpdatePeer(peers);
      }
    }
    else if (convert.UTF8.decode(message["action"]) == "pack") {
      core.String to = convert.UTF8.decode(message["to"]);
      core.String from = convert.UTF8.decode(message["from"]);
      notifyOnReceivePackage(to, from, message["pack"]);
    }
  }

  core.int getState() {
    if (_websocket == null) {
      return -1;
    }
    return _websocket.readyState;
  }

  void sendJoin(core.String id) {
    var pack = {};
    pack["action"] = "join";
    pack["mode"] = "broadcast";
    pack["id"] = id;
    sendObject(pack);
  }

  void unicastPackage(core.String to, core.String from, core.Map pack) {
    var package = {};
    package["action"] = "pack";
    package["mode"] = "unicast";
    package["pack"] = pack;
    package["to"] = to;
    package["from"] = from;
    sendObject(package);
  }

  void sendObject(core.Map pack) {
    data.Uint8List buffer8 = Bencode.encode(pack);
    _websocket.sendByteBuffer(buffer8.buffer);
  }

  void sendBuffer(data.ByteBuffer buffer) {
    _websocket.sendByteBuffer(buffer);
  }

  void sendText(core.String message) {
    _websocket.sendString(message);
  }

  void notifyUpdatePeer(core.List<core.String> peers) {
    _signalFindPeer.add(peers);
  }
 
  void notifyOnReceivePackage(core.String to, core.String from, core.Map pack) {
    SignalMessageInfo info = new SignalMessageInfo(to, from, pack);
    _signalReceiveMessage.add(info);
  }

  void notifyOnClose(core.String message) {
    _signalClose.add(message);
  }

  async.Stream onFindPeer() {
    return _signalFindPeer.stream;
  }

  async.Stream onReceiveMessage() {
    return _signalReceiveMessage.stream;
  }
  async.Stream onClose() {
    return _signalClose.stream;
  }
}

class SignalMessageInfo {
  core.String _mTo;
  core.String _mFrom;
  core.Map _mPack;
  SignalMessageInfo(core.String to, core.String from, core.Map pack) {
    _mTo = to;
    _mFrom = from;
    _mPack = pack;
  }
  core.String get to => _mTo;
  core.String get from => _mFrom;
  core.Map get pack => _mPack;
}
