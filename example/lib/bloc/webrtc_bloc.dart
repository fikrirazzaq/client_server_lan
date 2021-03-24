import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meta/meta.dart';

part 'webrtc_event.dart';
part 'webrtc_state.dart';

Map<String, dynamic> _connectionConfiguration = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
  ]
};

const _offerAnswerConstraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

class WebRtcBloc extends Bloc<WebRtcEvent, WebRtcState> {
  WebRtcBloc() : super(WebRtcInitial());

  @override
  Stream<WebRtcState> mapEventToState(
    WebRtcEvent event,
  ) async* {
    if (event is WebRtcOfferCon) {
      yield* _mapWebRtcOfferConToState(event);
    } else if (event is WebRtcAnswerCon) {
      yield* _mapWebRtcAnswerConToState(event);
    } else if (event is WebRtcSdpChanged) {
      yield* _mapWebRtcSdpChangedToState(event);
    } else if (event is WebRtcCreateDataChannel) {
      yield* _mapWebRtcCreateDataChanngelToState(event);
    } else if (event is WebRtcAddDataChannel) {
      yield* _mapWebRtcAddDataChanngelToState(event);
    } else if (event is WebRtcAcceptCon) {
      yield* _mapWebRtcAcceptConToState(event);
    } else if (event is WebRtcSetReady) {
      yield* _mapWebRtcSetReadyToState(event);
    } else if (event is WebRtcChangeClientPeer) {
      yield WebRtcClientPeerChanged(clientPeer: event.peer);
    } else if (event is WebRtcChangeServerPeer) {
      yield* _mapWebRtcChangeServerPeer(event);
    } else if (event is WebRtcUpdateConState) {
      yield* _mapWebRtcUpdateConState(event);
    }
  }

  Stream<WebRtcState> _mapWebRtcUpdateConState(
      WebRtcUpdateConState event) async* {
    var indexPeer =
        event.serverPeers.indexWhere((e) => e.label == event.clientName);
    if (indexPeer > -1) {
      yield WebRtcLoading();

      var peers = event.serverPeers;
      var peer = peers[indexPeer];
      peers[indexPeer] = peer.copyWith(pcState: event.pcState);

      yield WebRtcReady(
        clientPeer: event.clientPeer,
        serverPeers: event.serverPeers,
        isServer: event.isServer,
      );
    }
  }

  Stream<WebRtcState> _mapWebRtcChangeServerPeer(
      WebRtcChangeServerPeer event) async* {
    var indexPeer =
        state.serverPeers.indexWhere((e) => e.label == event.peer.label);
    if (indexPeer > -1) {
      var peers = state.serverPeers;
      peers[indexPeer] = event.peer;
      yield WebRtcServerPeersChanged(serverPeers: peers);
    }
  }

  Stream<WebRtcState> _mapWebRtcSetReadyToState(WebRtcSetReady event) async* {
    yield WebRtcReady(
      clientPeer: event.clientPeer,
      serverPeers: event.serverPeers,
      isServer: event.isServer,
    );
  }

  Future<RTCPeerConnection> _createPeerConnection({
    @required String clientName,
    bool isServer = false,
  }) async {
    final pc = await createPeerConnection(_connectionConfiguration);
    pc.onIceCandidate = (candidate) {
      if (isServer) {
        add(WebRtcSdpChanged(isServer: true, clientName: clientName));
      } else {
        add(WebRtcSdpChanged(isServer: false, clientName: clientName));
      }
    };

    pc.onDataChannel = (dc) {
      if (isServer) {
        add(WebRtcAddDataChannel(
          isServer: true,
          clientName: clientName,
          dc: dc,
        ));
      } else {
        add(WebRtcAddDataChannel(
          isServer: false,
          clientName: clientName,
          dc: dc,
        ));
      }
    };

    return pc;
  }

