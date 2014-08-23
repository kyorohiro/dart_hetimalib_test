part of hetima_cl;

/**
 * 
 *  
 * 
 * 
 */
class Caller {
  /// don't have webrtc instance
  static final core.String RTC_ICE_STATE_ZERO = "zero";
 
  /// The ICE Agent is gathering addresses and/or waiting for remote candidates to be supplied.
  /// http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState  
  static final core.String RTC_ICE_STATE_NEW = "new";

  /// The ICE Agent has received remote candidates on at least one component, and is checking candidate pairs but has not yet found a connection. In addition to checking, it may also still be gathering.
  /// http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState
  static final core.String RTC_ICE_STATE_CHECKING = "checking";

  /// The ICE Agent has found a usable connection for all components but is still checking other candidate pairs to see if there is a better connection. It may also still be gathering.
  /// http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState  
  static final core.String RTC_ICE_STATE_CONNECTED = "connected";

  /// The ICE Agent has finished gathering and checking and found a connection for all components. Open issue: it is not clear how the non controlling ICE side knows it is in the state.
  /// http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState
  static final core.String RTC_ICE_STATE_COMPLEDTED = "completed";

  /// The ICE Agent is finished checking all candidate pairs and failed to find a connection for at least one component. Connections may have been found for some components.
  /// http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState
  static final core.String RTC_ICE_STATE_FAILED = "failed";

  /// Liveness checks have failed for one or more components. This is more aggressive than failed, and may trigger intermittently (and resolve itself without action) on a flaky network
  /// http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState.
  static final core.String RTC_ICE_STATE_DISCONNECTE = "disconnected";

  /// The ICE Agent has shut down and is no longer responding to STUN requests.
  /// http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState
  static final core.String RTC_ICE_STATE_CLOSED = "closed";

  html.RtcPeerConnection _connection = null;
  html.RtcDataChannel _datachannel = null;
  core.String _myuuid;
  core.String _targetuuid;
  CallerExpectSignalClient _signalclient;

  core.Map _stuninfo = {
    "iceServers": [{
        "url": "stun:stun.l.google.com:19302"
      }]
  };
  /*
   * http://stackoverflow.com/questions/21585681/send-image-data-over-rtc-data-channel
   * 
   * core.Map _mediainfo = {
   * 'optional': [{
   *     'RtpDataChannels': true
   *   }]
   * };
   */
  core.Map _mediainfo = {
    'optional': []
  };

  ///
  /// set application uuid;
  Caller(core.String uuid) {
    _myuuid = uuid;
  }

  core.String get targetUuid => _targetuuid;

  ///
  /// set connection/send/receive target application uuid. 
  Caller setTarget(uuid) {
    _targetuuid = uuid;
    return this;
  }

  ///
  /// set signal client. 
  /// signal client send or receive sdp data and ice candidate data, 
  Caller setSignalClient(CallerExpectSignalClient signalclient) {
    _signalclient = signalclient;
    return this;
  }

  async.StreamController<MessageInfo> _onReceiveStreamController = new async.StreamController.broadcast();
  
  ///
  /// when receive message, then notified/.
  async.Stream<MessageInfo> onReceiveMessage() {
    return _onReceiveStreamController.stream;    
  }

  async.StreamController<core.String> _onStatusChangeControleler = new async.StreamController.broadcast();

  ///
  /// when status change, then notified/.
  async.Stream<core.String> onStatusChange() {
    return _onStatusChangeControleler.stream;    
  }

  ///
  /// initialize
  Caller init() {
    return this;
  }

  ///
  /// start to connect
  Caller connect() {
    core.print("##[caller] connect "+ _myuuid+","+_targetuuid);
    _connection = new html.RtcPeerConnection(_stuninfo, _mediainfo);
    _connection.onIceCandidate.listen(_onIceCandidate);
    _connection.onDataChannel.listen(_onDataChannel);
    _connection.onAddStream.listen((html.MediaStreamEvent e){    core.print("#####[ww]#########onAddStream###");});
    _connection.onIceConnectionStateChange.listen((html.Event e){
      core.print("#####[ww]#########onIceConnectionStateChange###"+_connection.iceConnectionState+","+_connection.signalingState +","+_connection.iceGatheringState);
      _onStatusChangeControleler.add(_connection.iceConnectionState);
    });
    _connection.onNegotiationNeeded.listen((html.Event e){ 
      core.print("#####[ww]#########onNegotiationNeeded###"+_connection.iceConnectionState+","+_connection.signalingState);
      //createOffer();
    });
    _connection.onSignalingStateChange.listen((html.Event e){    core.print("#####[ww]#########onSignalingStateChange###"+_connection.iceConnectionState+","+_connection.signalingState);});
    _datachannel = _connection.createDataChannel("message");
    _datachannel.binaryType = "arraybuffer";
    _setChannelEvent(_datachannel);
    return this;
  }

