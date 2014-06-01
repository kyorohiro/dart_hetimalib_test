
import 'package:chrome/chrome_app.dart' as chrome;
import 'dart:html' as html;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetima_cl;

void main() {

  html.DivElement drugdtopTag = new html.Element.html("""<div id="drugdrop">drug drop</div>""");
  html.InputElement fileSelector = new html.Element.html("""<input type="file" id="files" name="file" />""");
  html.TextAreaElement announceField = new html.Element.textarea();
  html.TextAreaElement nameField = new html.Element.textarea();
  announceField.value = "http://www.example.com/announce:6969";
  nameField.value = "test.data";

  html.TextAreaElement result = new html.Element.textarea();
  drugdtopTag.onDrop.listen((html.MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
    for(html.File f in e.dataTransfer.files) {
      createTorrent(f,
          announceField.value,
          nameField.value,
          result);
      break;
    }
  });
  drugdtopTag.onDragOver.listen((html.MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
  });

  fileSelector.onChange.listen((html.Event e){
    for(html.File f in fileSelector.files) {
      print("==" + f.name);
      createTorrent(f,
          announceField.value,
          nameField.value,
          result);
      break;
    }
  });
  drugdtopTag.style.width = "100px";
  drugdtopTag.style.height = "100px";
  drugdtopTag.style.backgroundColor = "#800080";

  html.document.body.children.add(new html.Element.html("<div> announce </div>"));
  html.document.body.children.add(announceField);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(new html.Element.html("<div> name </div>"));
  html.document.body.children.add(nameField);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(drugdtopTag);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(fileSelector);
  html.document.body.children.add(new html.Element.br());
  html.document.body.children.add(result);
  html.document.body.children.add(new html.Element.br());
}

void createTorrent(html.File f, String announce, String name,
                       html.TextAreaElement output) {
  hetima_cl.HetimaFileBlob file = new hetima_cl.HetimaFileBlob(f);
  hetima.TorrentFileCreator creator = new hetima.TorrentFileCreator();
  creator.announce = announce;
  creator.name = name;
  creator.createFromSingleFile(file).then((hetima.TorrentFileCreatorResult e){
    output.value = "##"+":"+convert.JSON.encode(e.torrentFile.mMetadata);
 });
  print("=1=" + f.name);
  print("=2=" + f.relativePath);
  print("=3=" + f.type);
  print("=4=" + f.toString());
}

