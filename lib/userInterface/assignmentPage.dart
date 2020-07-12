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
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: Text('${snapshot.data.documents[index].data['Name'].toString()}'),
                    ),
                  );
                });
          } else if (snapshot.connectionState == ConnectionState.waiting) {
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

  Future<QuerySnapshot> loadAssignments() async {
    return await Firestore.instance.collection('assignments').getDocuments();
  }

  void toPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
