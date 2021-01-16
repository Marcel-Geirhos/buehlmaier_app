import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool isExpanded;
  int _numberYears;
  List<int> _numberOfDoors;
  List<int> _numberOfPosts;
  List<int> _numberOfWindows;
  List<int> _numberOfWoodAluWindows68;
  List<int> _numberOfWoodAluWindows78;
  List<int> _numberOfWoodAluWindows88;
  List<int> _numberOfWoodWindows68;
  List<int> _numberOfWoodWindows78;
  List<int> _numberOfWoodWindows88;

  List<String> _percentOfWoodAluWindows68;
  List<String> _percentOfWoodAluWindows78;
  List<String> _percentOfWoodAluWindows88;
  List<String> _percentOfWoodWindows68;
  List<String> _percentOfWoodWindows78;
  List<String> _percentOfWoodWindows88;

  List<int> _overall;
  List<int> _completedAssignments;
  QuerySnapshot _assignmentStatistics;
  Future _loadedAssignmentsStatistics;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    isExpanded = false;
    _numberYears = 0;
    _numberOfDoors = [];
    _numberOfPosts = [];
    _numberOfWindows = [];
    _numberOfWoodAluWindows68 = [];
    _numberOfWoodAluWindows78 = [];
    _numberOfWoodAluWindows88 = [];
    _numberOfWoodWindows68 = [];
    _numberOfWoodWindows78 = [];
    _numberOfWoodWindows88 = [];

    _percentOfWoodAluWindows68 = [];
    _percentOfWoodAluWindows78 = [];
    _percentOfWoodAluWindows88 = [];
    _percentOfWoodWindows68 = [];
    _percentOfWoodWindows78 = [];
    _percentOfWoodWindows88 = [];

    _overall = [];
    _completedAssignments = [];
    _loadedAssignmentsStatistics = loadAssignmentStatistics();
  }

  Future<void> loadAssignmentStatistics() async {
    for (int year = 2020; year <= DateTime.now().year; year++, _numberYears++) {
      int doors = 0, posts = 0, windows = 0, woodAluWindows68 = 0, woodAluWindows78 = 0, woodAluWindows88 = 0;
      int woodWindows68 = 0, woodWindows78 = 0, woodWindows88 = 0, overall = 0, completedAssignments = 0;
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
        } else {
          windows += numberOfElements;
          overall += numberOfElements;
          if (orderType == 'Holz Alu Fenster IV 68') {
            woodAluWindows68 += numberOfElements;
          } else if (orderType == 'Holz Alu Fenster IV 78') {
            woodAluWindows78 += numberOfElements;
          } else if (orderType == 'Holz Alu Fenster IV 88') {
            woodAluWindows88 += numberOfElements;
          } else if (orderType == 'Holzfenster IV 68') {
            woodWindows68 += numberOfElements;
          } else if (orderType == 'Holzfenster IV 78') {
            woodWindows78 += numberOfElements;
          } else if (orderType == 'Holzfenster IV 88') {
            woodWindows88 += numberOfElements;
          }
        }
        completedAssignments++;
      }
      _percentOfWoodAluWindows68.add(calculateWindowPercent(windows, woodAluWindows68));
      _percentOfWoodAluWindows78.add(calculateWindowPercent(windows, woodAluWindows78));
      _percentOfWoodAluWindows88.add(calculateWindowPercent(windows, woodAluWindows88));
      _percentOfWoodWindows68.add(calculateWindowPercent(windows, woodWindows68));
      _percentOfWoodWindows78.add(calculateWindowPercent(windows, woodWindows78));
      _percentOfWoodWindows88.add(calculateWindowPercent(windows, woodWindows88));
      _numberOfDoors.add(doors);
      _numberOfPosts.add(posts);
      _numberOfWindows.add(windows);
      _numberOfWoodAluWindows68.add(woodAluWindows68);
      _numberOfWoodAluWindows78.add(woodAluWindows78);
      _numberOfWoodAluWindows88.add(woodAluWindows88);
      _numberOfWoodWindows68.add(woodWindows68);
      _numberOfWoodWindows78.add(woodWindows78);
      _numberOfWoodWindows88.add(woodWindows88);
      _overall.add(overall);
      _completedAssignments.add(completedAssignments);
    }
  }

  String calculateWindowPercent(int numberOfAllWindows, int numberOfTypWindows) {
    double oneWindowPercent = 100 / numberOfAllWindows;
    return (oneWindowPercent * numberOfTypWindows).toStringAsFixed(0) + '%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiken'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _loadedAssignmentsStatistics,
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
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
            child: Center(child: Text('Daten werden geladen...')),
          );
        },
      ),
    );
  }

    Widget cardList(int index) {
      int currentYear = index + 2020;
      return Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                Card(
                  elevation: 8.0,
                  margin: EdgeInsets.fromLTRB(5, 50, 5, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: Text('$currentYear', style: TextStyle(fontSize: 32.0))),
                      ),
                      Center(child: Text(currentYear == 2020 ? 'Seit 18.06.2020' : '', style: TextStyle(fontSize: 16.0))),
                      Divider(thickness: 5.0),
                      Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Haustüren: ${_numberOfDoors[index]}', style: TextStyle(fontSize: 18.0)),
                    ),
                    ExpansionPanelList(
                      expansionCallback: (int item, bool status) {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      children: [
                        ExpansionPanel(
                            headerBuilder: (BuildContext context, bool isExpanded) {
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('Fenster: ${_numberOfWindows[index]}', style: TextStyle(fontSize: 18.0)),
                              );
                            },
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('Holz Alu Fenster 68:  ${_numberOfWoodAluWindows68[index]} Stk. / ${_percentOfWoodAluWindows68[index]}', style: TextStyle(fontSize: 14.0)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('Holz Alu Fenster 78:  ${_numberOfWoodAluWindows78[index]} Stk. / ${_percentOfWoodAluWindows78[index]}', style: TextStyle(fontSize: 14.0)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('Holz Alu Fenster 88:  ${_numberOfWoodAluWindows88[index]} Stk. / ${_percentOfWoodAluWindows88[index]}', style: TextStyle(fontSize: 14.0)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('Holzfenster 68:           ${_numberOfWoodWindows68[index]} Stk. / ${_percentOfWoodWindows68[index]}', style: TextStyle(fontSize: 14.0)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('Holzfenster 78:           ${_numberOfWoodWindows78[index]} Stk. / ${_percentOfWoodWindows78[index]}', style: TextStyle(fontSize: 14.0)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('Holzfenster 88:           ${_numberOfWoodWindows88[index]} Stk. / ${_percentOfWoodWindows88[index]}', style: TextStyle(fontSize: 14.0)),
                              ),
                            ],
                          ),
                          isExpanded: isExpanded,
                        ),
                      ],
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
            ),
          ),
        ],
      );
    }
  }
