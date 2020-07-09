import 'package:flutter/material.dart';
import 'package:buehlmaier_app/models/workload.dart';
import 'package:buehlmaier_app/utils/chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class WorkloadPage extends StatelessWidget {
  final List<Workload> data = [
    Workload(
      name: 'Türen',
      count: 50,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    Workload(
      name: 'Fenster',
      count: 5,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    Workload(
      name: 'Pfosten',
      count: 8,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auslastung'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Auslastung: 3,5 Wochen',
                style: TextStyle(fontSize: 22.0),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Türen: ${data.elementAt(0).count.toString()}', style: TextStyle(fontSize: 18.0)),
                Text('Fenster: ${data.elementAt(1).count.toString()}', style: TextStyle(fontSize: 18.0)),
                Text('Pfosten: ${data.elementAt(2).count.toString()}', style: TextStyle(fontSize: 18.0)),
              ],
            ),
            WorkloadChart(data: data),
            Text('Unbearbeitete Aufträge: 7', style: TextStyle(fontSize: 18.0)),
          ],
        ),
      ),
    );
  }
}