  Stream<WebRtcState> _mapWebRtcOfferConToState(
      WebRtcOfferCon offerCon) async* {
    WebRTCPeer peer;
    final pc = await _createPeerConnection(
        clientName: offerCon.clientName, isServer: true);

    // Create Data Channel
    var dataChannelDict = RTCDataChannelInit();
    var dc = await pc.createDataChannel(offerCon.clientName, dataChannelDict);

    // Create offer
    var offer = await pc.createOffer(_offerAnswerConstraints);
    await pc.setLocalDescription(offer);

    var peers = state.serverPeers ?? [];
    var indexToUpdate = peers.indexWhere((e) => e.label == offerCon.clientName);
    peer = WebRTCPeer(
      label: offerCon.clientName,
      pc: pc,
      dc: dc,
      pcState: pc.connectionState,
    );
    if (indexToUpdate > -1) {
      peers[indexToUpdate] = peer;
    } else {
      peers.add(peer);
    }
    yield WebRtcOffered(serverPeers: peers);

    add(WebRtcSdpChanged(isServer: true, clientName: offerCon.clientName));
  }

  Timer _timer;
  bool _send = false;

  Stream<WebRtcState> _mapWebRtcSdpChangedToState(
      WebRtcSdpChanged event) async* {
    if (event.isServer) {
      if (state.serverPeers != null) {
        var indexPeer =
            state.serverPeers.indexWhere((e) => e.label == event.clientName);
        var sdp = await state.serverPeers[indexPeer].pc.getLocalDescription();

        var peers = state.serverPeers;
        var peer = peers[indexPeer];

        // Send SDP
        _timer?.cancel();
        _timer = null;

        _timer = Timer(Duration(seconds: 3), () {
          _send = true;
          add(WebRtcChangeServerPeer(peer: peer.copyWith(sdp: sdp)));
        });
      }
    } else {
      if (state.clientPeer != null) {
        var sdp = await state.clientPeer.pc.getLocalDescription();

        var peer = state.clientPeer;

        // Send SDP
        _timer?.cancel();
        _timer = null;
        _send = false;

        _timer = Timer(Duration(seconds: 3), () {
          _send = true;
          add(WebRtcChangeClientPeer(peer: peer.copyWith(sdp: sdp)));
        });
      }
    }
  }

  Stream<WebRtcState> _mapWebRtcCreateDataChanngelToState(
      WebRtcCreateDataChannel event) async* {
    if (event.isServer) {
      var dataChannelDict = RTCDataChannelInit();
      var dc = await state.serverPeers
          .firstWhere((e) => e.label == event.clientName)
          .pc
          .createDataChannel(event.clientName, dataChannelDict);
      add(WebRtcAddDataChannel(
        isServer: true,
        clientName: event.clientName,
        dc: dc,
      ));
    }
  }

  Stream<WebRtcState> _mapWebRtcAddDataChanngelToState(
      WebRtcAddDataChannel event) async* {
    if (event.isServer) {
      var indexPeer =
          state.serverPeers.indexWhere((e) => e.label == event.clientName);
      var peers = state.serverPeers;
      var peer = peers[indexPeer];
      peers[indexPeer] = peer.copyWith(dc: event.dc);

      yield WebRtcServerPeersChanged(serverPeers: peers);
    } else {
      var peer = state.clientPeer;

      yield WebRtcClientPeerChanged(clientPeer: peer.copyWith(dc: event.dc));
    }
  }

  Stream<WebRtcState> _mapWebRtcAnswerConToState(
      WebRtcAnswerCon answerCon) async* {
    final pc = await _createPeerConnection(clientName: answerCon.clientName);

    await pc.setRemoteDescription(answerCon.offer);
    final answer = await pc.createAnswer(_offerAnswerConstraints);
    await pc.setLocalDescription(answer);

    var peer = WebRTCPeer(
      label: answerCon.clientName,
      pc: pc,
      pcState: pc.connectionState,
    );

    yield WebRtcAnswered(clientPeer: peer);
  }

  Stream<WebRtcState> _mapWebRtcAcceptConToState(
      WebRtcAcceptCon acceptCon) async* {
    var indexPeer =
        state.serverPeers.indexWhere((e) => e.label == acceptCon.clientName);
    var peers = state.serverPeers;
    var peer = peers[indexPeer];
    await peer.pc.setRemoteDescription(acceptCon.answer);

    peers[indexPeer] = peer.copyWith(sdp: await peer.pc.getRemoteDescription());
    yield WebRtcAccepted(serverPeers: peers);
  }
}
