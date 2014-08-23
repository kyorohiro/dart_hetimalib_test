import 'dart:html' as html;
import 'dart:convert' as conv;
import 'dart:async' as async;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetimacl;

hetima.TrackerClient client = new hetima.TrackerClient(new hetimacl.HetiSocketBuilderChrome());
hetima.TorrentFile torrentFile = null;
html.LabelElement memoField = null;
void main() {
  
  html.Element startServerButton = new html.Element.html('<input id="startServerButton" type="button" value="startServer"> ');
  html.InputElement fileSelector = new html.Element.html("""<input type="file" id="files" name="file" />""");
  html.Element requestTrackerButton = new html.Element.html('<input id="requestTrackerButton" type="button" value="requestTracker"> ');
  memoField = new html.LabelElement();
  html.document.body.append(new html.Element.html("<div>### torrent file</div>"));
  html.document.body.append(fileSelector);
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(startServerButton);
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(requestTrackerButton);
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(memoField);

  startServerButton.onClick.listen((html.MouseEvent e){
    startServer();
  });
  requestTrackerButton.onClick.listen((html.MouseEvent e) {
    if(torrentFile == null) {
      return;
    }
    requestTracker(torrentFile);
  });

  fileSelector.onChange.listen((html.Event e) {
    memoField.innerHtml = "";
    html.File file = null;   
    if(fileSelector.files.length < 1){
      return;
    }
    startDecodeTorrentFile(fileSelector.files.last);
  });

}

void startDecodeTorrentFile(html.File file) {
  memoField.appendText("==" + file.name);
  memoField.appendHtml("<br>");

  hetimacl.HetimaFileBlob hetimaFile = new hetimacl.HetimaFileBlob(file);
  hetima.HetimaBuilder builder = new hetima.HetimaFileToBuilder(hetimaFile);
  hetima.TorrentFile.createTorrentFileFromTorrentFile(builder).then((hetima.TorrentFile f) {
    memoField.appendText("#"+f.mMetadata.toString());
    memoField.appendHtml("<br>");
    torrentFile = f;
  }).catchError((e) {
    print("= parsr error");
    memoField.appendText("= parser error");
  });
}

void startClient() {
  client.trackerHost = "";  
}

void startServer() {
  print("start server");
  hetimacl.HetiServerSocketChrome
  .startServer("127.0.0.1", 8088)
  .then((hetima.HetiServerSocket socket){
    socket.onAccept().listen((hetima.HetiSocket socket){
      socket.onReceive().listen((hetima.HetiReceiveInfo receive){
        print("receive");
      });
      socket.send(conv.UTF8.encode("hello")).then((hetima.HetiSendInfo info){
        new async.Future.delayed(const Duration(milliseconds: 3*1000),() {
          socket.close();
        });
      });
    });
  });
}

void requestTracker(hetima.TorrentFile file) {
  print("request tracker");
  if(torrentFile == null) {
    return;
  }
  hetima.TrackerClient client = new hetima.TrackerClient(new hetimacl.HetiSocketBuilderChrome());
  client.event = hetima.TrackerUrl.VALUE_EVENT_STARTED;
  client.updateFromMetaData(file).then((v){
    return client.request();
  }).then((hetima.TrackerRequestResult req) {
    if(hetima.TrackerRequestResult.OK == req.code) {
      print("request tracker ok");
    } else {
      print("request tracker error");      
    }
  });
}
