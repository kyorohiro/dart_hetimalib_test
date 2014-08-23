import 'dart:html';
import 'package:hetima/hetima.dart';
import 'package:hetima/hetima_cl.dart';
int boundsChange = 100;

/**
 * A `hello world` application for Chrome Apps written in Dart.
 *
 * For more information, see:
 * - http://developer.chrome.com/apps/api_index.html
 * - https://github.com/dart-gde/chrome.dart
 */
void main() {
  querySelector("#text_id").onClick.listen(resizeWindow);
}

void resizeWindow(MouseEvent event) {
  print("resizeWindow");
///  chrome.sockets s = chrome.sockets.tcpServer.
///  io.HttpClient client = new io.HttpClient();
///  
  HetiServerSocketChrome server = new HetiServerSocketChrome();
  server.start("127.0.0.1", 8088);
  print("##resizeWindow");
}
