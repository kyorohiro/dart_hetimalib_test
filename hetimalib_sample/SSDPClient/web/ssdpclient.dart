
import 'dart:html' as html;
import 'dart:convert' as convert;
import 'package:chrome/chrome_app.dart' as chrome;
import 'package:hetima/hetima.dart' as hetima;
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
    ssdp.send();
  });
  
}




class SSDP
{
  static String SSDP_ADDRESS = "239.255.255.250";
  static int SSDP_PORT = 1900;

  static String SSDP_M_SEARCH = 
      """M-SEARCH * HTTP/1.1\r\n"""+
      """MX: 3\r\n"""+
      """HOST: 239.255.255.250:1900\r\n"""+
      """MAN: "ssdp:discover"\r\n"""+
      """ST: upnp:rootdevice\r\n"""+
      """\r\n""";
  chrome.CreateInfo i = null;

  void init() {
    chrome.sockets.udp.onReceive.listen(onReceive);
    chrome.sockets.udp.create().then((chrome.CreateInfo info) {
      i = info;
    //  return chrome.sockets.udp.setMulticastLoopbackMode(i.socketId, false);
   // }).then((int v) {
     return  chrome.sockets.udp.bind(i.socketId, "0.0.0.0", 0);
    //}).then((int v){
    // return chrome.sockets.udp.joinGroup(i.socketId, "239.255.255.250");
    }).then((int v){
    });
  }

  void onReceive(chrome.ReceiveInfo info) {
    print("########");
    print(""+convert.UTF8.decode(info.data.getBytes()));
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    List<int> buffer = info.data.getBytes();
    builder.appendIntList(buffer, 0, buffer.length);
    print("########");    
    hetima.HetiHttpResponse.decodeHttpMessage(parser).then((hetima.HetiHttpMessageWithoutBody message) {
      print("===");
      for(hetima.HetiHttpResponseHeaderField field in message.headerField) {
        print("name:"+field.fieldName +"=value:"+ field.fieldValue);
      }
      print("===");
    });
  }
  
  void send() {
    chrome.ArrayBuffer buffer = new chrome.ArrayBuffer.fromBytes(
        convert.UTF8.encode(SSDP_M_SEARCH));
    chrome.sockets.udp.send(i.socketId, buffer, SSDP_ADDRESS, SSDP_PORT).then((chrome.SendInfo iii) {
      print("###send="+iii.resultCode.toString());      
    });
    //ssdpclient.dart.js
  }
}