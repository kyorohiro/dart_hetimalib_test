import 'dart:io' as io;
import 'dart:typed_data' as type;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_sv.dart' as hetima;

void main() {
  hetima.HttpServer server = new hetima.HttpServer();
  server.start();
  hetima.SignalServer sigserver = new hetima.SignalServer();
  sigserver.start();
}
