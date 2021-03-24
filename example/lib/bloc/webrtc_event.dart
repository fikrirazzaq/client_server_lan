part of 'webrtc_bloc.dart';

@immutable
abstract class WebRtcEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class WebRtcSetReady extends WebRtcEvent {
  final List<WebRTCPeer> serverPeers;
  final WebRTCPeer clientPeer;
  final bool isServer;

  WebRtcSetReady({this.serverPeers, this.clientPeer, this.isServer});

  @override
  List<Object> get props => [serverPeers, clientPeer, isServer];

  @override
  String toString() =>
      'WebRtcSetReady(serverPeers: $serverPeers, clientPeer: $clientPeer, isServer: $isServer)';
}

class WebRtcOfferCon extends WebRtcEvent {
  final String clientName;

  WebRtcOfferCon({@required this.clientName});

  @override
  List<Object> get props => [clientName];

  @override
  String toString() => 'WebRtcOfferCon {}';
}

class WebRtcAnswerCon extends WebRtcEvent {
  final String clientName;
  final RTCSessionDescription offer;

  WebRtcAnswerCon({
    @required this.clientName,
    @required this.offer,
  });

  @override
  List<Object> get props => [clientName, offer];
}

class WebRtcAcceptCon extends WebRtcEvent {
  final String clientName;
  final RTCSessionDescription answer;

  WebRtcAcceptCon({
    @required this.clientName,
    @required this.answer,
  });

  @override
  List<Object> get props => [clientName, answer];
}

class WebRtcClearSdp extends WebRtcEvent {
  final String clientName;

  WebRtcClearSdp({@required this.clientName});
}

class WebRtcUpdateConState extends WebRtcEvent {
  final String clientName;
  final List<WebRTCPeer> serverPeers;
  final WebRTCPeer clientPeer;
  final bool isServer;
  final RTCPeerConnectionState pcState;

  WebRtcUpdateConState({
    @required this.clientName,
    @required this.pcState,
    @required this.serverPeers,
    @required this.clientPeer,
    @required this.isServer,
  });
}

class WebRtcSendToServer extends WebRtcEvent {
  final String clientName;
  final dynamic message;

  WebRtcSendToServer({
    @required this.clientName,
    @required this.message,
  });

  @override
  List<Object> get props => [clientName, message];
}

class WebRtcSendToClient extends WebRtcEvent {
  final String clientName;
  final dynamic message;

  WebRtcSendToClient({
    @required this.clientName,
    @required this.message,
  });

  @override
  List<Object> get props => [clientName, message];
}

class WebRtcSdpChanged extends WebRtcEvent {
  final bool isServer;
  final String clientName;

  WebRtcSdpChanged({
    @required this.isServer,
    @required this.clientName,
  });

  @override
  List<Object> get props => [isServer, clientName];
}

class WebRtcChangeClientPeer extends WebRtcEvent {
  final WebRTCPeer peer;

  WebRtcChangeClientPeer({
    @required this.peer,
  });

  @override
  List<Object> get props => [peer];
}

class WebRtcChangeServerPeer extends WebRtcEvent {
  final WebRTCPeer peer;

  WebRtcChangeServerPeer({
    @required this.peer,
  });

  @override
  List<Object> get props => [peer];
}

class WebRtcCreateDataChannel extends WebRtcEvent {
  final bool isServer;
  final String clientName;

  WebRtcCreateDataChannel({
    @required this.isServer,
    @required this.clientName,
  });

  @override
  List<Object> get props => [isServer, clientName];
}

class WebRtcAddDataChannel extends WebRtcEvent {
  final bool isServer;
  final String clientName;
  final RTCDataChannel dc;

  WebRtcAddDataChannel({
    @required this.isServer,
    @required this.clientName,
    @required this.dc,
  });

  @override
  List<Object> get props => [isServer, clientName, dc];
}
