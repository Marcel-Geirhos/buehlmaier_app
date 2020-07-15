import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/models/assignment.dart';
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
  List<Assignment> _assignmentList = [];
  final _format = DateFormat('dd.MM.yyyy');
  DateTime _date = DateTime.now();
  String _currentOrderType;
  //List<Assignment> _assignmentList;
  QuerySnapshot _assignments;
  TextEditingController _consumerName = TextEditingController();
  TextEditingController _numberOfElements = TextEditingController();
  List<DropdownMenuItem<String>> _dropdownMenuOrderType;
  List<String> _orderType = [
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
    SystemSettings.allowOnlyPortraitOrientation();
    _dropdownMenuOrderType = getDropdownMenuItemsForOrderType();
    _currentOrderType = _dropdownMenuOrderType[0].value;
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
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setModalBottomSheetState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    consumerName(_assignments.documents[index].data['Name'], index),
                                    orderType(setModalBottomSheetState, _assignments.documents[index].data['OrderType'],
                                        index),
                                    numberOfElements(
                                        _assignments.documents[index].data['NumberOfElements'].toString(), index),
                                    installationDate(setModalBottomSheetState, index),
                                    glassDeliveryDate(setModalBottomSheetState, index),
                                    aluminumDeliveryDate(setModalBottomSheetState, index),
                                    buttonRow(index),
                                  ],
                                );
                              });
                            });
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

  Widget consumerName(String consumerName, int index) {
    return Row(
      children: <Widget>[
        Text('Kundenname: '),
        Expanded(
          child: TextFormField(
            controller: _consumerName,
            decoration: InputDecoration(
              hintText: _assignmentList[index].consumerName,
              contentPadding: EdgeInsets.only(left: 10.0),
            ),
            onChanged: (newConsumerName) {
              _assignmentList[index].consumerName = newConsumerName;
            },
          ),
        ),
      ],
    );
  }

  Widget orderType(StateSetter setModalBottomSheetState, String orderType, int index) {
    return Row(
      children: [
        Text('Auftragsart: '),
        DropdownButton(
          value: _assignmentList[index].orderType,
          items: _dropdownMenuOrderType,
          onChanged: (String selectedChoice) {
            setModalBottomSheetState(
              () {
                _assignmentList[index].orderType = selectedChoice;
              },
            );
          },
        ),
      ],
    );
  }

  Widget numberOfElements(String numberOfElements, int index) {
    return Row(
      children: [
        Text('Anzahl Elemente:'),
        Expanded(
          child: TextFormField(
            controller: _numberOfElements,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: _assignmentList[index].numberOfElements,
              contentPadding: EdgeInsets.only(left: 10.0),
            ),
            onChanged: (newNumberOfElements) {
              _assignmentList[index].numberOfElements = newNumberOfElements;
            },
          ),
        ),
      ],
    );
  }

  /*Widget installationDate() {
    print(_dateTime);
    return Row(
      children: [
        Text('Einbautermin: '),
        Text(_dateTime == null
            ? 'Test' /*_assignments.documents[index].data['InstallationDate']*/ : _dateTime.toString()),
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            showDatePicker(
                    context: context, initialDate: DateTime.now(), firstDate: DateTime(2019), lastDate: DateTime(2050))
                .then(
              (date) => setState(
                () {
                  _dateTime = date;
                  /*print('Date: ' + _dateTime.toString());
                  int installationDateMilliseconds = _dateTime.millisecondsSinceEpoch;
                  final format = DateFormat('dd.MM.yyyy');

                  print('Index: ' + index.toString());
                  String weekday = convertWeekday(_dateTime.weekday);

                  _assignments.documents[index].data['InstallationDate'] =
                      weekday + ' ' + format.format(DateTime.fromMillisecondsSinceEpoch(installationDateMilliseconds));
                  test =
                      weekday + ' ' + format.format(DateTime.fromMillisecondsSinceEpoch(installationDateMilliseconds));
                  _assignments.documents[index].data['InstallationDate'] = test;
                  print(test);
                  print('Datumsformat: ' +
                      weekday +
                      ' ' +
                      format.format(DateTime.fromMillisecondsSinceEpoch(installationDateMilliseconds)));
                  print('Einbautermin: ' + _assignments.documents[index].data['InstallationDate']);*/
                },
              ),
            );
          },
        ),
      ],
    );
  }*/

  Widget installationDate(StateSetter setModalBottomSheetState, int index) {
    return Row(
      children: [
        Text('Einbautermin: '),
        Text(_assignmentList[index].installationDate),
        //Text(_assignments.documents[index].data['InstallationDate'].toString()),
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            setModalBottomSheetState(() {
              selectInstallationDate(context, setModalBottomSheetState, index);
            });
          },
        ),
      ],
    );
  }

  Widget glassDeliveryDate(StateSetter setModalBottomSheetState, int index) {
    return Row(
      children: [
        Text('Glas bestellt am: '),
        Text(_date.toString()),
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            setModalBottomSheetState(() {
              selectGlassDeliveryDate(context, setModalBottomSheetState);
            });
          },
        ),
      ],
    );
  }

  Widget aluminumDeliveryDate(StateSetter setModalBottomSheetState, int index) {
    return Row(
      children: [
        Text('Alu bestellt am: '),
        Text(_assignments.documents[index].data['aluminumDeliveryDate'].toString()),
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            setModalBottomSheetState(() {
              selectAluminumDeliveryDate(context, setModalBottomSheetState, index);
            });
          },
        ),
      ],
    );
  }

  Future<Null> selectInstallationDate(BuildContext context, StateSetter updateState, int index) async {
    final DateTime newInstallationDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2050),
    );
    if (newInstallationDate != null) {
      updateState(() {
        String weekday = convertWeekday(newInstallationDate.weekday);
        _assignmentList[index].installationDate = weekday +
            ' ' +
            _format.format(DateTime.fromMillisecondsSinceEpoch(newInstallationDate.millisecondsSinceEpoch));
      });
    }
  }

  Future<Null> selectGlassDeliveryDate(BuildContext context, StateSetter updateState) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2019),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _date) {
      updateState(() {
        _date = picked;
        //print(_date.toString());
      });
    }
  }

  Future<Null> selectAluminumDeliveryDate(BuildContext context, StateSetter updateState, int index) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), //_date,
      firstDate: DateTime(2019),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _date) {
      updateState(() {
        //_date = picked;
        //_assignmentList[index].aluminumDeliveryDate = picked.toString();
        _assignments.documents[index].data['AluminumDeliveryDate'] = picked.toString();
        //print(picked.toString());
        //print(_assignments.documents[index].data['AluminumDeliveryDate']);
      });
    }
  }

  Widget buttonRow(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: () => updateAssignment(index),
          child: Text('Aktualisieren'),
        ),
        RaisedButton(
          onPressed: () => {},
          child: Text('Archivieren'),
        ),
        RaisedButton(
          onPressed: () => {},
          child: Text('Löschen'),
        ),
      ],
    );
  }

  Future<void> loadAssignments() async {
    _assignments = await Firestore.instance.collection('assignments').getDocuments();
    for (int i = 0; i < _assignments.documents.length; i++) {
      print('Id: ${_assignments.documents[i].data['Id']}');
      print('InstallationDate: ${_assignments.documents[i].data['InstallationDate']}');
      print('OrderType: ${_assignments.documents[i].data['OrderType']}');
      Assignment assignment = new Assignment(
          _assignments.documents[i].data['Name'],
          _assignments.documents[i].data['OrderType'],
          _assignments.documents[i].data['NumberOfElements'],
          _assignments.documents[i].data['InstallationDate']);
      _assignmentList.add(assignment);
      print('InstallationDate2: ${_assignmentList[i].installationDate.toString()}');
      print('Test2: ${_assignmentList[i].orderType.toString()}');
    }
  }

  Future<void> updateAssignment(int index) async {
    String id = _assignments.documents[index].data['Id'];
    await Firestore.instance.collection('assignments').document(id).updateData({
      'Name': _assignmentList[index].consumerName,
      'OrderType': _assignmentList[index].orderType,
      'NumberOfElements': _assignmentList[index].numberOfElements,
      'InstallationDate': _assignmentList[index].installationDate.toString(),
    });
    setState(() {
      Navigator.pop(context);
    });
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForOrderType() {
    List<DropdownMenuItem<String>> items = new List();
    for (String orderType in _orderType) {
      items.add(new DropdownMenuItem(value: orderType, child: new Text(orderType)));
    }
    return items;
  }

  String convertWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Montag';
        break;
      case 2:
        return 'Dienstag';
        break;
      case 3:
        return 'Mittwoch';
        break;
      case 4:
        return 'Donnerstag';
        break;
      case 5:
        return 'Freitag';
        break;
      case 6:
        return 'Samstag';
        break;
      case 7:
        return 'Sonntag';
        break;
      default:
        return '';
    }
  }

  void toPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
