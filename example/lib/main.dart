import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client_server_lan/client_server_lan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:udp_lan_transfer_example/bloc/udp_lan_bloc.dart';
import 'package:udp_lan_transfer_example/bloc/webrtc_bloc.dart';

import 'bloc/logging_bloc_observer.dart';
import 'client_page.dart';
import 'server_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());

  Bloc.observer = LoggingBlocObserver();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WebRtcBloc>(create: (context) => WebRtcBloc()),
        BlocProvider<UdpLanBloc>(create: (context) => UdpLanBloc()),
      ],
      child: MaterialApp(
        title: 'UDPLANtransfer',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool kIsAndroid = false;
  String dropdownValue = 'Server';
  List<String> dropdownValues = ['Server', 'Client'];
  bool isLoading = false;
  String dataReceived = '';
  bool isRunning = false;
  String status = '';

  // Server
  ServerNode server;
  List<ConnectedClientNode> connectedClients = [];

  // Client
  ClientNode client;

  bool isServer = false;
  List<WebRTCPeer> serverPeers;
  WebRTCPeer clientPeer;

  List<String> receiveds = [];
  List<String> createds = [];

  @override
  Widget build(BuildContext context) {
    kIsAndroid =
        !kIsWeb && Theme.of(context).platform == TargetPlatform.android;
    return BlocBuilder<UdpLanBloc, UdpLanState>(
      builder: (context, state) {
        if (state is UdpLanInitial) {
          isRunning = false;
        }

        if (state is UdpLanLoading) {
          isLoading = true;
        }

        if (state is UdpLanReady) {
          isLoading = false;

          server = state.serverNode;
          connectedClients = state.clients;
          client = state.clientNode;
          isRunning = state.isRunning;
        }

        if (state is UdpLanClientsScanned) {
          connectedClients = state.clients;

          server = state.serverNode;
          connectedClients = state.clients;
          client = state.clientNode;
          isRunning = state.isRunning;

          if (connectedClients.isNotEmpty) {
            for (var i = 0; i < connectedClients.length; i++) {
              context
                  .read<WebRtcBloc>()
                  .add(WebRtcOfferCon(clientName: connectedClients[i].name));
            }
          }

          context.read<UdpLanBloc>().add(UdpLanSetReady());
        }

        if (state is UdpLanMessageReceived) {
          if (state.dataPacket.title == 'join_webrtc') {
            var clientName = state.dataPacket.name;
            context
                .read<WebRtcBloc>()
                .add(WebRtcOfferCon(clientName: clientName));
          } else {
            receiveds.add(state.dataPacket == null
                ? ''
                : state.dataPacket.payload.toString());
            dataReceived = state.dataPacket == null
                ? ''
                : state.dataPacket.payload.toString();

            // Receive & Handling Offer/Answer
            if (state.dataPacket != null) {
              final sdpMap = state.dataPacket.payload;
              if (state.dataPacket.title == 'answer') {
                context.read<WebRtcBloc>().add(WebRtcAcceptCon(
                      clientName: state.dataPacket.name,
                      answer: RTCSessionDescription(
                        sdpMap['sdp'],
                        sdpMap['type'],
                      ),
                    ));
              }
              if (state.dataPacket.title == 'offer') {
                context.read<WebRtcBloc>().add(WebRtcAnswerCon(
                      clientName: state.clientNode.name,
                      offer: RTCSessionDescription(
                        sdpMap['sdp'],
                        sdpMap['type'],
                      ),
                    ));
              }
            }

            context.read<UdpLanBloc>().add(UdpLanSetReady());
          }
        }

        if (state is UdpLanServerIsExisted) {
          context.read<UdpLanBloc>().add(
              UdpLanSendToServer(title: 'join_webrtc', data: 'injeksibos'));
        }

        return BlocConsumer<WebRtcBloc, WebRtcState>(
          listener: (context, state) {
            if (state is WebRtcOffered) {}

            if (state is WebRtcAnswered) {}

            if (state is WebRtcAccepted) {}

            if (state is WebRtcClientPeerChanged) {}
          },
          builder: (context, state) {
            isServer = state.isServer ?? false;
            serverPeers = state.serverPeers;
            clientPeer = state.clientPeer;

            if (state.serverPeers != null) {
              if (state.serverPeers.isNotEmpty) {
                for (var i = 0; i < state.serverPeers.length; i++) {
                  if (state.serverPeers[i].dc != null) {
                    state.serverPeers[i].dc.onMessage = (data) {};
                    state.serverPeers[i].dc.onDataChannelState = (state) {};
                  }

                  state.serverPeers[i].pc.onConnectionState = (con) {
                    context.read<WebRtcBloc>().add(WebRtcUpdateConState(
                          clientName: state.serverPeers[i].label,
                          pcState: con,
                          serverPeers: state.serverPeers,
                          clientPeer: state.clientPeer,
                          isServer: state.isServer,
                        ));
                  };
                }
              }
            }

            if (state.clientPeer != null) {
              if (state.clientPeer.dc != null) {
                state.clientPeer.dc.onMessage = (data) {};
                state.clientPeer.dc.onDataChannelState = (state) {};
              }

              state.clientPeer.pc.onConnectionState = (con) {
                context.read<WebRtcBloc>().add(WebRtcUpdateConState(
                      clientName: state.clientPeer.label,
                      pcState: con,
                      serverPeers: state.serverPeers,
                      clientPeer: state.clientPeer,
                      isServer: state.isServer,
                    ));
              };
            }

            if (state is WebRtcServerPeersChanged) {
              for (var i = 0; i < state.serverPeers.length; i++) {
                if (state.serverPeers[i].sdp != null) {
                  if (state.serverPeers[i].sdp.type == 'offer') {
                    createds.add(state.serverPeers[i].sdp.toMap().toString());
                    context.read<UdpLanBloc>().add(
                          UdpLanSendToClient(
                            title: 'offer',
                            clientName: state.serverPeers[i].label,
                            data: json.encode(state.serverPeers[i].sdp.toMap()),
                          ),
                        );
                  }
                }
              }

              context.read<WebRtcBloc>().add(
                    WebRtcSetReady(
                      clientPeer: null,
                      isServer: true,
                      serverPeers: state.serverPeers,
                    ),
                  );
            }

            if (state is WebRtcClientPeerChanged) {
              if (clientPeer.sdp != null) {
                createds.add(clientPeer.sdp.toMap().toString());
                if (clientPeer.sdp.type == 'answer') {
                  context.read<UdpLanBloc>().add(
                        UdpLanSendToServer(
                          title: 'answer',
                          data: json.encode(clientPeer.sdp.toMap()),
                        ),
                      );

                  context.read<WebRtcBloc>().add(
                        WebRtcSetReady(
                          clientPeer: clientPeer,
                          isServer: false,
                          serverPeers: null,
                        ),
                      );
                }
              }
            }

            return Scaffold(
              appBar: AppBar(
                title: Text('UDPLANtransfer'),
              ),
              body: Container(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDropdown(),
                      dropdownValue == 'Server'
                          ? ServerPage(
                              onStartPressed: () {
                                context
                                    .read<UdpLanBloc>()
                                    .add(UdpLanStart(isServer: true));
                              },
                              onDisposePressed: () {
                                context
                                    .read<UdpLanBloc>()
                                    .add(UdpLanDispose(isServer: true));
                              },
                              connectedClientNodes: connectedClients ?? [],
                              onFindClientsPressed: () {
                                context
                                    .read<UdpLanBloc>()
                                    .add(UdpLanScanClients());
                              },
                              onSendToClient: (clientName, message) {
                                state.serverPeers
                                    .firstWhere((e) => e.label == clientName)
                                    .dc
                                    .send(RTCDataChannelMessage(message));
                              },
                              dataReceived: dataReceived,
                              isLoading: isLoading,
                              isRunning: isRunning,
                              status: status,
                            )
                          : ClientPage(
                              onStartPressed: () {
                                context
                                    .read<UdpLanBloc>()
                                    .add(UdpLanStart(isServer: false));
                              },
                              onDisposePressed: () {
                                context
                                    .read<UdpLanBloc>()
                                    .add(UdpLanDispose(isServer: false));
                              },
                              onSendToServer: (message) {
                                // context.read<UdpLanBloc>().add(
                                //     UdpLanSendToServer(
                                //         title: 'Injeksi', data: 'Bos'));
                                state.clientPeer.dc
                                    .send(RTCDataChannelMessage(message));
                              },
                              dataReceived: dataReceived,
                              onCheckServerPressed: () {
                                context
                                    .read<UdpLanBloc>()
                                    .add(UdpLanCheckExistingServer());
                              },
                              isLoading: isLoading,
                              isRunning: isRunning,
                              status: status,
                            ),
                      Divider(),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: serverPeers == null ? 0 : serverPeers.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(
                              '${serverPeers[index].label}\n${serverPeers[index].pcState}\n${serverPeers[index].dc.onDataChannelState}'),
                          trailing: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              var controller = TextEditingController();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Send to Server'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          state.serverPeers
                                              .firstWhere((e) =>
                                                  e.label ==
                                                  serverPeers[index].label)
                                              .dc
                                              .send(RTCDataChannelMessage(
                                                  controller.text));
                                        },
                                        child: Text('SEND'),
                                      ),
                                    ],
                                    content: TextField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                          hintText: 'Text to send'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Divider(),
                      Text('Received'),
                      Divider(),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: receiveds.length,
                        separatorBuilder: (context, index) {
                          return Divider(height: 2);
                        },
                        itemBuilder: (context, index) {
                          return Text(
                              '-------${index + 1}\n${receiveds[index]}');
                        },
                      ),
                      Divider(),
                      Text('Created'),
                      Divider(),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: createds.length,
                        separatorBuilder: (context, index) {
                          return Divider(height: 2);
                        },
                        itemBuilder: (context, index) {
                          return Text(
                              '-------${index + 1}\n${createds[index]}');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  DropdownButton<String> _buildDropdown() {
    return DropdownButton<String>(
      value: dropdownValue,
      disabledHint: Text(dropdownValue),
      onChanged: !isRunning
          ? (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            }
          : null,
      items: dropdownValues.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

extension<T> on List<T> {
  T reversedIndex(int index) {
    return this[length - index - 1];
  }
}
