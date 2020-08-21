import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  QuerySnapshot _assignmentStatistics;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
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
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Column(
                    children: <Widget>[],
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> loadAssignmentStatistics() async {
    for (int year = 2020; year <= DateTime.now().year; year++) {
      _assignmentStatistics = await Firestore.instance.collection('archive_$year').getDocuments();
    }
  }
}
