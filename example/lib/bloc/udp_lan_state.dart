part of 'udp_lan_bloc.dart';

@immutable
abstract class UdpLanState extends Equatable {
  final bool isServer;
  final bool isRunning;
  final ServerNode serverNode;
  final List<ConnectedClientNode> clients;
  final ClientNode clientNode;
  final bool isServerExist;
  final DataPacket dataPacket;

  const UdpLanState({
    this.isServer,
    this.isRunning,
    this.serverNode,
    this.clients,
    this.clientNode,
    this.isServerExist,
    this.dataPacket,
  });

  @override
  List<Object> get props => [
        isServer,
        isRunning,
        serverNode,
        clients,
        clientNode,
        isServerExist,
        dataPacket,
      ];
}

class UdpLanInitial extends UdpLanState {
  const UdpLanInitial()
      : super(
          isRunning: false,
          isServer: false,
          serverNode: null,
          clients: null,
          clientNode: null,
          isServerExist: false,
          dataPacket: null,
        );

  @override
  String toString() => 'UdpLanInitial {}';
}

class UdpLanReady extends UdpLanState {
  const UdpLanReady({
    bool isServer,
    bool isRunning,
    ServerNode serverNode,
    List<ConnectedClientNode> clients,
    ClientNode clientNode,
    bool isServerExist,
    DataPacket dataPacket,
  }) : super(
          isRunning: isRunning,
          isServer: isServer,
          serverNode: serverNode,
          clients: clients,
          clientNode: clientNode,
          isServerExist: isServerExist,
          dataPacket: dataPacket,
        );

  @override
  String toString() =>
      'UdpLanReady { isRunning: $isRunning, isServer: $isServer, serverNode: $serverNode, clientNode: $clientNode}';
}

class UdpLanLoading extends UdpLanState {
  const UdpLanLoading();

  @override
  String toString() => 'UdpLanLoading { }';
}

class UdpLanClientsScanned extends UdpLanState {
  const UdpLanClientsScanned({
    @required List<ConnectedClientNode> clients,
    bool isServer,
    bool isRunning,
    ServerNode serverNode,
    ClientNode clientNode,
    bool isServerExist,
    DataPacket dataPacket,
  }) : super(
          isRunning: isRunning,
          isServer: isServer,
          serverNode: serverNode,
          clients: clients,
          clientNode: clientNode,
          isServerExist: isServerExist,
          dataPacket: dataPacket,
        );

  @override
  String toString() => 'UdpLanClientsScanned { clients: ${clients.toSet()} }';
}

class UdpLanServerIsExisted extends UdpLanState {
  const UdpLanServerIsExisted({
    List<ConnectedClientNode> clients,
    bool isServer,
    bool isRunning,
    ServerNode serverNode,
    ClientNode clientNode,
    bool isServerExist,
    DataPacket dataPacket,
  }) : super(
          isRunning: isRunning,
          isServer: isServer,
          serverNode: serverNode,
          clients: clients,
          clientNode: clientNode,
          isServerExist: isServerExist,
          dataPacket: dataPacket,
        );

  @override
  String toString() => 'UdpLanServerIsExisted { }';
}

class UdpLanMessageReceived extends UdpLanState {
  const UdpLanMessageReceived({
    @required DataPacket dataPacket,
    bool isServer,
    bool isRunning,
    List<ConnectedClientNode> clients,
    ServerNode serverNode,
    ClientNode clientNode,
    bool isServerExist,
  }) : super(
          dataPacket: dataPacket,
          isRunning: isRunning,
          isServer: isServer,
          serverNode: serverNode,
          clients: clients,
          clientNode: clientNode,
          isServerExist: isServerExist,
        );

  @override
  String toString() =>
      'UdpLanMessageReceived { dataPacket: ${dataPacket.title} }';
}
