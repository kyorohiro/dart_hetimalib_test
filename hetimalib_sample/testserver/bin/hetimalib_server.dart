import 'dart:io' as io;
import 'dart:typed_data' as type;
void main() {
  Server server = new Server();
  server.startHttpServer();
}

class Server {
  String _rootpath = "../..";
  io.WebSocket _websocket;

  void onWSReceive(io.WebSocket websocket, message) {
//     if (message is type.ByteBuffer) {
       websocket.add(message);
//     }
//     else {
//      websocket.close();
//     }
  }
  void onWSError(io.WebSocket websoket) {
  }
  void onWSDone(io.WebSocket websocket) {
  }
  void handleWebsocket(io.WebSocket websocket) {
    websocket.listen(
        (message){
           onWSReceive(websocket, message);
        }, 
        onDone:(){
          onWSDone(websocket);
        },
        onError:(){
          onWSError(websocket);
        });
    websocket.close();
  }

  void handleError(io.HttpRequest req, io.HttpResponse res) {
    res.statusCode = 404;
    res.close();
  }

  void handleDir(io.HttpRequest req, io.HttpResponse res, String path) {
    io.Directory dir = new io.Directory(path);
    res.statusCode = 200;
    res.headers.set("Content-Type", "text/html");
    
    dir.list().listen((io.FileSystemEntity e) {
      res.write(
          ("<a href=."+e.path.substring(_rootpath.length)+">"+e.path+"</a><br>"));      
    }).onDone((){
      res.close();      
    });
  }

  void handleFile(io.HttpRequest req, io.HttpResponse res, io.File fpath) {
    fpath.readAsBytes().then((List<int> buffer) {
      res.statusCode = 200;
      if (fpath.path.endsWith(".txt")) {
        res.headers.set("Content-Type", "text/plain");
      } else if (fpath.path.endsWith(".htm") || fpath.path.endsWith(".html")) {
        res.headers.set("Content-Type", "text/html");
      } else {
        res.headers.set("Content-Type", "text/plain");
      }
      res.add(buffer);
      res.close();
    });
  }

  void startHttpServer() {
    io.HttpServer
    .bind("127.0.0.1", 8081)
    .then((io.HttpServer server) {
      server
      .listen((io.HttpRequest request) {
        if (request.uri.path == "/websocket") {
          io.WebSocketTransformer.upgrade(request).then(handleWebsocket);
          return;
        }
        print("onListen...:" + request.uri.path);
        String path = _rootpath + request.uri.path;
        io.FileSystemEntity.isDirectory(path).then((isDir) {
          if (isDir == true) {
            handleDir(request, request.response, path);
            return;
          } else {
            io.File fpath = new io.File(path);
            fpath.exists().then((bool isThere) {
              if (isThere) {
                handleFile(request, request.response, fpath);
              } else {
                handleError(request, request.response);
                return;
              }
            });
          }
        });
      });
    });
  }
}
