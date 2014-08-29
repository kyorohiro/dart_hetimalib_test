import 'dart:html' as html;
import 'dart:convert' as convert;
import 'package:chrome/chrome_app.dart' as chrome;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetimacl;
SSDP ssdp = new SSDP();
html.LabelElement memoField = null;
void main() {
  html.Element requestDiscover = new html.Element.html('<input id="requestDiscoverButton" type="button" value="requestDiscover"> ');
  html.Element bindjoinNetwork = new html.Element.html('<input id="bindjoinNetworkButton" type="button" value="bindjoinNetwork"> ');
  html.Element getServiceButton = new html.Element.html('<input id="getServiceNetworkButton" type="button" value="getServiceNetwork"> ');

  memoField = new html.LabelElement();
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(bindjoinNetwork);

  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(requestDiscover);

  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(getServiceButton);

  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(memoField);

  bindjoinNetwork.onClick.listen((html.MouseEvent e) {
    ssdp.init();
  });
  requestDiscover.onClick.listen((html.MouseEvent e) {
    ssdp.send();
  });
  getServiceButton.onClick.listen((html.MouseEvent e) {
    ssdp.extractService();
  });

}




class SSDP {
  static String SSDP_ADDRESS = "239.255.255.250";
  static int SSDP_PORT = 1900;
  static String SSDP_M_SEARCH = """M-SEARCH * HTTP/1.1\r\n""" + """MX: 3\r\n""" + """HOST: 239.255.255.250:1900\r\n""" + """MAN: "ssdp:discover"\r\n""" + """ST: upnp:rootdevice\r\n""" + """\r\n""";
  chrome.CreateInfo i = null;

  List<String> locationList = new List();
  void init() {
    memoField.innerHtml = "";
    chrome.sockets.udp.onReceive.listen(onReceive);
    chrome.sockets.udp.create().then((chrome.CreateInfo info) {
      i = info;
        return chrome.sockets.udp.setMulticastLoopbackMode(i.socketId, false);
      }).then((int v) {
      return chrome.sockets.udp.bind(i.socketId, "0.0.0.0", 0);
      //}).then((int v){
      // return chrome.sockets.udp.joinGroup(i.socketId, "239.255.255.250");
    }).then((int v) {
      memoField.appendHtml("created udp socket");
    }).catchError((e){
      memoField.appendHtml("failed to created udp socket");
    });
  }

  void onReceive(chrome.ReceiveInfo info) {
    print("########");
    print("" + convert.UTF8.decode(info.data.getBytes()));

    print("########");
    extractLocation(info.data.getBytes());
  }

  void extractLocation(List<int> buffer) {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    builder.appendIntList(buffer, 0, buffer.length);
    hetima.HetiHttpResponse.decodeHttpMessage(parser).then((hetima.HetiHttpMessageWithoutBody message) {
      print("===");
     for (hetima.HetiHttpResponseHeaderField field in message.headerField) {
        print("name:" + field.fieldName + "=value:" + field.fieldValue);
     }
      print("===");
      hetima.HetiHttpResponseHeaderField f = message.find("location");
      if(f != null) {
        if(!locationList.contains(f.fieldValue)) {
        locationList.add(f.fieldValue);
        memoField.appendHtml("##"+f.fieldValue);
        memoField.appendHtml("<br>");
        }

      }
    });
  }
  
  void extractService() {
    for(String location in locationList) {
      hetima.HetiHttpClient client = new hetima.HetiHttpClient(new hetimacl.HetiSocketBuilderChrome());
      hetima.HttpUrl url = hetima.HttpUrlDecoder.decodeUrl(location);
      client.connect(url.host, url.port).then((int d) {
/*      if(url.query.length != 0) {
        client.get(url.path+"?"+url.query).then((hetima.HetiHttpClientResponse res) {
          res.body.onFin().then((b){
            res.body.getLength().then((int length) {
              res.body.getByteFuture(0, length).then((List<int> v) {
                  print(""+convert.UTF8.decode(v));                
              });
            });
          });
        }).catchError((e){
          print("##err SDFSDf");          
        });
      } else */{
        client.get(url.path).then((hetima.HetiHttpClientResponse res) {
          hetima.HetiHttpResponseHeaderField field = res.message.find(hetima.RfcTable.HEADER_FIELD_CONTENT_LENGTH);
          if(field != null&& 0<field.fieldValue.length) {
           int len =  int.parse(field.fieldValue);
           return res.body.getByteFuture(0, len).then((List<int> v) {
             print("SDFS=DFSDFF=S=DFSDFDF");  
             print(""+convert.UTF8.decode(v));
             client.close();
           });
          }
          else {
          return res.body.onFin().then((b){
            res.body.getLength().then((int length) {
              res.body.getByteFuture(0, length).then((List<int> v) {
                print("SDFS=DFSDFF=S=DFSDFDFfFFFF");  
                  print(""+convert.UTF8.decode(v));                
              });
            });
          });
          }
        }).catchError((e){
          print("##err SDFSDf");          
        });
      }
      });
    }
  }

  void send() {
    memoField.innerHtml = "";
    chrome.ArrayBuffer buffer = new chrome.ArrayBuffer.fromBytes(convert.UTF8.encode(SSDP_M_SEARCH));
    chrome.sockets.udp.send(i.socketId, buffer, SSDP_ADDRESS, SSDP_PORT).then((chrome.SendInfo iii) {
      print("###send=" + iii.resultCode.toString());
    });
    //ssdpclient.dart.js
  }
}
