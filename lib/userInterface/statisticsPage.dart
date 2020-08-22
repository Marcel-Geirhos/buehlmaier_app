import 'package:flutter/material.dart';
import 'package:buehlmaier_app/utils/chart.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:buehlmaier_app/models/workload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:buehlmaier_app/utils/systemSettings.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _numberYears;
  List<int> _numberOfDoors = [];
  List<int> _numberOfPosts = [];
  List<int> _numberOfWindows = [];
  List<Workload> data = [];
  QuerySnapshot _assignmentStatistics;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _numberYears = 0;
    /*_numberOfDoors = 0;
    _numberOfPosts = 0;
    _numberOfWindows = 0;*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiken'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: loadAssignmentStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Swiper(
              itemCount: _numberYears,
              scale: 0.9,
              viewportFraction: 0.8,
              loop: false,
              itemBuilder: (BuildContext context, int index) {
                return cardList(index);
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget cardList(int index) {
    int currentYear = index + 2019; // TODO auf 2020 ändern!
    return ListView(
      children: <Widget>[
        Card(
          elevation: 8.0,
          margin: EdgeInsets.fromLTRB(5, 100, 5, 80),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('$currentYear', style: TextStyle(fontSize: 32.0)),
              ),
              StatisticsChart(data: data, index: index),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> loadAssignmentStatistics() async {
    int chartNumber = 0;
    int doors = 0;
    int posts = 0;
    int windows = 0;
    // TODO auf 2020 ändern!
    for (int year = 2019; year <= DateTime.now().year; year++, _numberYears++, chartNumber++) {
      _assignmentStatistics = await Firestore.instance.collection('archive_$year').getDocuments();
      for (int i = 0; i < _assignmentStatistics.documents.length; i++) {
        int numberOfElements = int.parse(_assignmentStatistics.documents[i].data['NumberOfElements']);
        String orderType = _assignmentStatistics.documents[i].data['OrderType'];
        if (orderType == 'Haustüre') {
          doors += numberOfElements;
        } else if (orderType == 'Pfosten Riegel') {
          posts += numberOfElements;
        } else if (orderType == 'Leisten' || orderType == 'Sonstiges') {
          // Wird nicht erfasst.
        } else {
          windows += numberOfElements;
        }
      }
      _numberOfDoors.add(doors);
      _numberOfPosts.add(posts);
      _numberOfWindows.add(windows);
      addChartData(chartNumber);
    }
  }

  void addChartData(int index) {
    data.add(Workload(
      name: 'Türen',
      count: _numberOfDoors[index],
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ));
    data.add(Workload(
      name: 'Fenster',
      count: _numberOfWindows[index],
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ));
    data.add(Workload(
      name: 'Pfosten',
      count: _numberOfPosts[index],
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ));
    for (int i = 0; i < data.length; i++) {
      print(data[i].count);
    }
  }
}
