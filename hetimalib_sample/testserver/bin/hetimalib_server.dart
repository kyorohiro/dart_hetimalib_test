import 'package:hetima/hetima_sv.dart' as hetima;

void main() {
  hetima.HttpServer server = new hetima.HttpServer();
  server.start();
  hetima.SignalServer sigserver = new hetima.SignalServer();
  sigserver.start();
}
