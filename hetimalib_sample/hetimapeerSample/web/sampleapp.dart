import 'dart:html' as html;
import 'dart:convert' as convert;
import 'package:hetima/hetima.dart' as hetima_common;
import 'package:hetima/hetima_cl.dart' as hetima_cl;

html.SelectElement selectElement = new html.Element.select();
html.TextAreaElement receiveMessage = new html.Element.textarea();
html.TextAreaElement sendMessage = new html.Element.textarea();

hetima_cl.HetimaPeer peer = new hetima_cl.HetimaPeer();

void main() {
  print("" + peer.id);

  html.DivElement myid = new html.Element.html("<div>" + peer.id + "</div>");
  html.Element joinButton = new html.Element.html('<input id="joinbutton" type="button" value="join"> ');
  html.Element findnodeButton = new html.Element.html('<input id="findenode" type="button" value="findnode"> ');
  html.Element offerButton = new html.Element.html('<input id="offerbutton" type="button" value="offer"> ');
  receiveMessage.id = "receive";
  html.Element sendButton = new html.Element.html('<input id="sendbutton" type="button" value="send"> ');
  html.Element relayButton = new html.Element.html('<input id="relaybutton" type="button" value="relay message"> ');

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
  html.document.body.children.add(findnodeButton);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(relayButton);
  html.document.body.children.add(new html.Element.br());

  joinButton.onClick.listen(onClickJoinButton);
  offerButton.onClick.listen(onClickOfferButton);
  sendButton.onClick.listen(onClickSendButton);
  findnodeButton.onClick.listen(onClickFindnodeButton);
  relayButton.onClick.listen(onClickRelayButton);

  peer.onFindPeer().listen(updateItem);
  peer.onMessage().listen(onReceiveMessage);
  peer.onStatusChange().listen(onStatusChange);
  peer.onRelayPackage().listen(onRelayPackage);
}

void onReceiveMessage(hetima_cl.MessageInfo info) {
  receiveMessage.value += info.message;
}

void onRelayPackage(hetima_cl.RelayPackageInfo info) {
  if (info.pack == null) {
    return;
  }
  if (info.pack["message"] != null) {
    receiveMessage.value += (convert.UTF8.decode(info.pack["message"]));
  }
}

void onStatusChange(hetima_cl.StatusChangeInfo info) {
  updateItem(new List<String>());
}
void updateItem(List<String> newUuidList) {
  print("##11 :" + newUuidList.length.toString());
  for (html.OptionElement l in selectElement.options) {
    l.remove();
  }
  List<hetima_cl.PeerInfo> infos = peer.getPeerList();
  if (infos == null) {
    return;
  }
  for (int i = 0; i < infos.length; i++) {
    hetima_cl.PeerInfo info = infos[i];
    html.OptionElement e = new html.Element.option();
    e.value = info.uuid.toString();
    e.text = "-" + info.status.toString() + "," + info.uuid.toString();
    if (info.relayCaller != null) {
      e.text = "relayable-" + e.text;
    }
    selectElement.append(e);
  }
}


void onClickFindnodeButton(html.MouseEvent event) {
  print("--clicked findnode button " + selectElement.value);
  peer.requestFindNode(selectElement.value, selectElement.value);
}

void onClickJoinButton(html.MouseEvent event) {
  print("--clicked test button");
  peer.connectJoinServer();
}

void onClickRelayButton(html.MouseEvent event) {
  print("--clicked relay button");
  hetima_cl.PeerInfo info = peer.findPeerFromList(selectElement.value);
  if (info.relayCaller == null) {
    if (info.relayCaller == null) {
      print("null relay");
    }
  }
  Map pack = {};
  pack["message"] = "hello";
  peer.requestRelayPackage(info.relayCaller.targetUuid, info.uuid, pack);
}

void onClickOfferButton(html.MouseEvent event) {
  print("--clicked offer button " + selectElement.value);
  if (selectElement.value.length == 0) {
    return;
  }
  peer.connectPeer(selectElement.value);
}

void onClickSendButton(html.MouseEvent event) {
  print("--clicked send button " + selectElement.value);
  peer.sendMessage(selectElement.value, sendMessage.value);
}
