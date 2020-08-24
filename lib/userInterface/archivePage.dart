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
  bool _searched;
  String _currentArchiveYearFilter;
  List<Assignment> _assignmentList;
  QuerySnapshot _assignments;
  TextEditingController _consumerName = TextEditingController();
  List<DropdownMenuItem<String>> _dropdownMenuArchiveYearFilter;
  List<String> _dropdownArchiveYearFilter = [];
  Future _loadArchiveAssignments;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _searched = false;
    _assignmentList = new List<Assignment>();
    _dropdownMenuArchiveYearFilter = getDropdownMenuItemsForArchiveYearFilter();
    _currentArchiveYearFilter = _dropdownMenuArchiveYearFilter[0].value;
    _loadArchiveAssignments = loadArchiveAssignments();
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
          ExpansionTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(FontAwesomeIcons.filter, size: 20.0),
            ),
            title: Text('Filter'),
            children: <Widget>[
              archiveConsumerNameSearch(),
              archiveYearFilter(),
            ],
          ),
          FutureBuilder(
            future: _loadArchiveAssignments,
            builder: (context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done && _assignmentList.isNotEmpty) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: _assignmentList.length,
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
                return Center(child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text('Daten werden geladen'),
                ));
              } else if (_assignmentList.isEmpty) {
                return Center(child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text('Keine Aufträge gefunden'),
                ));
              }
              return Center(child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Text('Daten werden geladen'),
              ));
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
                '${_assignmentList.elementAt(index).consumerName}   ${_assignmentList.elementAt(index).numberOfElements.toString()} Stück',
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
      child: Text('Auftragsart: ${_assignmentList.elementAt(index).orderType ?? ''}'),
    );
  }

  Widget creationDate(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
      child: Text('Erstellt am: ${_assignmentList.elementAt(index).creationDate?.toString() ?? ''}'),
    );
  }

  Widget installationDate(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _assignmentList.elementAt(index).installationDate == '' ||
                    _assignmentList.elementAt(index).installationDate == null
                ? Icon(FontAwesomeIcons.calendarTimes, size: 20.0)
                : Icon(FontAwesomeIcons.calendarCheck, size: 20.0),
          ),
          Text('Einbautermin: ${_assignmentList.elementAt(index).installationDate?.toString() ?? ''}'),
        ],
      ),
    );
  }

  Widget archiveDate(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 24.0),
      child: Text('Archiviert am: ${_assignmentList.elementAt(index).archiveDate?.toString() ?? ''}'),
    );
  }

  Future<void> loadArchiveAssignments({String searchedConsumerName = ''}) async {
    if (_searched == false) {
      _assignmentList.clear();
      if (searchedConsumerName == '') {
        print('Test $searchedConsumerName');
        _assignments = await Firestore.instance
            .collection('archive_$_currentArchiveYearFilter')
            .orderBy('ArchiveDateMilliseconds', descending: false)
            .getDocuments();
        for (int i = 0; i < _assignments.documents.length; i++) {
          Assignment assignment = new Assignment(
            consumerName: _assignments.documents[i].data['Name'],
            orderType: _assignments.documents[i].data['OrderType'],
            numberOfElements: _assignments.documents[i].data['NumberOfElements'],
            installationDate: _assignments.documents[i].data['InstallationDate'],
            creationDate: _assignments.documents[i].data['CreationDate'],
            archiveDate: _assignments.documents[i].data['ArchiveDate'],
          );
          _assignmentList.add(assignment);
        }
      } else {
        QuerySnapshot allAssignments;
        for (int year = 2020; year <= DateTime.now().year; year++) {
          allAssignments = await Firestore.instance.collection('archive_$year').getDocuments();
        }
        _assignmentList.clear();
        for (int i = 0; i < allAssignments.documents.length; i++) {
          if (allAssignments.documents[i].data['Name']
              .toString()
              .toLowerCase()
              .contains(searchedConsumerName.toLowerCase())) {
            Assignment assignment = new Assignment(
              consumerName: allAssignments.documents[i].data['Name'],
              orderType: allAssignments.documents[i].data['OrderType'],
              numberOfElements: allAssignments.documents[i].data['NumberOfElements'],
              installationDate: allAssignments.documents[i].data['InstallationDate'],
              creationDate: allAssignments.documents[i].data['CreationDate'],
              archiveDate: allAssignments.documents[i].data['ArchiveDate'],
            );
            _assignmentList.add(assignment);
          }
        }
      }
    }
    setState(() {
      _searched = true;
    });
  }

  Widget archiveYearFilter() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text('Archivierungsjahr: '),
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

  Widget archiveConsumerNameSearch() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 16.0),
          child: Icon(FontAwesomeIcons.search, size: 20.0),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextFormField(
              controller: _consumerName,
              decoration: InputDecoration(
                labelText: 'Kundenname...',
                contentPadding: EdgeInsets.only(left: 10.0),
                suffixIcon: IconButton(icon: Icon(FontAwesomeIcons.timesCircle), onPressed: () => removeConsumerName()),
              ),
              onChanged: (consumerName) {
                _searched = false;
                loadArchiveAssignments(searchedConsumerName: consumerName);
              },
            ),
          ),
        ),
      ],
    );
  }

  void removeConsumerName() {
    _consumerName.clear();
    _searched = false;
    loadArchiveAssignments();
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForArchiveYearFilter() {
    for (int year = 2020; year <= DateTime.now().year; year++) {
      _dropdownArchiveYearFilter.add(year.toString());
    }
    List<DropdownMenuItem<String>> items = new List();
    for (String archiveYearFilter in _dropdownArchiveYearFilter) {
      items.add(DropdownMenuItem(value: archiveYearFilter, child: Text(archiveYearFilter)));
    }
    return items;
  }
}
