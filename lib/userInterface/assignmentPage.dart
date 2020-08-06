import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/models/assignment.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';
import 'package:buehlmaier_app/userInterface/archivPage.dart';
import 'package:buehlmaier_app/userInterface/settingsPage.dart';
import 'package:buehlmaier_app/userInterface/workloadPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:buehlmaier_app/userInterface/newAssignmentPage.dart';
import 'package:buehlmaier_app/userInterface/editAssignmentPage.dart';

class AssignmentPage extends StatefulWidget {
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  int _selectedPrioChipIndex;
  String _currentStatusFilter;
  List<Assignment> _assignmentList;
  QuerySnapshot _assignments;
  List<DropdownMenuItem<String>> _dropdownMenuStatusFilter;
  List<String> _dropdownStatusFilter = [
    'Alle Aufträge',
    'Unbearbeiteter Auftrag',
    'Holzarbeiten in Bearbeitung',
    'Bereit zum Lackieren',
    'Beim Lackieren und Ausschlagen',
    'Fertig zum Einbau',
  ];

  @override
  void initState() {
    super.initState();
    _assignmentList = [];
    SystemSettings.allowOnlyPortraitOrientation();
    _dropdownMenuStatusFilter = getDropdownMenuItemsForStatusFilter();
    _currentStatusFilter = _dropdownMenuStatusFilter[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bühlmaier App'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.cog),
          onPressed: () => toPage(SettingsPage()),
        ),
        actions: <Widget>[
          popupMenu(),
        ],
      ),
      body: Column(
        children: [
          statusFilter(),
          FutureBuilder(
            future: loadAssignments(),
            builder: (context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Expanded(
                  child: ListView.builder(
                      itemCount: _assignments.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Card(
                            child: InkWell(
                              onTap: () => toPage(EditAssignmentPage(_assignments.documents[index].data['Id'])),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  title(index),
                                  orderType(index),
                                  creationDate(index),
                                  installationDate(index),
                                  glassDeliveryDate(index),
                                  aluminumDeliveryDate(index),
                                  status(index),
                                  priority(index),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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

  Widget statusFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Status: '),
        Container(
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: _currentStatusFilter,
                items: _dropdownMenuStatusFilter,
                onChanged: (String newPriority) {
                  setState(() {
                    _currentStatusFilter = newPriority;
                    // TODO
                  });
                },
              ),
            ),
          ),
        ),
      ],
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
            child: _assignments.documents[index].data['InstallationDate'] == ''
                ? Icon(FontAwesomeIcons.calendarTimes, size: 20.0)
                : Icon(FontAwesomeIcons.calendarCheck, size: 20.0),
          ),
          Text('Einbautermin: ${_assignments.documents[index].data['InstallationDate']?.toString() ?? ''}'),
        ],
      ),
    );
  }

  Widget glassDeliveryDate(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _assignments.documents[index].data['GlassDeliveryDate'] == ''
                ? Icon(FontAwesomeIcons.calendarTimes, size: 20.0)
                : Icon(FontAwesomeIcons.calendarCheck, size: 20.0),
          ),
          Text(_assignments.documents[index].data['IsGlassOrdered'] == true &&
                  _assignments.documents[index].data['GlassDeliveryDate'] == ''
              ? 'Glas ist bestellt'
              : 'Glas Liefertermin: ${_assignments.documents[index].data['GlassDeliveryDate']?.toString() ?? ''}'),
        ],
      ),
    );
  }

  Widget aluminumDeliveryDate(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
      child: Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: _assignments.documents[index].data['Aluminum'] == 0 ? true : false,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _assignments.documents[index].data['AluminumDeliveryDate'] == ''
                  ? Icon(FontAwesomeIcons.calendarTimes, size: 20.0)
                  : Icon(FontAwesomeIcons.calendarCheck, size: 20.0),
            ),
            Text(_assignments.documents[index].data['IsAluminumOrdered'] == true &&
                    _assignments.documents[index].data['AluminumDeliveryDate'] == ''
                ? 'Alu ist bestellt'
                : 'Alu Liefertermin: ${_assignments.documents[index].data['AluminumDeliveryDate']?.toString() ?? ''}'),
          ],
        ),
      ),
    );
  }

  Widget status(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 0.0),
      child: StatefulBuilder(builder: (BuildContext context, StateSetter setStatusState) {
        return Row(
          children: [
            Text('Status: ${_assignmentList[index].statusText}'),
            IconButton(
              icon: Icon(FontAwesomeIcons.arrowCircleRight),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => showSecurityDialog(index, setStatusState),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget showSecurityDialog(int index, StateSetter setStatusState) {
    return AlertDialog(
      title: Text('Nächste Status'),
      content: Text('Auftrag in den nächsten Status versetzen?'),
      actions: [
        FlatButton(
          child: Text('Nein'),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text('Ja'),
          onPressed: () => nextStatus(index, setStatusState),
        ),
      ],
      elevation: 24.0,
    );
  }

  void nextStatus(int index, StateSetter setStatusState) async {
    if (_assignmentList[index].statusText == 'Unbearbeiteter Auftrag') {
      _assignmentList[index].statusText = 'Holzarbeiten in Bearbeitung';
      _assignmentList[index].status = 1;
    } else if (_assignmentList[index].statusText == 'Holzarbeiten in Bearbeitung') {
      _assignmentList[index].statusText = 'Bereit zum Lackieren';
      _assignmentList[index].status = 2;
    } else if (_assignmentList[index].statusText == 'Bereit zum Lackieren') {
      _assignmentList[index].statusText = 'Beim Lackieren und Ausschlagen';
      _assignmentList[index].status = 3;
    } else if (_assignmentList[index].statusText == 'Beim Lackieren und Ausschlagen') {
      _assignmentList[index].statusText = 'Fertig zum Einbau';
      _assignmentList[index].status = 4;
    }
    await Firestore.instance.collection('assignments').document(_assignments.documents[index].data['Id']).updateData({
      'StatusText': _assignmentList[index].statusText,
      'Status': _assignmentList[index].status,
    });
    Navigator.pop(context);
    setStatusState(() {});
  }

  Widget priority(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 0.0, 12.0),
      child: StatefulBuilder(builder: (BuildContext context, StateSetter setPriorityState) {
        return Row(children: [
          GestureDetector(
            onTap: () => setPriority(0, index, setPriorityState),
            child: ChoiceChip(
              label: Text(_assignmentList[index].priority == 0 ? _assignmentList[index].priorityText : '  '),
              selected: _assignmentList[index].priority == 0,
              selectedColor: Colors.red,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: GestureDetector(
              onTap: () => setPriority(1, index, setPriorityState),
              child: ChoiceChip(
                label: Text(_assignmentList[index].priority == 1 ? _assignmentList[index].priorityText : '  '),
                selected: _assignmentList[index].priority == 1,
                selectedColor: Colors.yellowAccent,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setPriority(2, index, setPriorityState),
            child: ChoiceChip(
              label: Text(_assignmentList[index].priority == 2 ? _assignmentList[index].priorityText : '  '),
              selected: _assignmentList[index].priority == 2,
              selectedColor: Colors.green,
            ),
          ),
        ]);
      }),
    );
  }

  void setPriority(int chipIndex, int index, StateSetter setPriorityState) async {
    if (chipIndex == 0) {
      _assignmentList[index].priorityText = 'Warten auf Freigabe';
      _assignmentList[index].priority = 0;
    } else if (chipIndex == 1) {
      _assignmentList[index].priorityText = 'Kann produziert werden';
      _assignmentList[index].priority = 1;
    } else if (chipIndex == 2) {
      _assignmentList[index].priorityText = 'Muss/Ist in Produktion';
      _assignmentList[index].priority = 2;
    }
    _selectedPrioChipIndex = chipIndex;
    await Firestore.instance.collection('assignments').document(_assignments.documents[index].data['Id']).updateData({
      'PriorityText': _assignmentList[index].priorityText,
      'Priority': _assignmentList[index].priority,
    });
    setPriorityState(() {});
  }

  Future<void> loadAssignments() async {
    if (_currentStatusFilter == 'Alle Aufträge') {
      _assignments = await Firestore.instance.collection('assignments').getDocuments();
    } else {
      _assignments = await Firestore.instance.collection('assignments').where('StatusText', isEqualTo: _currentStatusFilter).getDocuments();
    }
    for (int i = 0; i < _assignments.documents.length; i++) {
      Assignment assignment = new Assignment(
        consumerName: _assignments.documents[i].data['Name'],
        orderType: _assignments.documents[i].data['OrderType'],
        numberOfElements: _assignments.documents[i].data['NumberOfElements'],
        installationDate: _assignments.documents[i].data['InstallationDate'],
        glassDeliveryDate: _assignments.documents[i].data['GlassDeliveryDate'],
        aluminumDeliveryDate: _assignments.documents[i].data['AluminumDeliveryDate'],
        status: _assignments.documents[i].data['Status'],
        aluminum: _assignments.documents[i].data['Aluminum'],
        statusText: _assignments.documents[i].data['StatusText'],
        isGlassOrdered: _assignments.documents[i].data['IsGlassOrdered'],
        isAluminumOrdered: _assignments.documents[i].data['IsAluminumOrdered'],
        priorityText: _assignments.documents[i].data['PriorityText'],
        priority: _assignments.documents[i].data['Priority'],
        creationDate: _assignments.documents[i].data['CreationDate'],
      );
      _assignmentList.insert(i, assignment);
    }
    // TODO hier weitermachen!!!
    /*for (int i = 0; i < _assignments.documents.length; i++) {
      print("Bevor CreationDate: ${_assignmentList.elementAt(i).creationDate}");
    }
    _assignmentList.sort((a,b) => a.creationDate.compareTo(b.creationDate));
    for (int i = 0; i < _assignments.documents.length; i++) {
      print("After CreationDate: ${_assignmentList.elementAt(i).creationDate}");
    }*/
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForStatusFilter() {
    List<DropdownMenuItem<String>> items = new List();
    for (String statusFilter in _dropdownStatusFilter) {
      items.add(new DropdownMenuItem(value: statusFilter, child: new Text(statusFilter)));
    }
    return items;
  }

  void toPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