  ///
  /// close 
  void close() {
    core.print("##[caller] close "+ _myuuid+","+_targetuuid);
    _connection.close();
  }

  ///
  /// create offer sdp.
  Caller createOffer() {
    core.print("##[caller] createOffer "+ _myuuid+","+_targetuuid);
    _connection.createOffer()
    .then(_onOffer)
    .catchError((){_onError("create offer");});
    return this;
  }

  ///
  /// create answer sdp.
  Caller createAnswer() {
    core.print("##[caller] createAnswer "+ _myuuid+","+_targetuuid);
    _connection.createAnswer()
    .then(_onAnswer)
    .catchError((){_onError("create answer");});
    return this;
  }

  ///
  /// set remote sdp
  void setRemoteSDP(core.String type, core.String sdp) {
    core.print("##[caller] setRemoteSdp "+ _myuuid+","+_targetuuid);
    html.RtcSessionDescription rsd = new html.RtcSessionDescription();
    rsd.sdp = sdp;
    rsd.type = type;
    _connection.setRemoteDescription(rsd);
  }

  ///
  /// add ice candidate
  void addIceCandidate(html.RtcIceCandidate candidate) {
    core.print("##[caller] addIceCandidate "+ _myuuid+","+_targetuuid);
    _connection.addIceCandidate(candidate, (){
      core.print("add ice ok");
    }, (core.String e){
      core.print("add ice ng"+e.toString());
    });
  }

  ///
  /// return RTC_ICE_STATE_xxxx
  core.String get status {
    if(_connection == null) {
      return RTC_ICE_STATE_ZERO;
    }
    return _connection.iceConnectionState;
  }

  ///
  /// set local sdp
  void setLocalSdp(html.RtcSessionDescription description) {
    core.print("##[caller] setLocalSdp "+ _myuuid+","+_targetuuid);
    _connection.setLocalDescription(description)
    .then(_onSuccessLocalSdp);//.then(_onError);
  }

  void _onIceCandidate(html.RtcIceCandidateEvent event) {
    if (event.candidate == null) {
      core.print("fin onIceCandidate");
    }
    else {
     if(_signalclient != null) {
       core.print("---caller#send : ice");
        _signalclient.send(this, _targetuuid, _myuuid, 
            "ice",convert.JSON.encode(IceTransfer.iceObj2Map(event.candidate)));
      }
    }
  }

  void _onSuccessLocalSdp(dynamic) {
      core.print("sucess set loca sdp¥n" + 
          _connection.localDescription.sdp.toString().substring(0,10)
          +"¥n");
      // send offer
      // send answer
      if(_signalclient != null) {
        core.print("---caller#send sdp : "+_connection.localDescription.type);
        _signalclient.send(this, _targetuuid, _myuuid, 
            _connection.localDescription.type,
            _connection.localDescription.sdp);
      }
  }

  void _onOffer(html.RtcSessionDescription sdp) {
    core.print("onOffer"+sdp.toString());
    setLocalSdp(sdp);
  }
  void _onAnswer(html.RtcSessionDescription sdp) {
    core.print("onAnswer"+sdp.toString());
    setLocalSdp(sdp);
  }

  void _onError(core.String event) {
    core.print("onerror "+event.toString());
  }

  void _onDataChannel(html.RtcDataChannelEvent event) {
    _datachannel = event.channel;
    _setChannelEvent(_datachannel);
  }

  ///
  /// sent text message
  void sendText(core.String text) {
    core.print("##[caller] sendText "+ _myuuid+","+_targetuuid);
    //_datachannel.sendString(text);
    core.Map pack = {};
    pack["action"] = "direct";
    pack["type"] = "text";
    pack["content"] = text;
    _datachannel.sendByteBuffer(Bencode.encode(pack).buffer);
  }

