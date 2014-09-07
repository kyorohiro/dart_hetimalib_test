import 'dart:html' as html;
import 'dart:convert' as convert;
import 'dart:async' as async;
import 'package:chrome/chrome_app.dart' as chrome;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetimacl;

hetima.UpnpDeviceSearcher ssdp = null;

html.LabelElement deviceInfoMemo = null;
html.LabelElement addressInfoMemo = null;
html.LabelElement localAddressInfoMemo = null;
html.LabelElement portMappingResultInfoMemo = null;

String localAddress = "";
void main() {
  html.Element bindjoinNetwork = new html.Element.html('<input id="bindjoinNetworkButton" type="button" value="[1]bindjoinNetwork"> ');
  html.Element requestDiscover = new html.Element.html('<input id="requestDiscoverButton" type="button" value="[2]requestDiscover"> ');
  html.Element getServiceButton = new html.Element.html('<input id="requestMyIPButton" type="button" value="[3]requestMyIP"> ');
  html.Element getLocalAddressButton = new html.Element.html('<input id="testButton" type="button" value="[4]getLocalAddress"> ');
  html.Element setPortButton = new html.Element.html('<input id="testButton" type="button" value="[5]setPort"> ');
  html.Element delPortButton = new html.Element.html('<input id="testButton" type="button" value="[5]delPort"> ');
  html.Element gelPortButton = new html.Element.html('<input id="testButton" type="button" value="[5]gelPort"> ');

  hetima.UpnpDeviceSearcher.createInstance(new hetimacl.HetiSocketBuilderChrome()).then((hetima.UpnpDeviceSearcher searcher) {
    ssdp = searcher;
    ssdp.onReceive().listen((hetima.UPnpDeviceInfo info) {
      deviceInfoMemo.text = "device:" + info.getValue(hetima.UPnpDeviceInfo.KEY_LOCATION, "not found");
    });
  });

  deviceInfoMemo = new html.LabelElement();
  addressInfoMemo = new html.LabelElement();
  localAddressInfoMemo = new html.LabelElement();
  portMappingResultInfoMemo = new html.LabelElement();

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

  html.document.body.append(setPortButton);
  html.document.body.append(delPortButton);
  html.document.body.append(gelPortButton);

  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(portMappingResultInfoMemo);
  html.document.body.append(new html.Element.html("<div>### </div>"));

  

  requestDiscover.onClick.listen((html.MouseEvent e) {
    if(ssdp == null) {
      return;
    }
    ssdp.searchWanPPPDevice();
  });
  getServiceButton.onClick.listen((html.MouseEvent e) {
    if(ssdp == null) {
      return;
    }
    for (hetima.UPnpDeviceInfo deviceInfo in ssdp.deviceInfoList) {
      hetima.UPnpPPPDevice pppDevice = new hetima.UPnpPPPDevice(deviceInfo);
      pppDevice.requestGetExternalIPAddress().then((String v) {
        print("v=" + v);
        addressInfoMemo.text = "address:" + v;
      });
    }
  });

  getLocalAddressButton.onClick.listen((html.MouseEvent e) {
    if(ssdp == null) {
      return;
    }
    chrome.system.network.getNetworkInterfaces().then((List<chrome.NetworkInterface> nl) {
      for (chrome.NetworkInterface i in nl) {
        print("address:" + i.address);
        print("name:" + i.name);
        print("name:" + i.prefixLength.toString());
      }
      for (chrome.NetworkInterface i in nl) {
        if (i.prefixLength == 24) {
          localAddressInfoMemo.text = i.address;
          localAddress = i.address;
          break;
        }
      }
    });
    DummyServer server = new DummyServer();
    server.startServer();
  });

  setPortButton.onClick.listen((html.MouseEvent e) {
    if(ssdp == null) {
      return;
    }
    for (hetima.UPnpDeviceInfo deviceInfo in ssdp.deviceInfoList) {
      hetima.UPnpPPPDevice pppDevice = new hetima.UPnpPPPDevice(deviceInfo);
      pppDevice.requestAddPortMapping(
          48083, hetima.UPnpPPPDevice.VALUE_PORT_MAPPING_PROTOCOL_TCP,
          8083, localAddress, 
          hetima.UPnpPPPDevice.VALUE_ENABLE, "test", 0).then((int v){
        portMappingResultInfoMemo.text = "portMappingResult:add:" + v.toString();
      });
    }
  });
  
  delPortButton.onClick.listen((html.MouseEvent e) {
    if(ssdp == null) {
      return;
    }
    for (hetima.UPnpDeviceInfo deviceInfo in ssdp.deviceInfoList) {
      hetima.UPnpPPPDevice pppDevice = new hetima.UPnpPPPDevice(deviceInfo);
      pppDevice.requestDeletePortMapping(48083, hetima.UPnpPPPDevice.VALUE_PORT_MAPPING_PROTOCOL_TCP).then((int v){
        portMappingResultInfoMemo.text = "portMappingResult:del:" + v.toString();
      });
    }
  });

  gelPortButton.onClick.listen((html.MouseEvent e) {
    if(ssdp == null) {
      return;
    }
    for (hetima.UPnpDeviceInfo deviceInfo in ssdp.deviceInfoList) {
      hetima.UPnpPPPDevice pppDevice = new hetima.UPnpPPPDevice(deviceInfo);
      pppDevice.requestGetGenericPortMapping(0).then((hetima.UPnpGetGenericPortMappingResponse s) {
        portMappingResultInfoMemo.text = "portMappingResult:get:"+ s.toString();        
      });
    }
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

