import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/models/assignment.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';
import 'package:buehlmaier_app/userInterface/archivPage.dart';
import 'package:buehlmaier_app/userInterface/settingsPage.dart';
import 'package:buehlmaier_app/userInterface/workloadPage.dart';
import 'package:buehlmaier_app/userInterface/newAssignmentPage.dart';
import 'package:buehlmaier_app/userInterface/editAssignmentPage.dart';

class AssignmentPage extends StatefulWidget {
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  List<Assignment> _assignmentList = [];
  String _currentOrderType;
  QuerySnapshot _assignments;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
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
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: _assignments.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditAssignmentPage(_assignments.documents[index].data['Id'])));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(_assignments.documents[index].data['Name']),
                                Text('${_assignments.documents[index].data['NumberOfElements'].toString()} Stück'),
                                Text(_assignments.documents[index].data['OrderType']),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
                            child: Text(
                                'Erstellt am: ${_assignments.documents[index].data['CreationDate']?.toString() ?? ''}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
                            child: Text(
                                'Einbautermin: ${_assignments.documents[index].data['InstallationDate']?.toString() ?? ''}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
                            child: Text(
                                'Alu bestellt am: ${_assignments.documents[index].data['AluminumDeliveryDate']?.toString() ?? ''}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
                            child: Text(
                                'Glas bestellt am: ${_assignments.documents[index].data['GlassDeliveryDate']?.toString() ?? ''}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 24.0),
                            child: Text('Status: ${_assignments.documents[index].data['Status'].toString()}'),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          } else if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Daten werden geladen'));
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => toPage(NewAssignmentPage()),
        child: Icon(Icons.add),
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
      Assignment assignment = new Assignment(
          _assignments.documents[i].data['Name'],
          _assignments.documents[i].data['OrderType'],
          _assignments.documents[i].data['NumberOfElements'],
          _assignments.documents[i].data['InstallationDate'],
          _assignments.documents[i].data['GlassDeliveryDate'],
          _assignments.documents[i].data['AluminumDeliveryDate']);
      _assignmentList.insert(i, assignment);
    }
  }

  void toPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
