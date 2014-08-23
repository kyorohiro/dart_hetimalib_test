part of hetima;

class HetiHttpClientResponse {
  HetiHttpMessageWithoutBody message;
  HetimaBuilder body;
  int getContentLength() {
    HetiHttpResponseHeaderField contentLength = message.find(RfcTable.HEADER_FIELD_CONTENT_LENGTH);
    if (contentLength == null) {
      try {
        return int.parse(contentLength.fieldValue);
      } catch (e) {
      }
    }
    return -1;
  }
}

class HetiHttpClient {
  HetiSocketBuilder _builder;
  HetiSocket socket = null;
  String host;
  int port;

  HetiHttpClient(HetiSocketBuilder builder) {
    _builder = builder;
  }

  async.Future<int> connect(String _host, int _port) {
    host = _host;
    port = _port;
    async.Completer<int> completer = new async.Completer();
    socket = _builder.createClient();
    socket.connect(host, port).then((HetiSocket socket) {
      if (socket == null) {
        completer.complete(-999);
      } else {
        completer.complete(1);
      }
    });
    return completer.future;
  }

  async.Future<HetiHttpClientResponse> get(String path, [Map<String, String> header]) {
    async.Completer<HetiHttpClientResponse> completer = new async.Completer();

    Map<String, String> headerTmp = {};
    headerTmp["Host"] = host;
    headerTmp["Connection"] = "close";
    for (String key in header.keys) {
      headerTmp[key] = header[key];
    }

    ArrayBuilder builder = new ArrayBuilder();
    builder.appendString("GET" + " " + path + " " + "HTTP/1.1" + "\r\n");
    for (String key in headerTmp.keys) {
      builder.appendString("" + key + ": " + headerTmp[key] + "\r\n");
    }
    builder.appendString("\r\n");

    socket.onReceive().listen((HetiReceiveInfo info) {
      String r = convert.UTF8.decode(info.data);
    //  print("\r\n######\r\n" + r + "\r\n#####\r\n");
    });
    socket.send(builder.toList()).then((HetiSendInfo info) {
      print("\r\n======" + info.resultCode.toString() + "\r\n");
    });

    EasyParser parser = new EasyParser(socket.buffer);
    HetiHttpResponse.decodeHttpMessage(parser).then((HetiHttpMessageWithoutBody message) {
      HetiHttpClientResponse result = new HetiHttpClientResponse();
      result.message = message;
      HetiHttpResponseHeaderField transferEncodingField = message.find("Transfer-Encoding");
      if(transferEncodingField == null || transferEncodingField.fieldValue != "chunked") {
        result.body = new HetimaBuilderAdapter(socket.buffer, message.index);
      } else {
        result.body = new ChunkedBuilderAdapter(new HetimaBuilderAdapter(socket.buffer, message.index)).start();
      }
      completer.complete(result);
    }).catchError((e) {
      print("\r\n#CCCCC#\r\n");
      completer.completeError(e);
    });
    return completer.future;
  }

  void close() {
    if (socket != null) {
      socket.close();
    }
  }
}
