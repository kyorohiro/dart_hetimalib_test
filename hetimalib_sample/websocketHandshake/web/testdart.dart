import 'dart:html' as html;
import 'package:hetima/hetima.dart'as hetima;
import 'package:hetima/hetima_cl.dart'as hetima;

hetima.SignalClient client = new hetima.SignalClient();
hetima.Caller caller = new hetima.Caller("test");
html.TextAreaElement localsdp = new html.Element.textarea();
html.TextAreaElement remotesdp = new html.Element.textarea();
AdapterSignalClient signalclient = new AdapterSignalClient();

void main() {
  print(""+hetima.Uuid.createUUID());
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

 // html.Element localsdp = new html.Element.textarea();
  localsdp.id = "localsdp";
 // html.Element remotesdp = new html.Element.textarea();
  remotesdp.id = "remotesdp";

  html.document.body.children.add(testButton);
  html.document.body.children.add(new html.Element.br());

  html.document.body.children.add(new html.Element.html("<div>local sdp</div>"));
  html.document.body.children.add(localsdp);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(new html.Element.html("<div>remote sdp</div>"));
  html.document.body.children.add(remotesdp);
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

}

void onClickTestButton(html.MouseEvent event) {
  print("--clicked test button");
// 
  if(hetima.SignalClient.OPEN == client.getState()) {
    client.sendText("hello");    
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
  signalclient.onReceive(caller, "offer", remotesdp.value);
}
void onSetAnswerButton(html.MouseEvent event) {
  print("--clicked set answer button¥n"+ remotesdp.value); 
  signalclient.onReceive(caller, "answer", remotesdp.value);
}

class CallerEventListener implements hetima.CallerEventListener {
    
}

class AdapterSignalClient extends hetima.CallerExpectSignalClient {
  void send(hetima.Caller caller, String toUUid, String from, String type, String data) {
    print("signal client send");
     localsdp.value = data;
  }
  void onReceive(hetima.Caller caller, String type, String data) {
    print("onreceive " + type+","+data);
    super.onReceive(caller, type, data);
  }
}
