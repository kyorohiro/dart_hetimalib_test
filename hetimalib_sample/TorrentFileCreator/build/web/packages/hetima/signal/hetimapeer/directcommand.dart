part of hetima_cl;
class DirectCommand {
  HetimaPeer _mPeer = null;
  DirectCommand(HetimaPeer peer) {
    core.print("=[direct command]= new");
    _mPeer = peer;
  }

  void requestFindNode(core.String toUuid, core.String target) {
    core.print("=[direct command]= request find node");
    PeerInfo peerinfo = _mPeer.findPeerFromList(toUuid);
    if (peerinfo == null || peerinfo.caller == null) {
      core.print("--not found");
      return;
    }
    core.Map pack = {};
    pack["m"] = "request";
    pack["a"] = "findnode";
    pack["v"] = target;
    peerinfo.caller.sendPack(pack);
    core.print("--dd");
  }

  void handleFindnode(MessageInfo message) {
    core.print("=[direct command]= handlefindnode");
    if (convert.UTF8.decode(message.pack["a"]) != "findnode") {
      return;
    }
    if (convert.UTF8.decode(message.pack["m"]) == "request") {
      core.print("xxxxxxxxxxxxxxx findnode -001");
      core.Map pack = {};
      pack["m"] = "response";
      pack["a"] = "findnode";
      core.List peers = pack["v"] = new core.List<core.String>();
      core.List<PeerInfo> infos = _mPeer.getPeerList();
      for (core.int i = 0; i < infos.length; i++) {
        if (infos[i].status == Caller.RTC_ICE_STATE_CONNECTED || infos[i].status == Caller.RTC_ICE_STATE_COMPLEDTED) {
          peers.add(infos[i].uuid);
        }
      }
      message.caller.sendPack(pack);
    } else {
      core.print("xxxxxxxxxxxxxxx findnode nnnn");
      core.List<core.String> uuidList = new core.List();
      core.List<data.Int8List> cashList = message.pack["v"];
      for (core.int i = 0; i < cashList.length; i++) {
        uuidList.add(convert.UTF8.decode(cashList[i]));
      }
      _mPeer._onInternalUpdatePeerInfo(uuidList, null, message.caller);
    }
  }

  void requestUnicastPackage(core.String toUuid, core.String relayUuid, core.String fromUuid, core.Map p) {
    core.print("=[direct command]= handleUnicastPackage t="+toUuid+",r="+relayUuid+",f="+fromUuid);
    PeerInfo peerinfo = _mPeer.findPeerFromList(relayUuid);
    if (peerinfo == null || peerinfo.caller == null) {
      return;
    }
    core.Map pack = {};
    pack["m"] = "request";
    pack["a"] = "unicast";
    pack["v"] = p;
    pack["t"] = toUuid;
    pack["r"] = relayUuid;
    pack["f"] = fromUuid;
    core.print("=[direct command]= sp m="+peerinfo.uuid+",t="+peerinfo.caller.targetUuid);
    peerinfo.caller.sendPack(pack);
  }

  void handleUnicastPackage(MessageInfo message) {
    core.print("=[direct command]= handleUnicastPackage");

     if (convert.UTF8.decode(message.pack["a"]) != "unicast") {
       return;
     }

     if (convert.UTF8.decode(message.pack["m"]) == "request") {
       if(convert.UTF8.decode(message.pack["t"]) == _mPeer.id) {
         return;
       }
       core.String toUuid = convert.UTF8.decode(message.pack["t"]);
       PeerInfo info = _mPeer.findPeerFromList(toUuid);
       if(info == null) {
         core.print("xxxxxxxxxxxxxxx sdfsdfasdfad[E] null");         
       }
       core.Map pack = {};
       pack["m"] = "response";
       pack["a"] = message.pack["a"];
       pack["v"] = message.pack["v"];
       pack["t"] = message.pack["t"];
       pack["r"] = message.pack["r"];
       pack["f"] = message.pack["f"];
       info.caller.sendPack(pack);
     } else {
       _mPeer._mRelayPackage.add(new RelayPackageInfo(message.pack["v"]));
       message.pack["r"];
       core.List<core.String> uuidList = new core.List();
       PeerInfo info = _mPeer.findPeerFromList(message.from);
       uuidList.add(convert.UTF8.decode(message.pack["f"]));
       _mPeer._onInternalUpdatePeerInfo(uuidList, null, info.caller);
       core.print("xxxxxxxxxxxxxxx request unicast ---------------------[B]");
     }  
  }
  
  void onReceiveMessage(MessageInfo message) {
    if ("map" == message.type) {
      core.String action = convert.UTF8.decode(message.pack["a"]);
      if (action == "findnode") {
        handleFindnode(message);
      } 
      else if(action == "unicast") {
        handleUnicastPackage(message);
      }
    }
  }
}
