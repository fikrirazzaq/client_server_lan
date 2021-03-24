import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:client_server_lan/client_server_lan.dart';
import 'package:device_info/device_info.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'udp_lan_event.dart';
part 'udp_lan_state.dart';

class UdpLanBloc extends Bloc<UdpLanEvent, UdpLanState> {
  UdpLanBloc() : super(UdpLanInitial());

  @override
  Stream<UdpLanState> mapEventToState(
    UdpLanEvent event,
  ) async* {
    if (event is UdpLanStart) {
      yield* _mapUdpLanStartToState(event);
    } else if (event is UdpLanScanClients) {
      yield* _mapUdpLanScanClientsToState(event);
    } else if (event is UdpLanCheckExistingServer) {
      yield* _mapUdpLanCheckExistingServerToState(event);
    } else if (event is UdpLanReceiveExistingServer) {
      yield UdpLanServerIsExisted(
        isServer: state.isServer,
        isRunning: state.isRunning,
        serverNode: state.serverNode,
        clients: state.clients,
        clientNode: state.clientNode,
        isServerExist: state.isServerExist,
        dataPacket: state.dataPacket,
      );
    } else if (event is UdpLanDispose) {
      yield* _mapUdpLanDisposeToState(event);
    } else if (event is UdpLanSendToServer) {
      yield* _mapUdpLanSendToServerToState(event);
    } else if (event is UdpLanSendToClient) {
      yield* _mapUdpLanSendToClientToState(event);
    } else if (event is UdpLanSetReady) {
      yield UdpLanReady(
        isServer: state.isServer,
        isRunning: state.isRunning,
        serverNode: state.serverNode,
        clients: state.clients,
        clientNode: state.clientNode,
        isServerExist: state.isServerExist,
        dataPacket: state.dataPacket,
      );
    } else if (event is UdpLanReceiveMessage) {
      yield UdpLanMessageReceived(
        dataPacket: event.data,
        isServer: state.isServer,
        isRunning: state.isRunning,
        serverNode: state.serverNode,
        clients: state.clients,
        clientNode: state.clientNode,
        isServerExist: state.isServerExist,
      );
    }
  }

  Stream<UdpLanState> _mapUdpLanStartToState(UdpLanStart event) async* {
    yield UdpLanLoading();

    if (event.isServer) {
      ServerNode server;
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          var deviceInfo = await DeviceInfoPlugin().androidInfo;
          server = ServerNode(
            name: 'server;${deviceInfo.androidId};${deviceInfo.model}',
            verbose: true,
            onDispose: () {},
            clientDispose: (client) {},
          );
        } else if (Platform.isIOS) {
          var deviceInfo = await DeviceInfoPlugin().iosInfo;
          server = ServerNode(
            name:
                'server;${deviceInfo.identifierForVendor};${deviceInfo.model}',
            verbose: true,
            onDispose: () {},
            clientDispose: (client) {},
          );
        }
        await server.init();
        await server.onReady;

        server.dataResponse.listen((data) {
          add(UdpLanReceiveMessage(data: data));
        });

        yield UdpLanReady(
          isServer: true,
          isRunning: true,
          serverNode: server,
          clients: [],
          clientNode: null,
          isServerExist: null,
        );
      }
    } else {
      ClientNode client;
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          var deviceInfo = await DeviceInfoPlugin().androidInfo;
          client = ClientNode(
            name: 'client;${deviceInfo.androidId};${deviceInfo.model}',
            verbose: true,
            onDispose: () {},
            onServerAlreadyExist: (data) {
              print('Server already exist on ${data.host}');
              add(UdpLanReceiveExistingServer());
            },
          );
        } else if (Platform.isIOS) {
          var deviceInfo = await DeviceInfoPlugin().iosInfo;
          client = ClientNode(
            name:
                'client;${deviceInfo.identifierForVendor};${deviceInfo.model}',
            verbose: true,
            onDispose: () {},
            onServerAlreadyExist: (data) {
              print('Server already exist on ${data.host}');
              add(UdpLanReceiveExistingServer());
            },
          );
        }

        await client.init();
        await client.onReady;

        client.dataResponse.listen((data) {
          add(UdpLanReceiveMessage(data: data));
        });

        yield UdpLanReady(
          isServer: false,
          isRunning: true,
          serverNode: null,
          clients: null,
          clientNode: client,
          isServerExist: false,
        );
      }
    }
  }

  Stream<UdpLanState> _mapUdpLanScanClientsToState(
      UdpLanScanClients event) async* {
    print('Scan clients... $state');
    yield UdpLanReady(
      clients: [],
      clientNode: state.clientNode,
      isRunning: state.isRunning,
      isServer: state.isServer,
      isServerExist: state.isServerExist,
      serverNode: state.serverNode,
    );

    var server = state.serverNode;

    await server.discoverNodes();
    await Future<Object>.delayed(const Duration(seconds: 2));

    yield UdpLanClientsScanned(
      clients: server.clientsConnected,
      clientNode: state.clientNode,
      isRunning: state.isRunning,
      isServer: state.isServer,
      isServerExist: state.isServerExist,
      serverNode: state.serverNode,
    );
  }

  Stream<UdpLanState> _mapUdpLanCheckExistingServerToState(
      UdpLanCheckExistingServer event) async* {
    print('Check existing server... $state');

    var client = state.clientNode;

    await client.discoverServerNode();
  }

  Stream<UdpLanState> _mapUdpLanDisposeToState(UdpLanDispose event) async* {
    if (event.isServer) {
      var server = state.serverNode;
      server.dispose();
    } else {
      var client = state.clientNode;
      client.dispose();
    }

    yield UdpLanInitial();
  }

  Stream<UdpLanState> _mapUdpLanSendToServerToState(
      UdpLanSendToServer event) async* {
    var client = state.clientNode;
    await client.sendData(event.data, event.title);

    yield state;
  }

  Stream<UdpLanState> _mapUdpLanSendToClientToState(
      UdpLanSendToClient event) async* {
    var server = state.serverNode;
    final client = server.clientUri(event.clientName);
    await server.sendData(event.data, event.title, client);

    yield state;
  }
}
