import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:syncfusion_flutter_charts/charts.dart';
import './BackgroundCollectingTask.dart';

class GraphInfo extends StatefulWidget{
  const GraphInfo({Key? key}) : super(key: key);
  @override
  State<GraphInfo> createState() => _GraphInfoState();
}

class _GraphInfoState extends State<GraphInfo> {



  late TooltipBehavior _tooltipBehavior;
  String chartTitle = 'Temperature';

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Graph Display', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SafeArea(
          child: Column(
              children: [
                Center(
                  child: Container(
                      child: SfCartesianChart(

                          primaryXAxis: CategoryAxis(),
                          // Chart title
                          title: ChartTitle(text: chartTitle),
                          // Enable legend
                          legend: Legend(isVisible: true),
                          // Enable tooltip
                          tooltipBehavior: _tooltipBehavior,

                          series: <LineSeries<SalesData, String>>[
                            LineSeries<SalesData, String>(
                                dataSource: <SalesData>[
                                  SalesData('Jan', 35),
                                  SalesData('Feb', 28),
                                  SalesData('Mar', 34),
                                  SalesData('Apr', 32),
                                  SalesData('May', 40)
                                ],
                                xValueMapper: (SalesData sales, _) => sales.year,
                                yValueMapper: (SalesData sales, _) => sales.sales,
                                // Enable data label
                                dataLabelSettings: DataLabelSettings(
                                    isVisible: true)
                            )
                          ]
                      )
                  ),
                ),

                Row(
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          onPressed: () {
                            tempData();
                            chartTitle = 'Temperature';
                          },
                          child: const Text('Temp'),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          onPressed: () {
                            humidityData();
                            chartTitle = 'Humidity';
                          },
                          child: const Text('Humid'),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          onPressed: () {
                            co2Data();
                            chartTitle = 'CO2';
                          },
                          child: const Text('CO2'),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ]

                ),

                Row(
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          onPressed: () {
                            vocData();
                            chartTitle = 'VOC';
                          },
                          child: const Text('VOC'),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          onPressed: () {
                            pm25Data();
                            chartTitle = 'PM2.5';
                          },
                          child: const Text('PM2.5'),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          onPressed: () {
                            ozoneData();
                            chartTitle = 'Ozone';
                          },
                          child: const Text('Ozone'),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ]
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Display Page'))
                        );
                      },
                      child: const Text('Back To Display Page'),
                    ),
                  ),
                ),

              ]
          )
      ),
    );
  }
}

void tempData() {

}


void humidityData() {

}


void co2Data() {

}


void vocData() {

}


void pm25Data() {

}


void ozoneData() {

}



class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
