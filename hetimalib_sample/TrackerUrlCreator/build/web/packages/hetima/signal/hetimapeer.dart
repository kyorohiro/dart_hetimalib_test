part of hetima_cl;

/**
 * 
 * 
 */
class HetimaPeer {
  SignalClient mClient = null;
  core.List<PeerInfo> mPeerInfoList = new core.List();
  core.String _mMyId = Uuid.createUUID();
  AdapterCallerExpectedSignalClient _mAdapterSignalClient;
  AdapterCESCCaller _mCescaller;
  DirectCommand _mAdapterResponser;

  async.StreamController<core.List<core.String>> _mSignalFindPeer = new async.StreamController.broadcast();
  async.StreamController<MessageInfo> _mCallerReceiveMessage = new async.StreamController.broadcast();
  async.StreamController<StatusChangeInfo> _mStatusChange = new async.StreamController.broadcast();
  async.StreamController<RelayPackageInfo> _mRelayPackage = new async.StreamController.broadcast();

  HetimaPeer() {
    core.print("-[hetimapeer]-new HetimaPeer :");
    mClient = new SignalClient();
    _mAdapterSignalClient = new AdapterCallerExpectedSignalClient(this, mClient);
    _mAdapterResponser = new DirectCommand(this);
    _mCescaller = new AdapterCESCCaller(this);
  }

  void showDebug() {
    core.print("start show debug");
    for (core.int i = 0; i < mPeerInfoList.length; i++) {
      core.print("" + mPeerInfoList[i].uuid);
    }
    core.print("end show debug");
  }
  void connectJoinServer() {
    core.print("-[hetimapeer]-connectJoinServer :");
    if (mClient.getState() == SignalClient.CLOSED) {
      mClient = new SignalClient();
    }
    mClient.onFindPeer().listen((core.List<core.String> uuidList) {
      _onInternalUpdatePeerInfo(uuidList, mClient, null);
    });
    mClient.onReceiveMessage().listen(_mAdapterSignalClient.onReceiveMessageFromSignalServer);

    mClient.connect().then((html.Event e) {
      mClient.sendJoin(_mMyId);
    });
  }

  void connectPeer(core.String uuid) {
    core.print("-[hetimapeer]-connectPeer :" + uuid);
    PeerInfo peerInfo = findPeerFromList(uuid);
    if (peerInfo == null || peerInfo.caller != null) {
      return;
    }
    peerInfo.caller = createCaller(uuid, _mAdapterSignalClient);
    peerInfo.caller.connect().createOffer();
  }

  void sendMessage(core.String uuid, core.String message) {
    core.print("-[hetimapeer]-sendMessage :" + uuid + "." + message);
    PeerInfo peerInfo = findPeerFromList(uuid);
    if (peerInfo == null || peerInfo.caller == null) {
      return;
    }
    peerInfo.caller.sendText(message);
  }

  async.Stream<core.List<core.String>> onFindPeer() => _mSignalFindPeer.stream;
  async.Stream<MessageInfo> onMessage() => _mCallerReceiveMessage.stream;
  async.Stream<StatusChangeInfo> onStatusChange() => _mStatusChange.stream;
  async.Stream<RelayPackageInfo> onRelayPackage() => _mRelayPackage.stream;


  core.int get status => mClient.getState();
  core.String get id => _mMyId;

  void joinNetwork() {
    core.print("-[hetimapeer]-joinNetwork :");
    if (mClient == null || mClient.getState() == SignalClient.CLOSED || mClient.getState() == SignalClient.CLOSING) {
      mClient = new SignalClient();
    }
    if (mClient.getState() != SignalClient.CONNECTING) {
      mClient.connect();
    }
  }

  core.List<PeerInfo> getPeerList() {
    core.print("-[hetimapeer]-getPeerList :");
    return mPeerInfoList;
  }

  PeerInfo findPeerFromList(core.String uuid) {
    core.print("-[hetimapeer]-findPeerFromList :" + uuid);
    for (core.int i = 0; i < mPeerInfoList.length; i++) {
      if (mPeerInfoList[i].uuid == uuid) {
        return mPeerInfoList[i];
      }
    }
    return null;
  }

