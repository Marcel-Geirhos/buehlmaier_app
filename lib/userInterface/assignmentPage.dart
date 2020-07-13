import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';
import 'package:buehlmaier_app/userInterface/archivPage.dart';
import 'package:buehlmaier_app/userInterface/bottomSheetPage.dart';
import 'package:buehlmaier_app/userInterface/settingsPage.dart';
import 'package:buehlmaier_app/userInterface/workloadPage.dart';
import 'package:buehlmaier_app/userInterface/newAssignmentPage.dart';

class AssignmentPage extends StatefulWidget {
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  BottomSheetPage bottomSheetPage = new BottomSheetPage();
  TextEditingController _consumerName = TextEditingController();

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
                    child: InkWell(
                      onTap: () => showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text('Kundenname:'),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _consumerName,
                                        decoration: InputDecoration(
                                          labelText: snapshot.data.documents[index].data['Name'].toString(),
                                          prefixIcon: Icon(Icons.person, size: 22.0),
                                          contentPadding: const EdgeInsets.all(0),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('${snapshot.data.documents[index].data['Name'].toString()}'),
                                Text('${snapshot.data.documents[index].data['NumberOfElements'].toString()} Stück'),
                                Text('${snapshot.data.documents[index].data['OrderType'].toString()}'),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
                            child: Text(
                                'Erstellt am: ${snapshot.data.documents[index].data['CreationDate']?.toString() ?? ''}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
                            child: Text(
                                'Einbautermin: ${snapshot.data.documents[index].data['InstallationDate']?.toString() ?? ''}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
                            child: Text(
                                'Alu bestellt: ${snapshot.data.documents[index].data['AluminumDeliveryDate']?.toString() ?? ''}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
                            child: Text(
                                'Glas bestellt: ${snapshot.data.documents[index].data['GlassDeliveryDate']?.toString() ?? ''}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 24.0),
                            child: Text('Status: ${snapshot.data.documents[index].data['Status'].toString()}'),
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

  Future<QuerySnapshot> loadAssignments() async {
    return await Firestore.instance.collection('assignments').getDocuments();
  }

  void toPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
