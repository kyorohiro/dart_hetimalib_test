part of trackerserver;

class Setting {
  static final String KEY_IP = "ip";
  static final String KEY_PORT = "port";
  static final String KEY_ROOT = "root";
  static final String KEY_HASHLIST = "hashlist";
  String settingfilePath = "../setting";

  static String getIp(Map<String, Object> p, String def) {
    return Bencode.toText(p, Setting.KEY_IP, def);
  }

  static int getPort(Map<String, Object> p, int def) {
    return Bencode.toNum(p, Setting.KEY_PORT, def);
  }

  static List<String> getHashlist(Map<String, Object> p) {
    List list = Bencode.toList(p, Setting.KEY_HASHLIST);
    List ret = [];
    for(int i=0;i<list.length;i++) {
      if(list[i] is Uint8List) {
        ret.add(conv.UTF8.decode(list[i]));
      }
    }
    return ret;
  }

  Future<Map<String, Object>> read() {
    Completer<Map<String, Object>> completer = new Completer();
    Future s = new Future.sync(() {
      File fpath = new File(settingfilePath);
      return fpath.readAsBytes().then((List<int> buffer) {
        Map<String, Object> obj = Bencode.decode(buffer);
        completer.complete(obj);
      });
    }).catchError((e) {
      Map<String, Object> r = new Map();
      completer.complete(r);
    });
    return completer.future;
  }

  Future<bool> write(Map<String, Object> v) {
    Completer<bool> completer = new Completer();
    Future s = new Future.sync(() {
      List<int> buffer = Bencode.encode(v);
      File fpath = new File(settingfilePath);
      return fpath.writeAsBytes(buffer);
    }).catchError((e) {
      completer.complete(false);
    }).whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    });
    return completer.future;
  }
}
