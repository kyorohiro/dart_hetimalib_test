part of hetima_cl;


class HetiServerSocketChrome extends HetiServerSocket {

  void start(core.String address, core.int port) {
    chrome.sockets.tcpServer.create().then((chrome.CreateInfo info) {
      chrome.sockets.tcpServer.listen(info.socketId, address, port).then((core.int backlog) {
        chrome.sockets.tcpServer.onAccept.listen((chrome.AcceptInfo info) {
          //
          //
          core.print("--accept ok");
        });
        chrome.sockets.tcpServer.onAcceptError.listen((chrome.AcceptErrorInfo info) {
          core.print("--accept error");
        });
      });
    });
  }

}

class HetiSocketChrome {
  core.int socketId;
  void send(core.List<core.int> data) {
    chrome.ArrayBuffer buffer = new chrome.ArrayBuffer.fromBytes(data);
    chrome.sockets.tcp.send(socketId, buffer);
  }

  void onReceive() {
    chrome.sockets.tcp.onReceive.listen((chrome.ReceiveInfo info) {
      //
    });
  }

  void close() {
    chrome.sockets.tcp.close(socketId);
  }
}


class HetiSocketListener {
  void onReceive(core.List<core.int> data) {
  }
}

