part of hetima;

class TorrentFile {
  static final String KEY_ANNOUNCE = "announce";
  static final String KEY_NAME = "name";
  static final String KEY_INFO = "info";
  static final String KEY_FILES = "files";
  static final String KEY_LENGTH = "length";
  static final String KEY_PIECE_LENGTH = "piece length";
  static final String KEY_PIECE = "piece";
  static final String KEY_PATH = "path";

  Map mMetadata = {};
  data.ByteBuffer piece = null;
  int piece_length = 0;

  TorrentFile.nullobject() {
    mMetadata = {};
  }

  TorrentFile.loadTorrentFileBuffer(data.Uint8List buffer) {
    mMetadata = Bencode.decode(buffer);
  }

  TorrentFile.torentmap(Map map) {
    mMetadata = map;
  }

  String get announce {
    if (mMetadata.containsKey(KEY_ANNOUNCE)) {
      return objectToString(mMetadata[KEY_ANNOUNCE]);
    } else {
      return "";
    }
  }

  void set announce(String v) {
    mMetadata[KEY_ANNOUNCE] = v;
  }

  TorrentFileInfo mInfo = null;
  TorrentFileInfo get info {
    if (mInfo == null) {
      mInfo = new TorrentFileInfo(mMetadata);
    }
    return mInfo;
  }

}

class TorrentFileInfo {
  Map mInfo = {};
  String get name {
    if (mInfo.containsKey(TorrentFile.KEY_NAME)) {
      return objectToString(mInfo[TorrentFile.KEY_NAME]);
    } else {
      return "";
    }
  }

  void set name(String v) {
    mInfo[TorrentFile.KEY_NAME] = v;
  }

  int get piece_length {
    return mInfo[TorrentFile.KEY_PIECE_LENGTH];
  }

  data.Uint8List get piece {
    return mInfo[TorrentFile.KEY_PIECE];
  }

  TorrentFileFiles get files {
    return new TorrentFileFiles(this);
  }

  TorrentFileInfo(Map metadata) {
    mInfo = metadata[TorrentFile.KEY_INFO];
  }
}

class TorrentFileFiles {
  TorrentFileInfo mInfo = null;
  TorrentFileFiles(TorrentFileInfo info) {
    mInfo = info;
  }

  int get size {
    if (mInfo.mInfo.containsKey(TorrentFile.KEY_FILES)) {
      return (mInfo.mInfo[TorrentFile.KEY_FILES] as List).length;
    }
    return 1;
  }

  List<TorrentFileFile> get path {
    if (1 == this.size) {
      mInfo.name;
      List<TorrentFileFile> ret = new List();
      ret.add(new TorrentFileFile([mInfo.name], mInfo.mInfo[TorrentFile.KEY_LENGTH]));
      return ret;
    } else {
      List<TorrentFileFile> ret = new List();
      List<Map> files = mInfo.mInfo[TorrentFile.KEY_FILES];
      for (Map f in files) {
        ret.add(new TorrentFileFile(f[TorrentFile.KEY_PATH], f[TorrentFile.KEY_LENGTH]));
      }
      return ret;
    }
  }
}

class TorrentFileFile {
  List<String> path = new List();
  int length = 0;
  TorrentFileFile(List p, int l) {
    length = l;
    for (Object o in p) {
      path.add(objectToString(o));
    }
  }
  String get pathAsString {
    StringBuffer buffer = new StringBuffer();
    for (String s in path) {
      buffer.write(s);
    }
    return buffer.toString();
  }
}


String objectToString(Object v) {
  if (v is String) {
    return v;
  } else {
    return convert.UTF8.decode((v as data.Uint8List).toList());
  }
}
