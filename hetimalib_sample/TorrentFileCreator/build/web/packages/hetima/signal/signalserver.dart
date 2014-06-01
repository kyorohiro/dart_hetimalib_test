part of hetima_sv;

class SignalServer {
  core.String _address = "localhost";
  core.int port = 8082;
  io.HttpServer _server;
  core.List<io.WebSocket> _temporaryConnectionList = new core.List();
  core.Map<core.String, core.Map> _connectionList = new core.Map();

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
    core.print("connect");
    _temporaryConnectionList.add(socket);
    socket.listen((dynmics) {
      onWsRceive(socket, dynmics);
    }, onDone: () {
      onWsDone(socket, "done");
    });
    //    onError:(){onWsDone(socket, "error");});
    //*/
  }

  void onWsRceive(io.WebSocket socket, core.Object message) {
    if (message is core.String) {
      core.print("receive:" + message);
    } else if (message is type.ByteBuffer) {
      type.ByteBuffer buffer = message;
      type.Uint8List accessBuffer = new type.Uint8List.view(buffer);
      core.print(convert.JSON.encode(Bencode.decode(accessBuffer)));
      onReceiveSignalMessage(socket, Bencode.decode(accessBuffer));
    } else if (message is type.Uint8List) {
      type.Uint8List buffer = message;
      type.Uint8List accessBuffer = buffer;
      core.print(convert.JSON.encode(Bencode.decode(accessBuffer)));
      onReceiveSignalMessage(socket, Bencode.decode(accessBuffer));
    } else {
      core.print("warning:" + message.toString());
      core.print("warning:" + message.runtimeType.toString());
    }
  }

  void onReceiveSignalMessage(io.WebSocket socket, core.Map message) {
    core.String action = convert.UTF8.decode(message["action"].toList());
    if (action == "join") {
      onJoin(socket, message);
    } else if (action == "pack") {
      onPack(socket, message);
    }
  }

  void onPack(io.WebSocket socket, core.Map message) {
    core.String action = convert.UTF8.decode(message["action"].toList());
    
    if (action != "pack") {
      return;
    }
    core.String from = convert.UTF8.decode(message["from"].toList());
    core.String to = convert.UTF8.decode(message["to"].toList());
  
    core.print("pack from="+from+",to="+to);

    core.Map p = _connectionList[to];
    if(p==null || p["socket"] == null) {
      return;
    }
    io.WebSocket targetSocket = _connectionList[to]["socket"];
    targetSocket.add(Bencode.encode(message).toList());
  }

  void onJoin(io.WebSocket socket, core.Map message) {
    core.String action = convert.UTF8.decode(message["action"].toList());
    if (action != "join") {
      return;
    }
    core.String id = convert.UTF8.decode(message["id"].toList());
    {
      var pack = {};
      pack["socket"] = socket;
      _connectionList[id] = pack;
    }

    {
      // respose peer list
      var pack = {};
      core.List<core.String> peers = pack["peers"] = [];
      pack["action"] = "join";
      pack["mode"] = "response";
      for (core.String key in _connectionList.keys) {
        peers.add(key);
      }
      socket.add(Bencode.encode(pack).toList());
    }
    {
      // broadcast join message to peers.
      var pack = {};
      core.List<core.String> peers = pack["peers"] = [];
      pack["action"] = "join";
      pack["mode"] = "broadcast";
      pack["from"] = id;
      for (core.String key in _connectionList.keys) {
        io.WebSocket targetSocket = _connectionList[key]["socket"];
        targetSocket.add(Bencode.encode(pack).toList());
      }
      core.print("fin onJoin");
    }
  }

  void onWsDone(io.WebSocket socket, core.String message) {
    core.print(message);
    _temporaryConnectionList.remove(socket);
    for (core.String key in _connectionList.keys) {
      if (_connectionList[key]["socket"] == socket) {
        _connectionList.remove(key);
        return;
      }
    }
  }

  void onError(core.String message) {
    core.print(message);
  }
}
