import 'dart:html' as html;
import 'package:hetima/hetima.dart'as hetima_common;
import 'package:hetima/hetima_cl.dart'as hetima_cl;

hetima_cl.SignalClient client = new hetima_cl.SignalClient();
hetima_cl.Caller caller = new hetima_cl.Caller("test");
AdapterSignalClient signalclient = new AdapterSignalClient();
String myuuid = hetima_common.Uuid.createUUID();
html.SelectElement selectElement = new html.Element.select();


void main() {
  print(""+ myuuid);
  html.DivElement myid = new html.Element.html("<div>"+myuuid+"</div>");
  html.Element joinButton  = new html.Element.html(
  '<input id="joinbutton" type="button" value="join"> ');
  html.Element offerButton = new html.Element.html(
      '<input id="offerbutton" type="button" value="offer"> ');

  html.document.body.children.add(myid);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(joinButton);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(selectElement);
  html.document.body.children.add(new html.Element.br());

  html.document.body.children.add(new html.Element.html("<div>local sdp</div>"));
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(new html.Element.html("<div>remote sdp</div>"));
  html.document.body.children.add(new html.Element.br());

  html.document.body.children.add(offerButton);
  html.document.body.children.add(new html.Element.br());

  joinButton.onClick.listen(onClickJoinButton);
  offerButton.onClick.listen(onClickOfferButton);
  
  caller
  .setSignalClient(signalclient)
  .setTarget("dummy")
  .connect();

  client.addEventListener(new SignalClientListenerImple());
}

class SignalClientListenerImple implements hetima_cl.SignalClientListener {
  void updatePeer(List<String> uuidList) {
    updateItem(uuidList);
  }
  void onReceivePackage() {
  }
}
List<String> findedUuidList = new List();
void updateItem(List<String> newUuidList) {
  for(String u in newUuidList) {
    if(!findedUuidList.contains(u) && myuuid != u) {
      findedUuidList.add(u);
    }
  }
  for(html.OptionElement l in  selectElement.options) {
    l.remove();
  }
  for(int i=0;i<findedUuidList.length;i++) {
    html.OptionElement e = new html.Element.option();
    e.value = findedUuidList[i];
    e.text = findedUuidList[i];
    selectElement.append(e);
  }
}

void onClickJoinButton(html.MouseEvent event) {
  print("--clicked test button");
// 
  if(hetima_cl.SignalClient.OPEN == client.getState()) {
    client.sendJoin(myuuid);
  } else {
    client.connect().then((html.Event e){client.sendJoin(myuuid);});
  }
}

void onClickOfferButton(html.MouseEvent event) {
  print("--clicked offer button");
  caller.createOffer();
}
void onClickAnswerButton(html.MouseEvent event) {
  print("--clicked answer button");
  caller.createAnswer();
}  
void onSetOfferButton(html.MouseEvent event) {
  print("--clicked set offer button"); 
}
void onSetAnswerButton(html.MouseEvent event) {
  print("--clicked set answer button¥n"); 
}

class AdapterSignalClient extends hetima_cl.CallerExpectSignalClient {
  void send(hetima_cl.Caller caller, String toUUid, String from, String type, String data) {
    print("signal client send");
     {
        var pack = {};
        pack["action"] = "caller";
        pack["type"] = from;
        pack["data"] = data;
        client.unicastPackage(toUUid, from, pack);
     }
  }
  void onReceive(hetima_cl.Caller caller, String type, String data) {
    print("onreceive " + type+","+data);
    super.onReceive(caller, type, data);
  }
}
