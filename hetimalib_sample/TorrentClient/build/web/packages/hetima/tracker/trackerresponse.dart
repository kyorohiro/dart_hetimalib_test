part of hetima;


class TrackerResponse {
  static final String KEY_INTERVAL = "interval";
  static final String KEY_PEERS = "peers";
  static final String KEY_PEER_ID = "peer_id";
  static final String KEY_IP = "ip";
  static final String KEY_PORT = "port";
  static final String KEY_FAILURE_REASON = "failure reason";

  int interval = 10;
  List<PeerAddress> peers = [];
  TrackerResponse() {
  }

  TrackerResponse.bencode(data.Uint8List contents) {
    Map<String, Object> c = Bencode.decode(contents);
    initFromMap(c);
  }

  static async.Future<TrackerResponse> createFromContent(HetimaBuilder builder) {
    async.Completer<TrackerResponse> completer = new async.Completer();
    EasyParser parser = new EasyParser(builder);
    HetiBencode.decode(parser).then((Object o) {
      Map<String, Object> c = o;
      TrackerResponse instance = new TrackerResponse();
      instance.initFromMap(c);
      completer.complete(instance);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  initFromMap(Map<String, Object> c) {
    interval = c[KEY_INTERVAL];
    Object obj = c[KEY_PEERS];

    if (obj is data.Uint8List) {
      data.Uint8List wpeers = c[KEY_PEERS];
      for (int i = 0; i < wpeers.length; i += 6) {
        List<int> wpeer = [wpeers[i + 0], wpeers[i + 1], wpeers[i + 2], wpeers[i + 3]];
        List<int> port = [wpeers[i + 4], wpeer[i + 5]];
        peers.add(new PeerAddress([], "", wpeer.toList(), ByteOrder.parseInt(port, 0, 2)));
      }
    } else {
      List<Object> wpeers = c[KEY_PEERS];
      for (Map<String, Object> wpeer in wpeers) {
        data.Uint8List ip = wpeer[KEY_IP];
        data.Uint8List peeerid = wpeer[KEY_PEER_ID];
        int port = wpeer[KEY_PORT];
        peers.add(new PeerAddress(peeerid.toList(), "", ip.toList(), port));
      }
    }
  }

  Map<String, Object> createResponse(bool isCompat) {
    Map ret = new Map();
    ret[KEY_INTERVAL] = interval;
    if (isCompat) {
      ArrayBuilder builder = new ArrayBuilder();
      for (PeerAddress p in peers) {
        builder.appendIntList(p.ip, 0, p.ip.length);
        builder.appendIntList(ByteOrder.parseShortByte(p.port, ByteOrder.BYTEORDER_BIG_ENDIAN), 0, 2);
      }
      ret[KEY_PEERS] = builder.toUint8List();
    } else {
      List wpeers = ret[KEY_PEERS] = [];
      for (PeerAddress p in peers) {
        Map wpeer = {};
        wpeer[KEY_IP] = p.ipAsString;
        wpeer[KEY_PEER_ID] = new data.Uint8List.fromList(p.peerId);
        wpeer[KEY_PORT] = p.port;
        wpeers.add(wpeer);
      }
    }
    return ret;
  }
}
