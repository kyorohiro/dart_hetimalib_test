part of hetima_cl;

class PeerInfo {
  Caller caller = null;
  core.String _uuid = null;
  SignalClient _relayClient = null;
  Caller _relayCaller = null;

  PeerInfo(core.String uuid) {
    _uuid = uuid;
  }
  core.String get uuid => _uuid;
  core.String get status {
    if (caller == null) {
      return Caller.RTC_ICE_STATE_ZERO;
    }
    return caller.status;
  }

  SignalClient get relayClient => _relayClient;
  Caller get relayCaller => _relayCaller;
  set relayClient(SignalClient client) {
    _relayClient = client;
  }

  set relayCaller(Caller caller) {
    _relayCaller = caller;
  }

}