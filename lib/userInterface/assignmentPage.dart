import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/models/assignment.dart';
import 'package:buehlmaier_app/utils/helpFunctions.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';
import 'package:buehlmaier_app/userInterface/archivePage.dart';
import 'package:buehlmaier_app/userInterface/settingsPage.dart';
import 'package:buehlmaier_app/userInterface/workloadPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:buehlmaier_app/userInterface/statisticsPage.dart';
import 'package:buehlmaier_app/userInterface/newAssignmentPage.dart';
import 'package:buehlmaier_app/userInterface/editAssignmentPage.dart';

class AssignmentPage extends StatefulWidget {
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> with TickerProviderStateMixin {
  int _remainingDaysToInstallation;
  String _currentStatusFilter;
  String _currentOrderTypeFilter;
  List<Assignment> _assignmentList;
  QuerySnapshot _assignments;
  DocumentSnapshot _settings;
  List<DropdownMenuItem<String>> _dropdownMenuStatusFilter;
  List<String> _dropdownStatusFilter = [
    'Alle Aufträge',
    'Unbearbeiteter Auftrag',
    'Holzarbeiten in Bearbeitung',
    'Bereit zum Lackieren',
    'Beim Lackieren und Ausschlagen',
    'Fertig zum Einbau',
  ];
  List<DropdownMenuItem<String>> _dropdownMenuOrderTypeFilter;
  List<String> _dropdownOrderTypeFilter = [
    'Alle Aufträge',
    'Holz Alu Fenster IV 68',
    'Holz Alu Fenster IV 78',
    'Holz Alu Fenster IV 88',
    'Holzfenster IV 68',
    'Holzfenster IV 78',
    'Holzfenster IV 88',
    'Haustüre',
    'Pfosten Riegel',
    'Leisten',
    'Sonstiges'
  ];

  @override
  void initState() {
    super.initState();
    _assignmentList = [];
    SystemSettings.allowOnlyPortraitOrientation();
    _dropdownMenuStatusFilter = getDropdownMenuItemsForStatusFilter();
    _currentStatusFilter = _dropdownMenuStatusFilter[0].value;
    _dropdownMenuOrderTypeFilter = getDropdownMenuItemsForOrderTypeFilter();
    _currentOrderTypeFilter = _dropdownMenuOrderTypeFilter[0].value;
  }

  @override
  Widget build(BuildContext context) {
    getSettings();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
            ExpansionTile(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(FontAwesomeIcons.filter, size: 20.0),
              ),
              title: Text('Filter'),
              children: <Widget>[
                statusFilter(),
                orderTypeFilter(),
              ],
            ),
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
                      },
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - 120),
                    child: Center(child: Text('Daten werden geladen...')),
                  );
                }
                return Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - 120),
                  child: Center(child: Text('Daten werden geladen...')),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => toPage(NewAssignmentPage()),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget popupMenu() {
    return PopupMenuButton<int>(
      onSelected: (tapped) {
        setState(() {
          if (tapped == 0) {
            toPage(ArchivePage());
          } else if (tapped == 1) {
            toPage(StatisticsPage());
          } else if (tapped == 2) {
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
          child: Text('Statistiken'),
        ),
        PopupMenuDivider(
          height: 5,
        ),
        PopupMenuItem(
          value: 2,
          child: Text('Auslastung'),
        ),
      ],
      elevation: 16.0,
    );
  }

  Widget statusFilter() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text('Status: '),
        ),
        Container(
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: _currentStatusFilter,
                items: _dropdownMenuStatusFilter,
                onChanged: (String newStatus) {
                  setState(() {
                    _currentStatusFilter = newStatus;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget orderTypeFilter() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text('Auftragsart: '),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 110.0,
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: _currentOrderTypeFilter,
                items: _dropdownMenuOrderTypeFilter,
                onChanged: (String newOrderType) {
                  setState(() {
                    _currentOrderTypeFilter = newOrderType;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
                'In ${calculateRemainingDays(index) == 1 ? '$_remainingDaysToInstallation Tag' : '$_remainingDaysToInstallation Tagen'}'),
          ),
        ],
      ),
    );
  }

  int calculateRemainingDays(int index) {
    String tempInstallationDate = _assignments.documents[index].data['InstallationDate'].toString().split(" ").last;
    if (tempInstallationDate == "") {
      _remainingDaysToInstallation = 0;
      return _remainingDaysToInstallation;
    }
    DateTime installationDate = DateFormat('dd.MM.yyyy').parse(tempInstallationDate);
    if (DateTime.now().isAfter(installationDate)) {
      _remainingDaysToInstallation = 0;
      updatePriority(index);
      return _remainingDaysToInstallation;
    }
    _remainingDaysToInstallation = installationDate.difference(DateTime.now()).inDays + 1;
    if (_settings.data['RemainingDays'] >= _remainingDaysToInstallation) {
      updatePriority(index);
    }
    return _remainingDaysToInstallation;
  }

  Widget glassDeliveryDate(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _assignments.documents[index].data['GlassDeliveryDate'] == '' ||
                    _assignments.documents[index].data['GlassDeliveryDate'] == null
                ? Icon(FontAwesomeIcons.calendarTimes, size: 20.0)
                : Icon(FontAwesomeIcons.calendarCheck, size: 20.0),
          ),
          Text(_assignments.documents[index].data['IsGlassOrdered'] == true &&
                      _assignments.documents[index].data['GlassDeliveryDate'] == '' ||
                  _assignments.documents[index].data['GlassDeliveryDate'] == null
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
              child: _assignments.documents[index].data['AluminumDeliveryDate'] == '' ||
                      _assignments.documents[index].data['AluminumDeliveryDate'] == null
                  ? Icon(FontAwesomeIcons.calendarTimes, size: 20.0)
                  : Icon(FontAwesomeIcons.calendarCheck, size: 20.0),
            ),
            Text(_assignments.documents[index].data['IsAluminumOrdered'] == true &&
                        _assignments.documents[index].data['AluminumDeliveryDate'] == '' ||
                    _assignments.documents[index].data['AluminumDeliveryDate'] == null
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
            Text('${_assignmentList[index].statusText ?? ''}'),
            IconButton(
              icon: Icon(FontAwesomeIcons.arrowCircleRight),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _assignmentList[index].statusText == 'Fertig zum Einbau'
                    ? showArchiveSecurityDialog(index)
                    : showSecurityDialog(index, setStatusState),
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

  Widget showArchiveSecurityDialog(int index) {
    return AlertDialog(
      title: Text('Auftrag archivieren'),
      content: Text('Auftrag wirklich archivieren?\nDie Aktion kann nicht rückgängig gemacht werden!'),
      actions: [
        FlatButton(
          child: Text('Nein'),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text('Ja'),
          onPressed: () => archiveAssignment(index),
        ),
      ],
      elevation: 24.0,
    );
  }

  void archiveAssignment(int index) async {
    final format = DateFormat('dd.MM.yyyy');
    int archiveDateMilliseconds = DateTime.now().millisecondsSinceEpoch;
    String weekday = HelpFunctions.convertWeekday(DateTime.now().weekday);
    await Firestore.instance
        .collection('archive_${DateTime.now().year}')
        .document(_assignments.documents[index].data['Id'])
        .setData({
      'NumberOfElements': _assignmentList[index].numberOfElements,
      'OrderType': _assignmentList[index].orderType,
      'InstallationDate': _assignmentList[index].installationDate,
      'Name': _assignmentList[index].consumerName,
      'CreationDate': _assignmentList[index].creationDate,
      'ArchiveDate': '$weekday ${format.format(DateTime.fromMillisecondsSinceEpoch(archiveDateMilliseconds))}',
      'ArchiveDateMilliseconds': archiveDateMilliseconds,
      'Id': _assignments.documents[index].data['Id'],
    });
    await Firestore.instance.collection('assignments').document(_assignments.documents[index].data['Id']).delete();
    setState(() {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssignmentPage()));
    });
  }

  Widget priority(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 0.0, 12.0),
      child: StatefulBuilder(builder: (BuildContext context, StateSetter setPriorityState) {
        return Row(children: [
          GestureDetector(
            onTap: () => setPriority(0, index, setPriorityState),
            child: ChoiceChip(
              label: Text(_assignmentList[index].priority == 0 ? _assignmentList[index].priorityText : '  ',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              selected: _assignmentList[index].priority == 0,
              selectedColor: Colors.red,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: GestureDetector(
              onTap: () => setPriority(1, index, setPriorityState),
              child: ChoiceChip(
                label: Text(_assignmentList[index].priority == 1 ? _assignmentList[index].priorityText : '  ',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                selected: _assignmentList[index].priority == 1,
                selectedColor: Colors.yellowAccent,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setPriority(2, index, setPriorityState),
            child: ChoiceChip(
              label: Text(_assignmentList[index].priority == 2 ? _assignmentList[index].priorityText : '  ',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
    await Firestore.instance.collection('assignments').document(_assignments.documents[index].data['Id']).updateData({
      'PriorityText': _assignmentList[index].priorityText,
      'Priority': _assignmentList[index].priority,
    });
    setPriorityState(() {});
  }

  void updatePriority(int index) async {
    _assignmentList[index].priorityText = 'Muss/Ist in Produktion';
    _assignmentList[index].priority = 2;
    await Firestore.instance.collection('assignments').document(_assignments.documents[index].data['Id']).updateData({
      'PriorityText': _assignmentList[index].priorityText,
      'Priority': _assignmentList[index].priority,
    });
  }

  Future<void> loadAssignments() async {
    if (_currentStatusFilter == 'Alle Aufträge' && _currentOrderTypeFilter == 'Alle Aufträge') {
      _assignments = await Firestore.instance
          .collection('assignments')
          .orderBy('CreationDateMilliseconds', descending: false)
          .getDocuments();
    } else if (_currentStatusFilter != 'Alle Aufträge' && _currentOrderTypeFilter == 'Alle Aufträge') {
      _assignments = await Firestore.instance
          .collection('assignments')
          .where('StatusText', isEqualTo: _currentStatusFilter)
          .getDocuments();
    } else if (_currentStatusFilter == 'Alle Aufträge' && _currentOrderTypeFilter != 'Alle Aufträge') {
      _assignments = await Firestore.instance
          .collection('assignments')
          .where('OrderType', isEqualTo: _currentOrderTypeFilter)
          .getDocuments();
    } else {
      CollectionReference colRef = Firestore.instance.collection('assignments');
      Query query = colRef.where('StatusText', isEqualTo: _currentStatusFilter);
      query = query.where('OrderType', isEqualTo: _currentOrderTypeFilter);
      _assignments = await query.getDocuments();
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
        creationDateMilliseconds: _assignments.documents[i].data['CreationDateMilliseconds'],
      );
      _assignmentList.insert(i, assignment);
    }
  }

  void getSettings() async {
    try {
      _settings = await Firestore.instance.collection('settings').document('settings').get();
    } catch (error) {
      print("ERROR: " + error.toString());
    }
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForStatusFilter() {
    List<DropdownMenuItem<String>> items = new List();
    for (String statusFilter in _dropdownStatusFilter) {
      items.add(new DropdownMenuItem(value: statusFilter, child: Text(statusFilter)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForOrderTypeFilter() {
    List<DropdownMenuItem<String>> items = new List();
    for (String orderTypeFilter in _dropdownOrderTypeFilter) {
      items.add(new DropdownMenuItem(value: orderTypeFilter, child: Text(orderTypeFilter)));
    }
    return items;
  }

  void toPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