  void addPeerInfo(PeerInfo info) {
    core.print("-[hetimapeer]-addPeerInfo :m=" + info.uuid);
    mPeerInfoList.add(info);
  }

  PeerInfo getConnectedPeerInfo(core.String uuid) {
    core.print("-[hetimapeer]-getConnectedPeerInfo :" + uuid);
    PeerInfo targetPeer = findPeerFromList(uuid);
    if (targetPeer == null) {
      targetPeer = new PeerInfo(uuid);
      addPeerInfo(targetPeer);
    }
    if (targetPeer.caller == null) {
      targetPeer.caller = createCaller(uuid, _mAdapterSignalClient);
      targetPeer.caller.connect();
    }
    return targetPeer;
  }

  void _onInternalUpdatePeerInfo(core.List<core.String> uuidList, SignalClient client, Caller caller) {
     core.print("-[hetimapeer]- find peer from server :" + uuidList.length.toString());
     core.List<core.String> adduuid = new core.List();
     for (core.String uuid in uuidList) {
       if (uuid == _mMyId) {continue;}
       core.print("xxxxxxxxxxxxxxx findnode =" + uuid);
       PeerInfo peerInfo = findPeerFromList(uuid);
       if (peerInfo == null) {
         peerInfo = new PeerInfo(uuid);
         addPeerInfo(peerInfo);
       }
       if (client != null) { peerInfo.relayClient = client;}
       if (caller != null) { peerInfo.relayCaller = caller;}
     }
     _mSignalFindPeer.add(adduuid);
   }

  Caller createCaller(core.String targetUUID, CallerExpectSignalClient esclient) {
    core.print("-[hetimapeer]-createCaller :t=" + targetUUID + ",m=" + _mMyId);
    Caller newCaller = new Caller(_mMyId);
    newCaller.setSignalClient(esclient);
    newCaller.setTarget(targetUUID);
    newCaller.onReceiveMessage().listen((MessageInfo info) {_mCallerReceiveMessage.add(info);});
    newCaller.onReceiveMessage().listen(_mAdapterResponser.onReceiveMessage);
    newCaller.onReceiveMessage().listen(_mCescaller.onReceiveMessageFromCaller);
    newCaller.onStatusChange().listen((core.String s) {_mStatusChange.add(new StatusChangeInfo(s));});
    return newCaller;
  }

  void requestFindNode(core.String toUuid, core.String target) {
    core.print("-[hetimapeer]-requestFindNode :" + toUuid + "," + target);
    _mAdapterResponser.requestFindNode(toUuid, target);
  }

  void requestRelayPackage(core.String relayUuid, core.String toUuid, core.Map pack) {
    core.print("-[hetimapeer]-requestRelayPackage :" + toUuid + "," + relayUuid + "," + convert.JSON.encode(pack).length.toString());
    _mAdapterResponser.requestUnicastPackage(toUuid, relayUuid, this.id, pack);
  }

  void requestRelayConnectPeer(core.String relayUuid, core.String toUuid) {
    core.print("-[hetimapeer]-requestRelayConnectPeer :" + toUuid + "," + relayUuid);
    PeerInfo peerInfo = findPeerFromList(toUuid);
    if (peerInfo == null) {
      core.print("--not found");
      showDebug();
      return;
    }

    PeerInfo relayInfo = findPeerFromList(relayUuid);
    if (relayInfo == null || relayInfo.caller == null) {
      core.print("--not found");
      showDebug();
      return;
    }

    peerInfo.caller = createCaller(toUuid, _mCescaller);
    peerInfo.caller.connect().createOffer();
  }

}


class StatusChangeInfo {
  core.String status = "";
  StatusChangeInfo(core.String s) {
    status = s;
  }
}

class RelayPackageInfo {
  core.Map pack;
  RelayPackageInfo(core.Map p) {
    pack = p;
  }
}