  ///
  /// send pack
  void sendPack(core.Map p) {
    core.print("##[caller] sendPack "+ _myuuid+","+_targetuuid);
    core.Map pack = {};
    pack["action"] = "pack";
    pack["type"] = "map";
    pack["content"] = p;
    //core.print(convert.JSON.encode(pack));
    _datachannel.sendByteBuffer(Bencode.encode(pack).buffer);
    core.print("-end-sendpack");    
  }
  void _onDataChannelReceiveMessage(html.MessageEvent event) {
    core.print("onReceiveMessage :" + event.data.runtimeType.toString());
    if(event.data is data.ByteBuffer) {
      core.print("###000");
      core.Map pack = Bencode.decode(new data.Uint8List.view(event.data as data.ByteBuffer));
      _onHandleDataChannelReceiveMessage(pack);
    }
    else if(event.data is data.Uint8List) {
      core.print("###001");
      core.Map pack = Bencode.decode(event.data as data.Uint8List);
      _onHandleDataChannelReceiveMessage(pack);
    }
  }

  void _onHandleDataChannelReceiveMessage(core.Map pack) {
    if(convert.UTF8.decode(pack["type"]) == "text") {
      _onReceiveStreamController.add(new MessageInfo(
          _targetuuid,
          "text", 
          convert.UTF8.decode(pack["content"]),
          {},
          this
      ));
    } else if(convert.UTF8.decode(pack["type"]) == "map") {
      _onReceiveStreamController.add(new MessageInfo(
          _targetuuid,
          "map", 
          "-",
          pack["content"],
          this
      ));
    }

  }

  void _onDataChannelOpen(html.Event event) {
    core.print("onOpenDataChannel:");
  }

  void _onDataChannelError(html.Event event) {
    core.print("onErrorDataChannel:"+event.toString());
  }

  void _onDataChannelClose(html.Event event) {
    core.print("onCloseDataChannel:");
  }

  void _setChannelEvent(html.RtcDataChannel channel) {
    channel.onMessage.listen(_onDataChannelReceiveMessage);
    channel.onOpen.listen(_onDataChannelOpen);
    channel.onError.listen(_onDataChannelError);
    channel.onClose.listen(_onDataChannelClose);
  }


}


class IceTransfer {
  static core.Map iceObj2Map(html.RtcIceCandidate candidate) {
    core.Map ret = {
       'candidate':candidate.candidate,
       'sdpMid':candidate.sdpMid,
       'sdpMLineIndex':candidate.sdpMLineIndex,
     };
    return ret;
  }
}

class MessageInfo {
  core.String _message = "";
  core.String _type = "";
  core.String _uuid = "";
  core.Map _pack = {};
  Caller caller;

  MessageInfo(core.String uuid, core.String type, core.String message, core.Map pack, Caller c) {
    _message = message; 
    _type =type;
    _pack = pack;
    caller = c;
  }
  core.String get from => caller.targetUuid;
  core.String get to=> caller._myuuid;
  core.String get uuid => _uuid;
  core.String get type => _type;
  core.String get message => _message;
  core.Map get pack => _pack;
}

///
///
///
class CallerExpectSignalClient {
  void send(Caller caller, core.String toUUid, core.String from, core.String type, core.String data) {
    ;
  }
  void onReceive(Caller caller, core.String to, core.String from, core.String type, core.String data) {
    switch (type) {
      case "answer":
      case "offer":
        core.print("##1## target=" + caller.targetUuid +",my="+caller._myuuid);
        caller.setRemoteSDP(type, data);
        core.print("##2##"+data);
        if(type =="offer") {
          core.print("##3## create answer");
          caller
          .setTarget(from)
          .createAnswer();
        }
        break;
      case "ice":
        core.print("##"+data+"##");
           html.RtcIceCandidate candidate =
               new html.RtcIceCandidate(convert.JSON.decode(data));
           core.print("add ice" + candidate.candidate+","+candidate.sdpMid+","+candidate.sdpMLineIndex.toString());
           caller.addIceCandidate(candidate);
          
        break;
    }
  }
}
