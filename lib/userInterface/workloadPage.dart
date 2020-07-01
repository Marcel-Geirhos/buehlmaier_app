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
        child: WorkloadChart(data: data),
      ),
    );
  }
}