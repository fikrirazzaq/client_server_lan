part of 'webrtc_bloc.dart';

@immutable
abstract class WebRtcState extends Equatable {
  final List<WebRTCPeer> serverPeers;
  final WebRTCPeer clientPeer;
  final bool isServer;

  const WebRtcState({
    @required this.serverPeers,
    @required this.clientPeer,
    @required this.isServer,
  });

  @override
  List<Object> get props => [serverPeers, clientPeer, isServer];
}

class WebRtcInitial extends WebRtcState {
  const WebRtcInitial()
      : super(
          serverPeers: null,
          clientPeer: null,
          isServer: false,
        );

  @override
  String toString() => 'WebRtcInitial {}';
}

class WebRtcLoading extends WebRtcState {}

class WebRtcReady extends WebRtcState {
  const WebRtcReady({
    List<WebRTCPeer> serverPeers,
    WebRTCPeer clientPeer,
    bool isServer,
  }) : super(
          serverPeers: serverPeers,
          clientPeer: clientPeer,
          isServer: isServer,
        );

  @override
  List<Object> get props => [serverPeers, clientPeer, isServer];

  @override
  String toString() =>
      'WebRtcReady { serverPeers: ${serverPeers != null ? serverPeers.length : '-'}, clientPeer: $clientPeer, isServer: $isServer }';
}

class WebRtcOffered extends WebRtcState {
  const WebRtcOffered({@required List<WebRTCPeer> serverPeers})
      : super(
          serverPeers: serverPeers,
          clientPeer: null,
          isServer: true,
        );

  @override
  List<Object> get props => [serverPeers, clientPeer, isServer];

  @override
  String toString() =>
      'WebRtcOffered { serverPeers: ' +
      serverPeers
          .map((e) => '(${e.label}, ${e.sdp != null ? e.sdp.type : '-'})')
          .toSet()
          .toString() +
      ' }';
}

class WebRtcServerPeersChanged extends WebRtcState {
  const WebRtcServerPeersChanged({@required List<WebRTCPeer> serverPeers})
      : super(
          serverPeers: serverPeers,
          clientPeer: null,
          isServer: true,
        );

  @override
  List<Object> get props => [serverPeers, clientPeer, isServer];

  @override
  String toString() =>
      'WebRtcServerPeersChanged { serverPeers: ' +
      serverPeers
          .map((e) => '(${e.label}, ${e.sdp != null ? e.sdp.type : '-'})')
          .toSet()
          .toString() +
      ' }';
}

class WebRtcAnswered extends WebRtcState {
  const WebRtcAnswered({@required WebRTCPeer clientPeer})
      : super(
          serverPeers: null,
          clientPeer: clientPeer,
          isServer: false,
        );

  @override
  List<Object> get props => [serverPeers, clientPeer, isServer];

  @override
  String toString() =>
      'WebRtcOffered { clientPeer: (${clientPeer.label}, ${clientPeer.sdp != null ? clientPeer.sdp.type : '-'}) }';
}

class WebRtcClientPeerChanged extends WebRtcState {
  const WebRtcClientPeerChanged({@required WebRTCPeer clientPeer})
      : super(
          serverPeers: null,
          clientPeer: clientPeer,
          isServer: false,
        );

  @override
  List<Object> get props => [serverPeers, clientPeer, isServer];

  @override
  String toString() =>
      'WebRtcClientPeerChanged { clientPeer: (${clientPeer.label}, ${clientPeer.sdp != null ? clientPeer.sdp.type : '-'}) }';
}

class WebRtcAccepted extends WebRtcState {
  const WebRtcAccepted({@required List<WebRTCPeer> serverPeers})
      : super(
          serverPeers: serverPeers,
          clientPeer: null,
          isServer: true,
        );

  @override
  List<Object> get props => [serverPeers, clientPeer, isServer];

  @override
  String toString() =>
      'WebRtcOffered { serverPeers: ' +
      serverPeers
          .map((e) => '(${e.label}, ${e.sdp != null ? e.sdp.type : '-'})')
          .toSet()
          .toString() +
      ' }';
}

class WebRTCPeer {
  final String label;
  final RTCPeerConnection pc;
  final RTCDataChannel dc;
  final RTCSessionDescription sdp;
  final RTCPeerConnectionState pcState;

  WebRTCPeer({
    this.label,
    this.pc,
    this.dc,
    this.sdp,
    this.pcState,
  });

  WebRTCPeer copyWith({
    String label,
    RTCPeerConnection pc,
    RTCDataChannel dc,
    RTCSessionDescription sdp,
    RTCPeerConnectionState pcState,
  }) {
    return WebRTCPeer(
      label: label ?? this.label,
      pc: pc ?? this.pc,
      dc: dc ?? this.dc,
      sdp: sdp ?? this.sdp,
      pcState: pcState ?? this.pcState,
    );
  }

  @override
  String toString() {
    return 'WebRTCPeer(label: $label, pc: $pc, dc: $dc, sdp: $sdp, pcState: $pcState)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WebRTCPeer &&
        other.label == label &&
        other.pc == pc &&
        other.dc == dc &&
        other.sdp == sdp &&
        other.pcState == pcState;
  }

  @override
  int get hashCode {
    return label.hashCode ^
        pc.hashCode ^
        dc.hashCode ^
        sdp.hashCode ^
        pcState.hashCode;
  }
}
