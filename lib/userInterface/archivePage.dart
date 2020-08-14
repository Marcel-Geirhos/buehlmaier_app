import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/models/assignment.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ArchivePage extends StatefulWidget {
  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String _currentArchiveYearFilter;
  List<Assignment> _assignmentList;
  QuerySnapshot _assignments;
  List<DropdownMenuItem<String>> _dropdownMenuArchiveYearFilter;
  List<String> _dropdownArchiveYearFilter = [];

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _dropdownMenuArchiveYearFilter = getDropdownMenuItemsForArchiveYearFilter();
    _currentArchiveYearFilter = _dropdownMenuArchiveYearFilter[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archiv'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          archiveYearFilter(),
          FutureBuilder(
            future: loadArchiveAssignments(),
            builder: (context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: _assignments.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title(index),
                              orderType(index),
                              creationDate(index),
                              installationDate(index),
                              archiveDate(index),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text('Daten werden geladen'));
              }
              return Center(child: Text('Daten werden geladen'));
            },
          ),
        ],
      ),
    );
  }

  Widget title(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 8.0, 8.0, 8.0),
              child: AutoSizeText(
                '${_assignments.documents[index].data['Name']}   ${_assignments.documents[index].data['NumberOfElements'].toString()} Stück',
                minFontSize: 14.0,
                maxFontSize: 24.0,
                maxLines: 1,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget orderType(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
      child: Text('Auftragsart: ${_assignments.documents[index].data['OrderType'] ?? ''}'),
    );
  }

  Widget creationDate(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
      child: Text('Erstellt am: ${_assignments.documents[index].data['CreationDate']?.toString() ?? ''}'),
    );
  }

  Widget installationDate(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _assignments.documents[index].data['InstallationDate'] == '' ||
                    _assignments.documents[index].data['InstallationDate'] == null
                ? Icon(FontAwesomeIcons.calendarTimes, size: 20.0)
                : Icon(FontAwesomeIcons.calendarCheck, size: 20.0),
          ),
          Text('Einbautermin: ${_assignments.documents[index].data['InstallationDate']?.toString() ?? ''}'),
        ],
      ),
    );
  }

  Widget archiveDate(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 24.0),
      child: Text('Archiviert am: ${_assignments.documents[index].data['ArchiveDate']?.toString() ?? ''}'),
    );
  }

  Future<void> loadArchiveAssignments() async {
    _assignments = await Firestore.instance.collection('archive_$_currentArchiveYearFilter').orderBy('ArchiveDateMilliseconds', descending: false).getDocuments();
    for (int i = 0; i < _assignments.documents.length; i++) {
      Assignment assignment = new Assignment(
        consumerName: _assignments.documents[i].data['Name'],
        orderType: _assignments.documents[i].data['OrderType'],
        numberOfElements: _assignments.documents[i].data['NumberOfElements'],
        installationDate: _assignments.documents[i].data['InstallationDate'],
        creationDate: _assignments.documents[i].data['CreationDate'],
        archiveDate: _assignments.documents[i].data['ArchiveDate'],
      );
      _assignmentList.insert(i, assignment);
    }
  }

  Widget archiveYearFilter() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text('Jahr: '),
        ),
        Container(
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: _currentArchiveYearFilter,
                items: _dropdownMenuArchiveYearFilter,
                onChanged: (String newArchiveYear) {
                  setState(() {
                    _currentArchiveYearFilter = newArchiveYear;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForArchiveYearFilter() {
    for (int i = 2020; i <= DateTime.now().year; i++) {
      _dropdownArchiveYearFilter.add(i.toString());
    }
    List<DropdownMenuItem<String>> items = new List();
    for (String archiveYearFilter in _dropdownArchiveYearFilter) {
      items.add(DropdownMenuItem(value: archiveYearFilter, child: Text(archiveYearFilter)));
    }
    return items;
  }
}
