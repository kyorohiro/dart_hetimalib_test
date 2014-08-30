import 'dart:html' as html;
import 'dart:convert' as convert;
import 'package:chrome/chrome_app.dart' as chrome;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetimacl;

hetima.UpnpPortMapping  ssdp  = new hetima.UpnpPortMapping(new hetimacl.HetiSocketBuilderChrome());

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
    ssdp.searchWanPPPDevice();
  });
  getServiceButton.onClick.listen((html.MouseEvent e) {
    ssdp.extractService();
  });

}




