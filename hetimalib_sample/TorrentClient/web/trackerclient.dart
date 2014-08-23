import 'dart:html' as html;
import 'dart:convert' as conv;
import 'dart:async' as async;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetimacl;

hetima.TrackerClient client = new hetima.TrackerClient(new hetimacl.HetiSocketBuilderChrome());

void main() {
  
  html.Element startServerButton = new html.Element.html('<input id="startServerButton" type="button" value="startServer"> ');
  html.InputElement fileSelector = new html.Element.html("""<input type="file" id="files" name="file" />""");
  html.LabelElement memoField = new html.LabelElement();

  html.document.body.append(new html.Element.html("<div>### torrent file</div>"));
  html.document.body.append(fileSelector);
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(startServerButton);
  html.document.body.append(new html.Element.html("<div>### </div>"));
  html.document.body.append(memoField);

  startServerButton.onClick.listen((html.MouseEvent e){
    startServer();
  });
  fileSelector.onChange.listen((html.Event e) {
    memoField.innerHtml = "";
    html.File file = null;   
    for (html.File f in fileSelector.files) {
      file =f;
      print("==" + f.name);
      memoField.appendText("==" + f.name);
      memoField.appendHtml("<br>");
      break;
    }
    if(file == null) {return;}
    
    hetimacl.HetimaFileBlob hetimaFile = new hetimacl.HetimaFileBlob(file);
    hetima.HetimaBuilder builder = new hetima.HetimaFileToBuilder(hetimaFile);
    hetima.HetiBencode.decode(new hetima.EasyParser(builder)).then((Object o) {
      if(o is Map) {
        Map dict = o;
        for(Object k in dict.keys) {
          if(dict[k] != null) {
            print("="+dict[k].toString());
            memoField.appendText("#"+k.toString()+ "=" + dict[k].toString()+"");
            memoField.appendHtml("<br>");
          }
        }
      }
    }).catchError((e) {
      print("= parsr error");
      memoField.appendText("= parser error");
    });
  });

  
}

void startClient() {
  client.trackerHost = "";  
}

void startServer() {
  print("resizeWindow");
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
  print("##resizeWindow");
}
