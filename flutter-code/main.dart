import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './BlueToothDeviceListEntry.dart';
import './DisplayInfo.dart';
import './SelectBondedDevicePage.dart';
import './BackgroundCollectingTask.dart';
import 'package:scoped_model/scoped_model.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(home: HomePage(),);
  }
}

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  List<BluetoothDevice> devices = <BluetoothDevice>[];

  String _address = "...";
  String _name = "...";

  BackgroundCollectingTask? _collectingTask;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _getBTState();
    _stateChangeListener();

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

  }

  @override
  void dispose(){
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state.index == 0){
      //resume
      if(_bluetoothState.isEnabled){
        _listBondedDevices();
      }
    }
  }


  _getBTState(){
    FlutterBluetoothSerial.instance.state.then((state){
      setState(() {
        _bluetoothState = state;
      });

      if(_bluetoothState.isEnabled){
        _listBondedDevices();
      }
      setState(() {});
      });
  }

  _stateChangeListener(){
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state){
      _bluetoothState = state;
      if(_bluetoothState.isEnabled){
        _listBondedDevices();
      } else {
        devices.clear();
      }
      print("State isEnabled: ${state.isEnabled}");
      setState(() {});
    });
  }

  _listBondedDevices(){
    FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices){
      devices = bondedDevices;
      setState(() {});
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth Connections"),),
      body: Container(
        child: Column(children: <Widget>[
          SwitchListTile(
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              future() async {
                if (value) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                } else {
                  await FlutterBluetoothSerial.instance.requestDisable();
                }
              }
              future().then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            title: const Text('Bluetooth Status'),
            subtitle: Text(_bluetoothState.toString()),
            trailing: ElevatedButton(
              child: const Text('Settings'), onPressed: () {
              FlutterBluetoothSerial.instance.openSettings();
            },
            ),
          ),
          ListTile(
            title: const Text('Local adapter address'),
            subtitle: Text(_address),
          ),
          ListTile(
            title: const Text('Local adapter name'),
            subtitle: Text(_name),
            onLongPress: null,
          ),
          // ListTile(
          //   title: ElevatedButton(
          //     child: const Text('Connect to paired device'),
          //     onPressed: () async {
          //       final BluetoothDevice? selectedDevice =
          //       await Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (context) {
          //             return SelectBondedDevicePage(checkAvailability: false);
          //           },
          //         ),
          //       );
          //
          //       if (selectedDevice != null) {
          //         print('Connect -> selected ' + selectedDevice.address);
          //         _startConnect(context, selectedDevice);
          //       } else {
          //         print('Connect -> no device selected');
          //       }
          //     },
          //   ),
          // ),

          ListTile(
            title: ElevatedButton(
              child: ((_collectingTask?.inProgress ?? false)
                  ? const Text('Disconnect, Stop Gathering Data')
                  : const Text('Connect to Gather Data')),
              onPressed: () async {
                if (_collectingTask?.inProgress ?? false) {
                  setState(() {
                    /* Update for `_collectingTask.inProgress` */
                  });
                } else {
                  final BluetoothDevice? selectedDevice =
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectBondedDevicePage(
                            checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    await _startBackgroundTask(context, selectedDevice);
                    setState(() {
                      /* Update for `_collectingTask.inProgress` */
                    });
                  }
                }
              },
            ),
          ),

          ListTile(
            title: ElevatedButton(
              child: const Text('Display Information Page'),
              onPressed: (_collectingTask != null)
                  ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ScopedModel<BackgroundCollectingTask>(
                        model: _collectingTask!,
                        child: DisplayInfo(),
                      );
                    },
                  ),
                );
              }
                  : null,
            ),
          ),

          // Expanded(
          //   child: ListView(
          //     children: devices.map((_device) => BluetoothDeviceListEntry(
          //     device: _device,
          //     enabled: true,
          //     onTap: (){
          //       print('Item');
          //       _startConnect(context, _device);
          //   },
          // ))
          // .toList(),
          //   ),
          // ),
        ],
        ),
      ),
    );
  }

  Future<void> _startBackgroundTask(
      BuildContext context,
      BluetoothDevice server,
      ) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
    } catch (ex) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

// void _startConnect(BuildContext context, BluetoothDevice server){
//   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//     return DisplayInfo(server: server);
//   }));
//
// }
