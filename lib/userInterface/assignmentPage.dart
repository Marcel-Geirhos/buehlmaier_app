import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';
import 'package:buehlmaier_app/userInterface/archivPage.dart';
import 'package:buehlmaier_app/userInterface/settingsPage.dart';
import 'package:buehlmaier_app/userInterface/workloadPage.dart';
import 'package:buehlmaier_app/userInterface/newAssignmentPage.dart';

class AssignmentPage extends StatefulWidget {
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  Future _loadAssignments;
  QuerySnapshot _assignments;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    //_loadAssignments = loadAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bühlmaier App'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => toPage(SettingsPage()),
        ),
        actions: <Widget>[
          popupMenu(),
        ],
      ),
      body: FutureBuilder(
        future: loadAssignments(),
        builder: (context, snapshot) {
          //if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                itemCount: _assignments.documents.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Text('${_assignments.documents[index].data['Name'].toString()}'),
                    ),
                  );
                });
          //} else if (snapshot.connectionState == ConnectionState.waiting) {
          //  return Center(child: CircularProgressIndicator());
          //}
          //return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => toPage(NewAssignmentPage()),
      ),
    );
  }

  Widget popupMenu() {
    return PopupMenuButton<int>(
      onSelected: (tapped) {
        setState(() {
          if (tapped == 0) {
            toPage(ArchivPage());
          } else if (tapped == 1) {
            toPage(WorkloadPage());
          }
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Text('Archiv'),
        ),
        PopupMenuDivider(
          height: 5,
        ),
        PopupMenuItem(
          value: 1,
          child: Text('Auslastung'),
        ),
      ],
      elevation: 16.0,
    );
  }

  Future<void> loadAssignments() async {
    _assignments = await Firestore.instance.collection('assignments').getDocuments();
    for (int i = 0; i < _assignments.documents.length; i++) {
      print('DATEN: ' + _assignments.documents[i].data['Name'].toString());
    }
    setState(() {});
  }

  void toPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
