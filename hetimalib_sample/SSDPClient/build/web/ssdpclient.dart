
import 'dart:html' as html;
import 'dart:convert' as convert;
import 'package:chrome/chrome_app.dart' as chrome;

SSDP ssdp = new SSDP();

void main() {
  html.Element requestDiscover = new html.Element.html('<input id="requestDiscoverButton" type="button" value="requestDiscover"> ');
  html.Element bindjoinNetwork = new html.Element.html('<input id="bindjoinNetworkButton" type="button" value="bindjoinNetwork"> ');
  
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(bindjoinNetwork);

  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(requestDiscover);
  
  bindjoinNetwork.onClick.listen((html.MouseEvent e) {
    ssdp.init();
  });
  requestDiscover.onClick.listen((html.MouseEvent e) {
    
  });
  
}




class SSDP
{
  static String SSDP_ADDRESS = "239.255.255.250";
  static int SSDP_PORT = 1900;

  chrome.CreateInfo i = null;

  void init() {
//    chrome.sockets.udp.onReceive.listen(onReceive);
    chrome.sockets.udp.create().then((chrome.CreateInfo info) {
      i = info;
  //   return  chrome.sockets.udp.bind(info.socketId, SSDP_ADDRESS, SSDP_PORT);
   // }).then((int v){
     return chrome.sockets.udp.joinGroup(i.socketId, "239.255.255.250");
    }).then((int v){
    });
  }

  void onReceive(chrome.ReceiveInfo info) {
    print(""+convert.UTF8.decode(info.data.getBytes()));
  }
  
  void send() {
    //ssdpclient.dart.js
  }
}