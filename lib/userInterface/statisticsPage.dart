import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _numberYears;
  List<int> _numberOfDoors;
  List<int> _numberOfPosts;
  List<int> _numberOfWindows;
  List<int> _overall;
  List<int> _completedAssignments;
  QuerySnapshot _assignmentStatistics;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _numberYears = 0;
    _numberOfDoors = [];
    _numberOfPosts = [];
    _numberOfWindows = [];
    _overall = [];
    _completedAssignments = [];
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
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
            child: Center(child: Text('Daten werden geladen...')),
          );
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
          margin: EdgeInsets.fromLTRB(5, 150, 5, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('$currentYear', style: TextStyle(fontSize: 32.0))),
              ),
              Divider(thickness: 5.0),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Türen: ${_numberOfDoors[index]}', style: TextStyle(fontSize: 18.0)),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Fenster: ${_numberOfWindows[index]}', style: TextStyle(fontSize: 18.0)),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Pfosten: ${_numberOfPosts[index]}', style: TextStyle(fontSize: 18.0)),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Insgesamt: ${_overall[index]}', style: TextStyle(fontSize: 18.0)),
              ),
              Divider(thickness: 5.0),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Abgeschlossene Aufträge: ${_completedAssignments[index]}', style: TextStyle(fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> loadAssignmentStatistics() async {
    int doors = 0;
    int posts = 0;
    int windows = 0;
    int overall = 0;
    int completedAssignments = 0;
    // TODO auf 2020 ändern!
    for (int year = 2019; year <= DateTime.now().year; year++, _numberYears++) {
      _assignmentStatistics = await Firestore.instance.collection('archive_$year').getDocuments();
      for (int i = 0; i < _assignmentStatistics.documents.length; i++) {
        int numberOfElements = int.parse(_assignmentStatistics.documents[i].data['NumberOfElements']);
        String orderType = _assignmentStatistics.documents[i].data['OrderType'];
        if (orderType == 'Haustüre') {
          doors += numberOfElements;
          overall += numberOfElements;
        } else if (orderType == 'Pfosten Riegel') {
          posts += numberOfElements;
          overall += numberOfElements;
        } else if (orderType == 'Leisten' || orderType == 'Sonstiges') {
          // Wird nicht erfasst.
        } else {
          windows += numberOfElements;
          overall += numberOfElements;
        }
        completedAssignments++;
      }
      _numberOfDoors.add(doors);
      _numberOfPosts.add(posts);
      _numberOfWindows.add(windows);
      _overall.add(overall);
      _completedAssignments.add(completedAssignments);
    }
  }
}
