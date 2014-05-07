import 'dart:html' as html;
import 'package:hetima/hetima.dart'as hetima;
import 'package:hetima/hetima_cl.dart'as hetima;

hetima.SignalClient client = new hetima.SignalClient();
hetima.Caller caller = new hetima.Caller("test");
AdapterSignalClient signalclient = new AdapterSignalClient();
String myuuid = hetima.Uuid.createUUID();
html.SelectElement selectElement = new html.Element.select();


void main() {
  print(""+ myuuid);
  html.Element testButton  = new html.Element.html(
  '<input id="testbutton" type="button" value="test"> ');
  html.Element offerButton = new html.Element.html(
      '<input id="offerbutton" type="button" value="offer"> ');
  html.Element answerbutton = new html.Element.html(
      '<input id="answerbutton" type="button" value="answer"> ');
  html.Element setremotesdpForAnswer = new html.Element.html(
      '<input id="setrenotesdp_answer" type="button" value="setrenotesdp(answer)"> ');
  html.Element setremotesdpForOffer = new html.Element.html(
      '<input id="setrenotesdp_offer" type="button" value="setrenotesdp(offer)"> ');

  html.document.body.children.add(testButton);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(selectElement);
  html.document.body.children.add(new html.Element.br());

  html.document.body.children.add(new html.Element.html("<div>local sdp</div>"));
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(new html.Element.html("<div>remote sdp</div>"));
  html.document.body.children.add(new html.Element.br());

  html.document.body.children.add(offerButton);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(answerbutton);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(setremotesdpForAnswer);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(setremotesdpForOffer);
  html.document.body.children.add(new html.Element.br());

  testButton.onClick.listen(onClickTestButton);
  offerButton.onClick.listen(onClickOfferButton);
  answerbutton.onClick.listen(onClickAnswerButton);
  setremotesdpForAnswer.onClick.listen(onSetAnswerButton);
  setremotesdpForOffer.onClick.listen(onSetOfferButton);
  
  caller
  .setSignalClient(signalclient)
  .setTarget("dummy")
  .connect();

  client.addEventListener(new SignalClientListenerImple());
}

class SignalClientListenerImple implements hetima.SignalClientListener {
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
      findedUuidList.addAll(newUuidList);
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

void onClickTestButton(html.MouseEvent event) {
  print("--clicked test button");
// 
  if(hetima.SignalClient.OPEN == client.getState()) {
    client.sendJoin(myuuid);
//    client.sendText("hello");    
  } else {
    client.init();
  }
  //caller.createOffer();
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

class AdapterSignalClient extends hetima.CallerExpectSignalClient {
  void send(hetima.Caller caller, String toUUid, String from, String type, String data) {
    print("signal client send");
     {
        var pack = {};
        pack["action"] = "caller";
        pack["type"] = from;
        pack["data"] = data;
        client.unicastPackage(toUUid, from, pack);
     }
  }
  void onReceive(hetima.Caller caller, String type, String data) {
    print("onreceive " + type+","+data);
    super.onReceive(caller, type, data);
  }
}