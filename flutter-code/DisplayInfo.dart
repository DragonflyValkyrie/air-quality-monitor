import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import './BackgroundCollectingTask.dart';
import './GraphPage.dart';
import 'dart:async';

class DisplayInfo extends StatefulWidget {
  const DisplayInfo({Key? key}) : super(key: key);
  @override
  _DisplayInfoState createState() => _DisplayInfoState();
}

class _DisplayInfoState extends State<DisplayInfo> {

  // BluetoothConnection? connection;
  // bool isConnecting = true;
  // bool get isConnected => (connection?.isConnected ?? false);
  //
  // bool isDisconnecting = false;
  //
  // @override
  // void intiState(){
  //   super.initState();
  //   _getBTConnection();
  // }
  //
  // @override
  // void dispose(){
  //   if (isConnected) {
  //     isDisconnecting = true;
  //     connection?.dispose();
  //     connection = null;
  //   }
  //   super.dispose();
  // }
  //
  // _getBTConnection(){
  //   BluetoothConnection.toAddress(widget.server.address).then((_connection){
  //     connection = _connection;
  //     setState(() {
  //       isConnecting = false;
  //       isDisconnecting = false;
  //     });
  //     connection!.input!.listen(_onDataReceived).onDone((){
  //       if(isDisconnecting){
  //         print('Disconnecting locally');
  //       } else {
  //         print('Disconnecting remotely');
  //       }
  //       if(this.mounted){
  //         setState(() {});
  //       }
  //       Navigator.of(context).pop();
  //
  //     });
  //   }).catchError((error){
  //     Navigator.of(context).pop();
  //   });
  // }
  //
  // void _onDataReceived(Uint8List data){
  //
  // }

  Color tempColor = Colors.grey.shade400;
  Color humidColor = Colors.grey.shade400;
  Color co2Color = Colors.grey.shade400;
  Color vocColor = Colors.grey.shade400;
  Color pm25Color = Colors.grey.shade400;
  Color ozoneColor = Colors.grey.shade400;

  @override
  Widget build(BuildContext context)  {
  final BackgroundCollectingTask task =
  BackgroundCollectingTask.of(context, rebuildOnChange: true);
    return Scaffold(
      appBar: AppBar(
        title:const Text('Information Display', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  child: const Text('Graph Chart'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GraphInfo()),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,10,20,10),
                    child: Container(
                        child: const Text('Values', style: TextStyle(color: Colors.black, fontSize: 20))
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30,10,30,10),
                    child: Container(
                      child: const Text('Levels', style: TextStyle(color: Colors.black, fontSize: 20)),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350.0,
                    height: 50.0,
                    child: Card(
                      color: Colors.grey.shade400,
                      child: Align(
                        alignment: Alignment(-0.85, 0.00),
                        child: Text(
                          'Temperature ',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ), //Text
                      ), //Center
                    ), //Card
                  ),
                  SizedBox(
                    width: 350.0,
                    height: 50.0,
                    child: Card(
                      color: Colors.grey.shade400,
                      child: Align(
                        alignment: Alignment(-0.85, 0.00),
                        child: Text(
                          'Humidity',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ), //Text
                      ), //Center
                    ), //Card

                  ),
                  SizedBox(
                    width: 350.0,
                    height: 50.0,
                    child: Card(
                      color: Colors.grey.shade400,
                      child: Align(
                        alignment: Alignment(-0.85, 0.00),
                        child: Text(
                          'CO2',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ), //Text
                      ), //Center
                    ), //Card

                  ),
                  SizedBox(
                    width: 350.0,
                    height: 50.0,
                    child: Card(
                      color: Colors.grey.shade400,
                      child: Align(
                        alignment: Alignment(-0.85, 0.00),
                        child: Text(
                          'VOC',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ), //Text
                      ), //Center
                    ), //Card

                  ),
                  SizedBox(
                    width: 350.0,
                    height: 50.0,
                    child: Card(
                      color: Colors.grey.shade400,
                      child: Align(
                        alignment: Alignment(-0.85, 0.00),
                        child: Text(
                          'PM2.5',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ), //Text
                      ), //Center
                    ), //Card

                  ),
                  SizedBox(
                    width: 350.0,
                    height: 50.0,
                    child: Card(
                      color: Colors.grey.shade400,
                      child: Align(
                        alignment: Alignment(-0.85, 0.00),
                          child: Text(
                              'Ozone',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                        ), //Text
                      ), //Center
                    ), //Card
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,20,0,10),
                    child: SizedBox(
                      width: 350.0,
                      height: 125.0,
                      child: Card(
                        color: Colors.purpleAccent,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'System Status',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ), //Text
                        ), //Center
                      ), //Card
                    ),
                  ),
                ],
              ),


            ],
          )

      ),
    );
  }
}
