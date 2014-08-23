part of hetima_sv;
class TorrentClient {
  dynamic address = "127.0.01";
  int port = 9999;

  async.Future<Object> startServer() {
    async.Future f = new async.Future.sync(() {
      io.ServerSocket.bind(address, port).then((io.ServerSocket server) {
        server.listen((io.Socket socket){
        });
     });
    }).catchError((e) {
      
    });
    return f;
  }

  async.Future<Object> handshake() {
    
  }

}
