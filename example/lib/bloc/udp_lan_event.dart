part of 'udp_lan_bloc.dart';

@immutable
abstract class UdpLanEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UdpLanStart extends UdpLanEvent {
  final bool isServer;

  UdpLanStart({@required this.isServer});

  @override
  List<Object> get props => [isServer];

  @override
  String toString() => 'UdpLanStart { isServer: $isServer }';
}

class UdpLanScanClients extends UdpLanEvent {
  @override
  String toString() => 'UdpLanScanClients { }';
}

class UdpLanCheckExistingServer extends UdpLanEvent {
  @override
  String toString() => 'UdpLanCheckExistingServer { }';
}

class UdpLanReceiveExistingServer extends UdpLanEvent {
  @override
  String toString() => 'UdpLanReceiveExistingServer { }';
}

class UdpLanSetReady extends UdpLanEvent {
  @override
  String toString() => 'UdpLanSetReady { }';
}

class UdpLanReceiveMessage extends UdpLanEvent {
  final DataPacket data;

  UdpLanReceiveMessage({@required this.data});

  @override
  List<Object> get props => [data];

  @override
  String toString() => 'UdpLanReceiveMessage { data: ${data.title} }';
}

class UdpLanSendToServer extends UdpLanEvent {
  final String title;
  final dynamic data;

  UdpLanSendToServer({@required this.title, @required this.data});

  @override
  String toString() => 'UdpLanSendToServer { title: $title }';
}

class UdpLanSendToClient extends UdpLanEvent {
  final String clientName;
  final dynamic data;
  final String title;

  UdpLanSendToClient({
    @required this.clientName,
    @required this.data,
    @required this.title,
  });

  @override
  List<Object> get props => [clientName, data, title];

  @override
  String toString() =>
      'UdpLanSendToClient { clientName: $clientName, title: $title }';
}

class UdpLanDispose extends UdpLanEvent {
  final bool isServer;

  UdpLanDispose({@required this.isServer});

  @override
  List<Object> get props => [isServer];

  @override
  String toString() => 'UdpLanDispose { isServer: $isServer }';
}
