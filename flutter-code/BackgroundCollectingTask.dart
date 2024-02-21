import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

class DataSample {
  double temperature;
  double humidity;
  double co2;
  double voc;
  double pm25;
  double ozone;
  DateTime timestamp;

  DataSample({
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.voc,
    required this.pm25,
    required this.ozone,
    required this.timestamp,
  });
}

class BackgroundCollectingTask extends Model {
  static BackgroundCollectingTask of(
      BuildContext context, {
        bool rebuildOnChange = false,
      }) =>
      ScopedModel.of<BackgroundCollectingTask>(
        context,
        rebuildOnChange: rebuildOnChange,
      );

  final BluetoothConnection _connection;
  List<int> _buffer = List<int>.empty(growable: true);

  // @TODO , Such sample collection in real code should be delegated
  // (via `Stream<DataSample>` preferably) and then saved for later
  // displaying on chart (or even stright prepare for displaying).
  // @TODO ? should be shrinked at some point, endless colleting data would cause memory shortage.
  List<DataSample> samples = List<DataSample>.empty(growable: true);

  bool inProgress = false;

  BackgroundCollectingTask._fromConnection(this._connection) {
    _connection.input!.listen((data) {
      _buffer += data;

      while (true) {
        // If there is a sample, and it is full sent
        int index = _buffer.indexOf('t'.codeUnitAt(0));
        if (index >= 0 && _buffer.length - index >= 13) {
          final DataSample sample = DataSample(
              temperature: (_buffer[index + 1] + _buffer[index + 2] / 100),
              humidity: (_buffer[index + 3] + _buffer[index + 4] / 100),
              co2: (_buffer[index + 5] + _buffer[index + 6] / 100),
              voc: (_buffer[index + 7] + _buffer[index + 8] / 100),
              pm25: (_buffer[index + 9] + _buffer[index + 10] / 100),
              ozone: (_buffer[index + 11] + _buffer[index + 12] / 100),
              timestamp: DateTime.now());
          _buffer.removeRange(0, index + 13);

          samples.add(sample);
          notifyListeners(); // Note: It shouldn't be invoked very often - in this example data comes at every second, but if there would be more data, it should update (including repaint of graphs) in some fixed interval instead of after every sample.
          //print("${sample.timestamp.toString()} -> ${sample.temperature1} / ${sample.temperature2}");
        }
        // Otherwise break
        else {
          break;
        }
      }
    }).onDone(() {
      notifyListeners();
    });
  }

  static Future<BackgroundCollectingTask> connect(
      BluetoothDevice server) async {
    final BluetoothConnection connection =
    await BluetoothConnection.toAddress(server.address);
    return BackgroundCollectingTask._fromConnection(connection);
  }

  void dispose() {
    _connection.dispose();
  }

}
