import 'package:flutter/material.dart';
import 'package:buehlmaier_app/utils/chart.dart';
import 'package:buehlmaier_app/models/workload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:buehlmaier_app/utils/systemSettings.dart';

class WorkloadPage extends StatefulWidget {
  @override
  _WorkloadPageState createState() => _WorkloadPageState();
}

class _WorkloadPageState extends State<WorkloadPage> {
  int _numberOfDoors;
  int _numberOfPosts;
  int _numberOfWindows;
  double _workload;
  QuerySnapshot _settings;
  QuerySnapshot _assignments;
  Future _loadedNumberOfSections;
  List<Workload> data = [];

  @override
  void initState() {
    super.initState();
    _numberOfDoors = 0;
    _numberOfPosts = 0;
    _numberOfWindows = 0;
    SystemSettings.allowOnlyPortraitOrientation();
    _loadedNumberOfSections = getNumberOfSections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auslastung'),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder(
            future: _loadedNumberOfSections,
            builder: (context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Auslastung: ${_workload?.toStringAsFixed(1) ?? ''} Wochen',
                        style: TextStyle(fontSize: 22.0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Türen: $_numberOfDoors', style: TextStyle(fontSize: 18.0)),
                        Text('Fenster: $_numberOfWindows', style: TextStyle(fontSize: 18.0)),
                        Text('Pfosten: $_numberOfPosts', style: TextStyle(fontSize: 18.0)),
                      ],
                    ),
                    WorkloadChart(data: data),
                    Text('Unbearbeitete Aufträge: 7', style: TextStyle(fontSize: 18.0)),
                  ],
                );
              }
              return CircularProgressIndicator();
            }),
      ),
    );
  }

  Future<void> getNumberOfSections() async {
    _assignments = await Firestore.instance.collection('assignments').getDocuments();
    for (int i = 0; i < _assignments.documents.length; i++) {
      int numberOfElements = int.parse(_assignments.documents[i].data['NumberOfElements']);
      String orderType = _assignments.documents[i].data['OrderType'];
      if (orderType == 'Haustüre') {
        _numberOfDoors += numberOfElements;
      } else if (orderType == 'Pfosten Riegel') {
        _numberOfPosts += numberOfElements;
      } else if (orderType == 'Leisten' || orderType == 'Sonstiges') {
        // Wird nicht erfasst.
      } else {
        _numberOfWindows += numberOfElements;
      }
    }
    calculateWorkload();
    addChartData();
  }

  Future<void> calculateWorkload() async {
    _settings = await Firestore.instance.collection('settings').getDocuments();
    int zFenster = _settings.documents[0].data['Z_fenster'];
    int zPfosten = _settings.documents[0].data['Z_pfosten'];
    int zTuer = _settings.documents[0].data['Z_tuer'];
    _workload = _numberOfWindows / zFenster + _numberOfPosts / zPfosten + _numberOfDoors / zTuer;
    setState(() {

    });
  }

  void addChartData() {
    data.add(Workload(
      name: 'Türen',
      count: _numberOfDoors,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ));
    data.add(Workload(
      name: 'Fenster',
      count: _numberOfWindows,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ));
    data.add(Workload(
      name: 'Pfosten',
      count: _numberOfPosts,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ));
  }
}