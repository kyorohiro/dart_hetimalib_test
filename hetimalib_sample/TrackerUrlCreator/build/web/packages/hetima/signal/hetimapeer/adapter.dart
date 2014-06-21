part of hetima_cl;

class AdapterCallerExpectedSignalClient extends CallerExpectSignalClient {
  SignalClient _mClient = null;
  HetimaPeer _mPeer = null;
  AdapterCallerExpectedSignalClient(HetimaPeer peer, SignalClient client) {
    _mClient = client;
    _mPeer = peer;
  }

  set client(SignalClient c) {
    _mClient = c;
  }

  void send(Caller caller, core.String to, core.String from, core.String type, core.String data) {
    core.print("signal client send");
    var pack = {};
    pack["action"] = "caller";
    pack["type"] = type;
    pack["data"] = data;
    _mClient.unicastPackage(to, from, pack);
  }

  void onReceiveMessageFromSignalServer(SignalMessageInfo message) {
    core.print("receive message from server :to=" + message.to + ",from=" + message.from + ",type=" + convert.UTF8.decode(message.pack["type"]));
    if (convert.UTF8.decode(message.pack["action"]) != "caller") {
      return;
    }
    core.String type = convert.UTF8.decode(message.pack["type"]);
    core.String data = convert.UTF8.decode(message.pack["data"]);
    PeerInfo targetPeer = _mPeer.getConnectedPeerInfo(message.from);
    onReceive(targetPeer.caller, message.to, message.from, type, data);
  }

}


class AdapterCESCCaller extends CallerExpectSignalClient {
  HetimaPeer _mPeer = null;

  AdapterCESCCaller(HetimaPeer peer) {
    _mPeer = peer;
  }

  void send(Caller caller, core.String to, core.String from, core.String type, core.String data) {
    core.print("[caller adapter] send "+to+","+from);
    var pack = {};
    pack["action"] = "caller";
    pack["type"] = type;
    pack["data"] = data;

    PeerInfo info = _mPeer.findPeerFromList(to);
    core.print("[caller adapter] ##("+info.relayCaller.targetUuid+")");

    _mPeer.requestRelayPackage(info.relayCaller.targetUuid, to, pack);
  }

  void onReceiveMessageFromCaller(MessageInfo message) {
    core.print("[caller adapter] receive message :to=" + message.to + ",from=" + message.from );
    //core.print("[caller adapter]## "+convert.JSON.encode(message.pack));
    
    if (message.pack["v"] == null || !(message.pack["v"] is core.Map)||
        message.pack["v"]["action"]==null) {
      core.print("[caller adapter] null");
      return;
    }
    if(convert.UTF8.decode(message.pack["v"]["action"]) != "caller") {
      core.print("[caller adapter] :action:" + convert.UTF8.decode(message.pack["v"]["action"]));
      return;
    }

    core.String type = convert.UTF8.decode(message.pack["v"]["type"]);
    core.String data = convert.UTF8.decode(message.pack["v"]["data"]);
    PeerInfo targetPeer = _mPeer.getConnectedPeerInfo(convert.UTF8.decode(message.pack["f"]));
    targetPeer.caller.setSignalClient(_mPeer._mCescaller);
    super.onReceive(targetPeer.caller, 
        message.to, 
        convert.UTF8.decode(message.pack["f"]), 
        type, data);
  }

}

