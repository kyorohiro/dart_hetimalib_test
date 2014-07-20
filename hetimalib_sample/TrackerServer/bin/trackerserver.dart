library trackerserver;
import 'package:hetima/hetima.dart';
import 'package:hetima/hetima_sv.dart' as hetimasv;
import 'dart:async';
import 'dart:io';
import 'dart:convert' as conv;
import 'dart:typed_data';
part 'setting.dart';

void main() {
  Setting setting = new Setting();
  setting.read().then((Map<String, Object> p) {
    hetimasv.TrackerServer server = new hetimasv.TrackerServer();
    server.address = Setting.getIp(p[Setting.KEY_IP], server.address);
    server.port = Setting.getPort(p, server.port);
    List<String> list = Setting.getHashlist(p);
    for (String p in list) {
      server.add(p);
    }
    server.start();
  });
}
