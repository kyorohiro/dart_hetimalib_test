part of hetima_sv;

class HttpServer {
  String rootpath = "../..";
  int port = 8081;
  String host = "localhost";

  io.WebSocket _websocket;

  Map<String, Map> redirect = {
    "/redirect": {
      "scheme": "http",
      "host": "localhost",
      "port": 8081,
      "path": "/"
    }
  };

  /// {"/redirect":{"scheme":"http","host":"localhost","port":8081,"path":"/"}};
  void putRedirect(String currentPath, String nextScheme, String nextHost, int nextPort, String nextPath) {
    redirect[currentPath] = {
      "scheme": nextScheme,
      "host": nextHost,
      "port": nextPort,
      "path": nextPath
    };
  }
  void handleError(io.HttpRequest req, io.HttpResponse res) {
    res.statusCode = io.HttpStatus.NOT_FOUND;
    res.close();
  }

  void handleDir(io.HttpRequest req, io.HttpResponse res, String path) {
    io.Directory dir = new io.Directory(path);
    res.statusCode = io.HttpStatus.OK;
    res.headers.set("Content-Type", "text/html");

    dir.list().listen((io.FileSystemEntity e) {
      res.write(("<a href=http://" + req.headers.host + ":" + port.toString() + "" + e.path.substring(rootpath.length) + ">" + e.path + "</a><br>"));
    }).onDone(() {
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
      res.headers.set("Content-Length", buffer.length);
      res.add(buffer);
      res.close();
    });
  }

  void handleRedirect(io.HttpRequest req, io.HttpResponse res, String path) {
    Map next = null;
    for (String r in redirect.keys) {
      if (r == req.uri.path) {
        next = redirect[r];
        break;
      }
    }
    res.statusCode = io.HttpStatus.MOVED_TEMPORARILY;
    String query = "";
    if (req.uri.query != null && req.uri.query.length != 0) {
      query = "?" + req.uri.query;
    }
    String location = "" + next["scheme"] + "://" + next["host"] + ":" + next["port"].toString() + next["path"] + query;
    res.headers.set(io.HttpHeaders.LOCATION, "" + location + "");
    res.headers.set("Content-Type", "text/html");
    res.close();
  }

  void onListen(io.HttpRequest request) {
    // file or directory
    async.Future f = new async.Future.sync(() {

      print("onListen...:" + request.uri.scheme + "," + request.headers.host + "," + request.uri.path + "," + request.uri.port.toString() + "," + request.uri.query);
      String path = rootpath + request.uri.path;

      // redirect
      for (String r in redirect.keys) {
        if (r == request.uri.path) {
          return new async.Future((){
            handleRedirect(request, request.response, request.uri.path);
          });
        }
      }

      return io.FileSystemEntity.isDirectory(path).then((isDir) {
        if (isDir == true) {
          handleDir(request, request.response, path);
          return new async.Future((){});
        } else {
          io.File fpath = new io.File(path);
          return fpath.exists().then((bool isThere) {
            if (isThere) {
              handleFile(request, request.response, fpath);
            } else {
              handleError(request, request.response);
              return;
            }
          });
        }
      });
    }).catchError((e) {
      if (e != null) {
        print(e.toString());
      }
      try {
        if (request != null && request.response != null) {
          request.response.statusCode = io.HttpStatus.NOT_FOUND;
          request.response.close();
        }
      } catch (e) {
      }
    });
  }

  void start() {
    io.HttpServer.bind(host, port).then((io.HttpServer server) {
      server.listen(onListen);
    });
  }
}
