part of hetima_cl;

class HetiSocketBuilderChrome extends HetiSocketBuilder {
  HetiSocket createClient() {
    return new HetiSocketChrome.empty();
  }

  async.Future<HetiServerSocket> startServer(core.String address, core.int port) {
    return HetiServerSocketChrome.startServer(address, port);
  }
}

class HetiServerSocketManager {
  core.Map<core.int, HetiServerSocket> _serverList = new core.Map();
  core.Map<core.int, HetiSocket> _clientList = new core.Map();
  static final HetiServerSocketManager _instance = new HetiServerSocketManager._internal();
  factory HetiServerSocketManager() {
    return _instance;
  }

  HetiServerSocketManager._internal() {
    manageServerSocket();
  }

  static HetiServerSocketManager getInstance() {
    return _instance;
  }

  void manageServerSocket() {
    chrome.sockets.tcpServer.onAccept.listen((chrome.AcceptInfo info) {
      core.print("--accept ok " + info.socketId.toString() + "," + info.clientSocketId.toString());
      HetiServerSocketChrome server = _serverList[info.socketId];
      if (server != null) {
        server.onAcceptInternal(info);
      }
    });

    chrome.sockets.tcpServer.onAcceptError.listen((chrome.AcceptErrorInfo info) {
      core.print("--accept error");
    });

    core.bool closeChecking = false;
    chrome.sockets.tcp.onReceive.listen((chrome.ReceiveInfo info) {
      core.print("--receive " + info.socketId.toString() + "," + info.data.getBytes().length.toString());
      HetiSocketChrome socket = _clientList[info.socketId];
      if (socket != null) {
        socket.onReceiveInternal(info);
        if (closeChecking == false) {
          closeChecking = true;
          chrome.sockets.tcp.getInfo(socket.clientSocketId).then((chrome.SocketInfo inf) {
            closeChecking = false;
            core.print("###DF# " + inf.connected.toString() + "," + inf.paused.toString());
            if (inf.connected == false) {
              socket.close();
            }
          });
        }
      }
    });
    chrome.sockets.tcp.onReceiveError.listen((chrome.ReceiveErrorInfo info) {
      core.print("--receive error " + info.socketId.toString() + "," + info.resultCode.toString());
      HetiSocketChrome socket = _clientList[info.socketId];
    });
  }

  void addServer(chrome.CreateInfo info, HetiServerSocketChrome socket) {
    _serverList[info.socketId] = socket;
  }

  void removeServer(chrome.CreateInfo info) {
    _serverList.remove(info.socketId);
  }

  void addClient(core.int socketId, HetiSocketChrome socket) {
    _clientList[socketId] = socket;
  }

  void removeClient(core.int socketId) {
    _serverList.remove(socketId);
  }

}

class HetiServerSocketChrome extends HetiServerSocket {

  static async.Future<HetiServerSocket> startServer(core.String address, core.int port) {
    async.Completer<HetiServerSocket> completer = new async.Completer();
    new async.Future.sync(() {
      return chrome.sockets.tcpServer.create().then((chrome.CreateInfo info) {
        return chrome.sockets.tcpServer.listen(info.socketId, address, port).then((core.int backlog) {
          HetiServerSocketChrome server = new HetiServerSocketChrome._internal(info);
          HetiServerSocketManager.getInstance().addServer(info, server);
          completer.complete(server);
        });
      });
    }).catchError((e) {
      completer.complete(null);
    });
    return completer.future;
  }

  async.StreamController<HetiSocket> _controller = new async.StreamController();
  chrome.CreateInfo _mInfo = null;

  HetiServerSocketChrome._internal(chrome.CreateInfo info) {
    _mInfo = info;
  }

  async.Stream<HetiSocket> onAccept() {
    return _controller.stream;
  }

  void onAcceptInternal(chrome.AcceptInfo info) {
    _controller.add(new HetiSocketChrome(info.clientSocketId));
  }

  void close() {
    chrome.sockets.tcpServer.close(_mInfo.socketId);
    HetiServerSocketManager.getInstance().removeServer(_mInfo);
  }

}

class HetiSocketChrome extends HetiSocket {
  core.int clientSocketId;
  async.StreamController<HetiReceiveInfo> _controller = new async.StreamController();

  HetiSocketChrome.empty() {
  }

  HetiSocketChrome(core.int _clientSocketId) {
    HetiServerSocketManager.getInstance().addClient(_clientSocketId, this);
    chrome.sockets.tcp.setPaused(_clientSocketId, false);
    clientSocketId = _clientSocketId;
  }

  async.Stream<HetiReceiveInfo> onReceive() {
    return _controller.stream;
  }

  void onReceiveInternal(chrome.ReceiveInfo info) {
    core.print("--receive " + info.socketId.toString());
    updateTime();
    core.List<core.int> tmp = info.data.getBytes();
    buffer.appendIntList(tmp, 0, tmp.length);
    _controller.add(new HetiReceiveInfo(info.data.getBytes()));
  }

  async.Future<HetiSendInfo> send(core.List<core.int> data) {
    updateTime();
    async.Completer<HetiSendInfo> completer = new async.Completer();
    new async.Future.sync(() {
      chrome.ArrayBuffer buffer = new chrome.ArrayBuffer.fromBytes(data);
      chrome.sockets.tcp.send(clientSocketId, buffer).then((chrome.SendInfo info) {
        updateTime();
        completer.complete(new HetiSendInfo(info.resultCode));
      });
    }).catchError((e) {
      completer.complete(new HetiSendInfo(-1999));
    });
    return completer.future;
  }

  async.Future<HetiSocket> connect(core.String peerAddress, core.int peerPort) {
    async.Completer<HetiSocket> completer = new async.Completer();
    new async.Future.sync(() {
      chrome.sockets.tcp.create().then((chrome.CreateInfo info) {
        chrome.sockets.tcp.connect(info.socketId, peerAddress, peerPort).then((core.int e) {
          {
            chrome.sockets.tcp.setPaused(info.socketId, false);
            clientSocketId = info.socketId;
            HetiServerSocketManager.getInstance().addClient(info.socketId, this);
            completer.complete(this);
          }
          //          completer.complete(new HetiSocketChrome(info.socketId));
        });
      });
    }).catchError((e) {
      core.print(e.toString());
      completer.complete(null);
    });
    return completer.future;
  }

  void close() {
    super.close();
    if (_isClose) {
      return;
    }
    updateTime();
    chrome.sockets.tcp.close(clientSocketId).then((d) {
      core.print("##closed()");
    });
    HetiServerSocketManager.getInstance().removeClient(clientSocketId);
    _isClose = true;
  }
  core.bool _isClose = false;
}
