part of hetima;

class TrackerRequest {

  String portAsString = "";
  String eventAsString = "";
  String infoHashAsString = "";
  String peeridAsString = "";
  String downloadedAsString = "";
  String uploadedAsString = "";
  String leftAsString = "";
  String address = "";
  List<int> ip = null;

  TrackerRequest.fromMap(Map<String, String> parameter, String _address, List<int> _ip) {
    portAsString = parameter[TrackerUrl.KEY_PORT];
    eventAsString = parameter[TrackerUrl.KEY_EVENT];
    infoHashAsString = parameter[TrackerUrl.KEY_INFO_HASH];
    peeridAsString = parameter[TrackerUrl.KEY_PEER_ID];
    downloadedAsString = parameter[TrackerUrl.KEY_DOWNLOADED];
    uploadedAsString = parameter[TrackerUrl.KEY_UPLOADED];
    leftAsString = parameter[TrackerUrl.KEY_LEFT];
    address = _address;
    ip = new List.from(_ip);
  }
  
  List<int> get infoHash => PercentEncode.decode(infoHashAsString).toList();
  List<int> get peerId => PercentEncode.decode(peeridAsString).toList();
  int get port => int.parse(portAsString);
}
