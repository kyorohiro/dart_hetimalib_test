import 'dart:html' as html;
import 'dart:convert' as convert;
import 'package:hetima/hetima.dart' as hetima_common;
import 'package:hetima/hetima_cl.dart' as hetima_cl;

String myuuid = hetima_common.Uuid.createUUID();
hetima_cl.SignalClient client = new hetima_cl.SignalClient();
AdapterSignalClient signalclient = new AdapterSignalClient();
html.SelectElement selectElement = new html.Element.select();
html.TextAreaElement receiveMessage = new html.Element.textarea();
html.TextAreaElement sendMessage = new html.Element.textarea();

hetima_cl.Caller caller = new hetima_cl.Caller(myuuid);

void main() {
  print("" + myuuid);
  html.DivElement myid = new html.Element.html("<div>" + myuuid + "</div>");
  html.Element joinButton = new html.Element.html('<input id="joinbutton" type="button" value="join"> ');
  html.Element offerButton = new html.Element.html('<input id="offerbutton" type="button" value="offer"> ');
  receiveMessage.id = "receive";
  html.Element sendButton = new html.Element.html('<input id="sendbutton" type="button" value="send"> ');

  html.document.body.children.add(myid);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(joinButton);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(selectElement);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(offerButton);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(new html.Element.html('<div>send</div>'));
  html.document.body.children.add(sendMessage);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(new html.Element.html('<div>receive</div>'));
  html.document.body.children.add(receiveMessage);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(sendButton);
  html.document.body.children.add(new html.Element.br());

  joinButton.onClick.listen(onClickJoinButton);
  offerButton.onClick.listen(onClickOfferButton);
  sendButton.onClick.listen(onClickSendButton);
  caller.setSignalClient(signalclient).setTarget("dummy").connect();
  caller.onReceiveMessage().listen(onReceiveMessage);
  client.onFindPeer().listen(onFindPeerFromSignalServer);
  client.onReceiveMessage().listen(onReceiveMessageFromSignalServer);
}

void onReceiveMessage(hetima_cl.MessageInfo info) {
  receiveMessage.value += info.message;
}

void onFindPeerFromSignalServer(List<String> uuidList) {
  updateItem(uuidList);
}

void onReceiveMessageFromSignalServer(hetima_cl.SignalMessageInfo message) {
  print("########");
  Map pack = message.pack;
  String to = message.to;
  String from = message.from;

  if (convert.UTF8.decode(pack["action"]) != "caller") {
    return;
  }
  String type = convert.UTF8.decode(pack["type"]);
  String data = convert.UTF8.decode(pack["data"]);
  signalclient.onReceive(caller, to, from, type, data);
}

List<String> findedUuidList = new List();
void updateItem(List<String> newUuidList) {
  for (String u in newUuidList) {
    if (!findedUuidList.contains(u) && myuuid != u) {
      findedUuidList.add(u);
    }
  }
  for (html.OptionElement l in selectElement.options) {
    l.remove();
  }
  for (int i = 0; i < findedUuidList.length; i++) {
    html.OptionElement e = new html.Element.option();
    e.value = findedUuidList[i];
    e.text = findedUuidList[i];
    selectElement.append(e);
  }
}

void onClickJoinButton(html.MouseEvent event) {
  print("--clicked test button");
  //
  if (hetima_cl.SignalClient.OPEN == client.getState()) {
    client.sendJoin(myuuid);
  } else {
    client.connect().then((html.Event e) {
      client.sendJoin(myuuid);
    });
  }
}

void onClickOfferButton(html.MouseEvent event) {
  print("--clicked offer button " + selectElement.value);
  caller.setTarget(selectElement.value).createOffer();
}

void onClickSendButton(html.MouseEvent event) {
  print("--clicked send button " + selectElement.value);
  String message = sendMessage.value;
  caller.sendText(message);
}

class AdapterSignalClient extends hetima_cl.CallerExpectSignalClient {
  void send(hetima_cl.Caller caller, String to, String from, String type, String data) {
    print("signal client send");
    {
      var pack = {};
      pack["action"] = "caller";
      pack["type"] = type;
      pack["data"] = data;
      client.unicastPackage(to, from, pack);
    }
  }
  void onReceive(hetima_cl.Caller caller, String to, String from, String type, String data) {
    print("onreceive to=" + to + "from=" + from + "type=" + type + ",data=" + data.substring(0, 10));
    super.onReceive(caller, to, from, type, data);
  }
}
