
import 'package:chrome/chrome_app.dart' as chrome;
import 'dart:html' as html;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'package:hetima/hetima.dart' as hetima;

void main() {
  html.DivElement drugdtopTag = new html.Element.html("""<div id="drugdrop">drug drop</div>""");
  html.InputElement fileSelector = new html.Element.html("""<input type="file" id="files" name="file" />""");
  html.TextAreaElement result = new html.Element.textarea();
  drugdtopTag.onDrop.listen((html.MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
    for(html.File f in e.dataTransfer.files) {
      html.FileReader reader = new html.FileReader();
      reader.readAsArrayBuffer(f);
      reader.onLoadEnd.listen((html.ProgressEvent e){
        print("==" + reader.result.runtimeType.toString());
        result.value = "##"+":"+createTorrentFileInfo(reader.result);
      });
      print("==" + f.name);
      print("==" + f.relativePath);
      print("==" + f.type);
    }
  });
  drugdtopTag.onDragOver.listen((html.MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
  });

  fileSelector.onChange.listen((html.Event e){
    for(html.File f in fileSelector.files) {
      print("==" + f.name);
    }
  });
  drugdtopTag.style.width = "100px";
  drugdtopTag.style.height = "100px";
  drugdtopTag.style.backgroundColor = "#800080";
 
  html.document.body.children.add(drugdtopTag);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(fileSelector);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(result);
  html.document.body.children.add(new html.Element.br());
}

String createTorrentFileInfo(type.Uint8List buffer) {
  print("==torrent info");
  try {
    Object o = hetima.Bencode.decode(buffer);
    return "ok:"+convert.JSON.encode(o);
  } catch(E) {
    return "error:"+E.toString();
  }
}
