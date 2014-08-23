part of hetima_sv;

class SignalServer {
  String _address = "localhost";
  int port = 8082;
  io.HttpServer _server;
  List<io.WebSocket> _temporaryConnectionList = new List();
  Map<String, Map> _connectionList = new Map();

  void start() {
    io.HttpServer.bind(_address, port).then((io.HttpServer server) {
      server.listen(onListen);
    });//.catchError((){onError("bind error");});
  }

  void onListen(io.HttpRequest request) {
    if (io.WebSocketTransformer.isUpgradeRequest(request)) {
      io.WebSocketTransformer.upgrade(request).then(onConnect);
    } else {
      request.response.statusCode = io.HttpStatus.FORBIDDEN;
      request.response.write("this server support websocket only");
      request.response.close();
    }
  }

  void onConnect(io.WebSocket socket) {
    print("connect");
    _temporaryConnectionList.add(socket);
    socket.listen((dynmics) {
      onWsRceive(socket, dynmics);
    }, onDone: () {
      onWsDone(socket, "done");
    });
    //    onError:(){onWsDone(socket, "error");});
    //*/
  }

  void onWsRceive(io.WebSocket socket, Object message) {
    if (message is String) {
      print("receive:" + message);
    } else if (message is type.ByteBuffer) {
      type.ByteBuffer buffer = message;
      type.Uint8List accessBuffer = new type.Uint8List.view(buffer);
      print(convert.JSON.encode(Bencode.decode(accessBuffer)));
      onReceiveSignalMessage(socket, Bencode.decode(accessBuffer));
    } else if (message is type.Uint8List) {
      type.Uint8List buffer = message;
      type.Uint8List accessBuffer = buffer;
      print(convert.JSON.encode(Bencode.decode(accessBuffer)));
      onReceiveSignalMessage(socket, Bencode.decode(accessBuffer));
    } else {
      print("warning:" + message.toString());
      print("warning:" + message.runtimeType.toString());
    }
  }

  void onReceiveSignalMessage(io.WebSocket socket, Map message) {
    String action = convert.UTF8.decode(message["action"].toList());
    if (action == "join") {
      onJoin(socket, message);
    } else if (action == "pack") {
      onPack(socket, message);
    }
  }

  void onPack(io.WebSocket socket, Map message) {
    String action = convert.UTF8.decode(message["action"].toList());
    
    if (action != "pack") {
      return;
    }
    String from = convert.UTF8.decode(message["from"].toList());
    String to = convert.UTF8.decode(message["to"].toList());
  
    print("pack from="+from+",to="+to);

    Map p = _connectionList[to];
    if(p==null || p["socket"] == null) {
      return;
    }
    io.WebSocket targetSocket = _connectionList[to]["socket"];
    targetSocket.add(Bencode.encode(message).toList());
  }

  void onJoin(io.WebSocket socket, Map message) {
    String action = convert.UTF8.decode(message["action"].toList());
    if (action != "join") {
      return;
    }
    String id = convert.UTF8.decode(message["id"].toList());
    {
      var pack = {};
      pack["socket"] = socket;
      _connectionList[id] = pack;
    }

    {
      // respose peer list
      var pack = {};
      List<String> peers = pack["peers"] = [];
      pack["action"] = "join";
      pack["mode"] = "response";
      for (String key in _connectionList.keys) {
        peers.add(key);
      }
      socket.add(Bencode.encode(pack).toList());
    }
    {
      // broadcast join message to peers.
      var pack = {};
      List<String> peers = pack["peers"] = [];
      pack["action"] = "join";
      pack["mode"] = "broadcast";
      pack["from"] = id;
      for (String key in _connectionList.keys) {
        io.WebSocket targetSocket = _connectionList[key]["socket"];
        targetSocket.add(Bencode.encode(pack).toList());
      }
      print("fin onJoin");
    }
  }

  void onWsDone(io.WebSocket socket, String message) {
    print(message);
    _temporaryConnectionList.remove(socket);
    for (String key in _connectionList.keys) {
      if (_connectionList[key]["socket"] == socket) {
        _connectionList.remove(key);
        return;
      }
    }
  }

  void onError(String message) {
    print(message);
  }
}
