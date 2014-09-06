import 'dart:html' as html;
import 'dart:convert' as convert;
import 'dart:async' as async;
import 'package:chrome/chrome_app.dart' as chrome;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetimacl;

hetima.UpnpDeviceSearcher ssdp = new hetima.UpnpDeviceSearcher(new hetimacl.HetiSocketBuilderChrome());

html.LabelElement deviceInfoMemo = null;
html.LabelElement addressInfoMemo = null;
html.LabelElement localAddressInfoMemo = null;
void main() {
  html.Element bindjoinNetwork = new html.Element.html('<input id="bindjoinNetworkButton" type="button" value="[1]bindjoinNetwork"> ');
  html.Element requestDiscover = new html.Element.html('<input id="requestDiscoverButton" type="button" value="[2]requestDiscover"> ');
  html.Element getServiceButton = new html.Element.html('<input id="requestMyIPButton" type="button" value="[3]requestMyIP"> ');
  html.Element getLocalAddressButton = new html.Element.html('<input id="testButton" type="button" value="[4]getLocalAddress"> ');

  deviceInfoMemo = new html.LabelElement();
  addressInfoMemo = new html.LabelElement();
  localAddressInfoMemo = new html.LabelElement();

  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(bindjoinNetwork);

  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(requestDiscover);
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(deviceInfoMemo);
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(getServiceButton);

  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(addressInfoMemo);
  html.document.body.append(new html.Element.html("<div>### </div>"));

  html.document.body.append(getLocalAddressButton);
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(localAddressInfoMemo);
  html.document.body.append(new html.Element.html("<div>### </div>"));

  ssdp.onReceive().listen((hetima.UPnpDeviceInfo info) {
    deviceInfoMemo.text = "device:"+info.getValue(hetima.UPnpDeviceInfo.KEY_LOCATION, "not found");
  });
  bindjoinNetwork.onClick.listen((html.MouseEvent e) {
    ssdp.init();
  });
  requestDiscover.onClick.listen((html.MouseEvent e) {
    ssdp.searchWanPPPDevice();
  });
  getServiceButton.onClick.listen((html.MouseEvent e) {
    for (hetima.UPnpDeviceInfo deviceInfo in ssdp.deviceInfoList) {
      hetima.UPnpPPPDevice pppDevice = new hetima.UPnpPPPDevice(deviceInfo);
      pppDevice.requestGetExternalIPAddress().then((String v) {
        print("v="+v);
        addressInfoMemo.text = "address:"+v;
      });
    }
  });

  getLocalAddressButton.onClick.listen((html.MouseEvent e) {
    chrome.system.network.getNetworkInterfaces().then((List<chrome.NetworkInterface> nl){
      for(chrome.NetworkInterface i in nl) {
        print("address:"+i.address);
        print("name:"+i.name);
        print("name:"+i.prefixLength.toString());
      }
      for(chrome.NetworkInterface i in nl) {
      if(i.prefixLength == 24) {
        localAddressInfoMemo.text = i.address;
        break;
      }
      }
    });
    DummyServer server = new DummyServer();
    server.startServer();
  });
}

class DummyServer {
  void startServer() {
    hetimacl.HetiSocketBuilderChrome builder = new hetimacl.HetiSocketBuilderChrome();
    builder.startServer("0.0.0.0", 8083).then((hetima.HetiServerSocket serverSocket) {
      serverSocket.onAccept().listen((hetima.HetiSocket socket) {
      //  new async.Future.delayed(new Duration(milliseconds: 100),() {
        socket.onReceive().listen((hetima.HetiReceiveInfo info) {
          socket.send(convert.UTF8.encode("hello")).then((hetima.HetiSendInfo i) {
             socket.close();
           });          
        });
      //  });
      });       
    });
  }
}


