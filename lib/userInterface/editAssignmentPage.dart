import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/models/assignment.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:buehlmaier_app/userInterface/assignmentPage.dart';

class EditAssignmentPage extends StatefulWidget {
  final String id;

  const EditAssignmentPage(this.id);

  @override
  _EditAssignmentState createState() => _EditAssignmentState();
}

class _EditAssignmentState extends State<EditAssignmentPage> {
  final _format = DateFormat('dd.MM.yyyy');
  Future _loadAssignments;
  DocumentSnapshot _assignments;
  Assignment _assignment;
  String _currentOrderType;
  String _currentStatus;
  String _currentPriority;
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
  List<DropdownMenuItem<String>> _dropdownMenuStatus;
  List<String> _dropdownStatus = [
    'Unbearbeiteter Auftrag',
    'Holzarbeiten in Bearbeitung',
    'Bereit zum Lackieren',
    'Beim Lackieren und Ausschlagen',
    'Fertig zum Einbau',
  ];
  List<DropdownMenuItem<String>> _dropdownMenuPriority;
  List<String> _dropdownPriority = [
    'Muss/Ist in Produktion',
    'Kann produziert werden',
    'Warten auf Freigabe',
  ];

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _loadAssignments = loadAssignments();
    _dropdownMenuOrderType = getDropdownMenuItemsForOrderType();
    _currentOrderType = _dropdownMenuOrderType[0].value;
    _dropdownMenuStatus = getDropdownMenuItemsForStatus();
    _currentStatus = _dropdownMenuStatus[0].value;
    _dropdownMenuPriority = getDropdownMenuItemsForPriority();
    _currentPriority = _dropdownMenuPriority[0].value;
  }

  @override
  void dispose() {
    _consumerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auftrag bearbeiten'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _loadAssignments,
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 24.0, 16.0, 0.0),
              child: Column(
                children: [
                  consumerName(),
                  orderType(),
                  numberOfElements(),
                  installationDate(),
                  glassDeliveryDate(),
                  aluminumDeliveryDate(),
                  status(),
                  prioritaet(),
                  buttonRow(),
                ],
              ),
            );
          } else {
            return Center(child: Text('Daten werden geladen'));
          }
        },
      ),
    );
  }

  Widget consumerName() {
    return Row(
      children: <Widget>[
        Text('Kundenname: '),
        Expanded(
          child: TextFormField(
            controller: _consumerName,
            decoration: InputDecoration(
              hintText: _assignment.consumerName,
              contentPadding: EdgeInsets.only(left: 10.0),
            ),
            onChanged: (newConsumerName) {
              _assignment.consumerName = newConsumerName;
            },
          ),
        ),
      ],
    );
  }

  Widget orderType() {
    return Row(
      children: [
        Text('Auftragsart: '),
        Container(
          width: 250,
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: _assignment.orderType,
                items: _dropdownMenuOrderType,
                onChanged: (String newOrderType) {
                  setState(() {
                    _assignment.orderType = newOrderType;
                    if (_assignment.orderType.contains('Alu')) {
                      _assignment.aluminum = 0;
                    } else {
                      _assignment.aluminum = 2;
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForOrderType() {
    List<DropdownMenuItem<String>> items = new List();
    for (String orderType in _orderType) {
      items.add(new DropdownMenuItem(value: orderType, child: new Text(orderType)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForStatus() {
    List<DropdownMenuItem<String>> items = new List();
    for (String status in _dropdownStatus) {
      items.add(new DropdownMenuItem(value: status, child: new Text(status)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForPriority() {
    List<DropdownMenuItem<String>> items = new List();
    for (String priority in _dropdownPriority) {
      items.add(new DropdownMenuItem(value: priority, child: new Text(priority)));
    }
    return items;
  }

  Widget numberOfElements() {
    return Row(
      children: [
        Text('Anzahl Elemente:'),
        Expanded(
          child: TextFormField(
            controller: _numberOfElements,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: _assignment.numberOfElements,
              contentPadding: EdgeInsets.only(left: 10.0),
            ),
            onChanged: (newNumberOfElements) {
              _assignment.numberOfElements = newNumberOfElements;
            },
          ),
        ),
      ],
    );
  }

  Widget installationDate() {
    return Row(
      children: [
        // Nur für besseres Design
        Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: false,
          child: Checkbox(
            value: _assignment.isGlassOrdered,
            onChanged: checkGlassOrdered,
          ),
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.calendarPlus, size: 22.0),
          onPressed: () {
            setState(() {
              selectInstallationDate(context);
            });
          },
        ),
        Text('Einbautermin:\n${_assignment?.installationDate ?? ''}'),
      ],
    );
  }

  Future<Null> selectInstallationDate(BuildContext context) async {
    final DateTime newInstallationDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2050),
    );
    if (newInstallationDate != null) {
      setState(() {
        String weekday = convertWeekday(newInstallationDate.weekday);
        _assignment.installationDate = weekday +
            ' ' +
            _format.format(DateTime.fromMillisecondsSinceEpoch(newInstallationDate.millisecondsSinceEpoch));
      });
    }
  }

  Widget glassDeliveryDate() {
    return Row(
      children: [
        Checkbox(
          value: _assignment.isGlassOrdered,
          onChanged: checkGlassOrdered,
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.calendarPlus, size: 22.0),
          onPressed: () {
            setState(() {
              selectGlassDeliveryDate(context);
            });
          },
        ),
        Text(_assignment.isGlassOrdered && _assignment.glassDeliveryDate == ''
            ? 'Glas ist bestellt'
            : _assignment.glassDeliveryDate == ''
                ? 'Glas noch nicht bestellt'
                : 'Glas Liefertermin:\n${_assignment.glassDeliveryDate}'),
      ],
    );
  }

  Future<Null> selectGlassDeliveryDate(BuildContext context) async {
    final DateTime newInstallationDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2050),
    );
    if (newInstallationDate != null) {
      setState(() {
        String weekday = convertWeekday(newInstallationDate.weekday);
        _assignment.glassDeliveryDate = weekday +
            ' ' +
            _format.format(DateTime.fromMillisecondsSinceEpoch(newInstallationDate.millisecondsSinceEpoch));
        _assignment.isGlassOrdered = true;
      });
    }
  }

  void checkGlassOrdered(bool newValue) => setState(() {
        _assignment.isGlassOrdered = newValue;
      });

  Widget aluminumDeliveryDate() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: _assignment.aluminum == 0 ? true : false,
      child: Row(
        children: [
          Checkbox(
            value: _assignment.isAluminumOrdered,
            onChanged: checkAluminumOrdered,
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.calendarPlus, size: 22.0),
            onPressed: () {
              setState(() {
                selectAluminumDeliveryDate(context);
              });
            },
          ),
          Text(_assignment.isAluminumOrdered && _assignment.aluminumDeliveryDate == ''
              ? 'Alu ist bestellt'
              : _assignment.aluminumDeliveryDate == ''
                  ? 'Alu noch nicht bestellt'
                  : 'Alu Liefertermin:\n${_assignment.aluminumDeliveryDate}'),
        ],
      ),
    );
  }

  Future<Null> selectAluminumDeliveryDate(BuildContext context) async {
    DateTime newInstallationDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2050),
    );
    if (newInstallationDate != null) {
      setState(() {
        String weekday = convertWeekday(newInstallationDate.weekday);
        _assignment.aluminumDeliveryDate = weekday +
            ' ' +
            _format.format(DateTime.fromMillisecondsSinceEpoch(newInstallationDate.millisecondsSinceEpoch));
        _assignment.isAluminumOrdered = true;
      });
    }
  }

  void checkAluminumOrdered(bool newValue) => setState(() {
        _assignment.isAluminumOrdered = newValue;
      });

  Widget status() {
    return Row(
      children: [
        Text('Status: '),
        Container(
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: _currentStatus,
                items: _dropdownMenuStatus,
                onChanged: (String newStatus) {
                  setState(() {
                    _currentStatus = newStatus;
                    if (_currentStatus == 'Unbearbeiteter Auftrag') {
                      _assignment.statusText = 'Unbearbeiteter Auftrag';
                      _assignment.status = 0;
                    } else if (_currentStatus == 'Holzarbeiten in Bearbeitung') {
                      _assignment.statusText = 'Holzarbeiten in Bearbeitung';
                      _assignment.status = 1;
                    } else if (_currentStatus == 'Bereit zum Lackieren') {
                      _assignment.statusText = 'Bereit zum Lackieren';
                      _assignment.status = 2;
                    } else if (_currentStatus == 'Beim Lackieren und Ausschlagen') {
                      _assignment.statusText = 'Beim Lackieren und Ausschlagen';
                      _assignment.status = 3;
                    } else if (_currentStatus == 'Fertig zum Einbau') {
                      _assignment.statusText = 'Fertig zum Einbau';
                      _assignment.status = 4;
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget prioritaet() {
    return Row(
      children: [
        Text('Priorität: '),
        Container(
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: _currentPriority,
                items: _dropdownMenuPriority,
                onChanged: (String newPriority) {
                  setState(() {
                    _currentPriority = newPriority;
                    if (_currentPriority == 'Muss/Ist in Produktion') {
                      _assignment.priorityText = 'Muss/Ist in Produktion';
                      _assignment.priority = 0;
                    } else if (_currentPriority == 'Kann produziert werden') {
                      _assignment.priorityText = 'Kann produziert werden';
                      _assignment.priority = 1;
                    } else if (_currentPriority == 'Warten auf Freigabe') {
                      _assignment.priorityText = 'Warten auf Freigabe';
                      _assignment.priority = 2;
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buttonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: () => updateAssignment(),
          child: Text('Aktualisieren'),
        ),
        RaisedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => showArchiveSecurityDialog(),
          ),
          child: Text('Archivieren'),
        ),
        RaisedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => showDeleteSecurityDialog(),
          ),
          child: Text('Löschen'),
        ),
      ],
    );
  }

  Widget showDeleteSecurityDialog() {
    return AlertDialog(
      title: Text('Auftrag löschen'),
      content: Text('Auftrag wirklich löschen?\nDer Auftrag kann nicht wiederhergestellt werden!'),
      actions: [
        FlatButton(
          child: Text('Nein'),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text('Ja'),
          onPressed: () => deleteAssignment(),
        ),
      ],
      elevation: 24.0,
    );
  }

  Widget showArchiveSecurityDialog() {
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
          onPressed: () => archiveAssignment(),
        ),
      ],
      elevation: 24.0,
    );
  }

  Future<void> loadAssignments() async {
    _assignments = await Firestore.instance.collection('assignments').document(widget.id).get();
    _assignment = new Assignment(
      consumerName: _assignments.data['Name'],
      orderType: _assignments.data['OrderType'],
      numberOfElements: _assignments.data['NumberOfElements'],
      installationDate: _assignments.data['InstallationDate'],
      glassDeliveryDate: _assignments.data['GlassDeliveryDate'],
      aluminumDeliveryDate: _assignments.data['AluminumDeliveryDate'],
      status: _assignments.data['Status'],
      aluminum: _assignments.data['Aluminum'],
      statusText: _assignments.data['StatusText'],
      isGlassOrdered: _assignments.data['IsGlassOrdered'],
      isAluminumOrdered: _assignments.data['IsAluminumOrdered'],
      priorityText: _assignments.data['PriorityText'],
      priority: _assignments.data['Priority'],
      creationDate: _assignments.data['CreationDate'],
    );
    if (_assignment.status == 0) {
      _currentStatus = 'Unbearbeiteter Auftrag';
    } else if (_assignment.status == 1) {
      _currentStatus = 'Holzarbeiten in Bearbeitung';
    } else if (_assignment.status == 2) {
      _currentStatus = 'Bereit zum Lackieren';
    } else if (_assignment.status == 3) {
      _currentStatus = 'Beim Lackieren und Ausschlagen';
    } else if (_assignment.status == 4) {
      _currentStatus = 'Fertig zum Einbau';
    }
    if (_assignment.priority == 0) {
      _currentPriority = 'Muss/Ist in Produktion';
    } else if (_assignment.priority == 1) {
      _currentPriority = 'Kann produziert werden';
    } else if (_assignment.priority == 2) {
      _currentPriority = 'Warten auf Freigabe';
    }
  }

  Future<void> updateAssignment() async {
    await Firestore.instance.collection('assignments').document(widget.id).updateData({
      'Name': _assignment.consumerName,
      'OrderType': _assignment.orderType,
      'NumberOfElements': _assignment.numberOfElements,
      'InstallationDate': _assignment.installationDate,
      'GlassDeliveryDate': _assignment.glassDeliveryDate,
      'AluminumDeliveryDate': _assignment.aluminumDeliveryDate,
      'Status': _assignment.status,
      'Aluminum': _assignment.aluminum,
      'StatusText': _currentStatus,
      'IsGlassOrdered': _assignment.isGlassOrdered,
      'IsAluminumOrdered': _assignment.isAluminumOrdered,
      'Priority': _assignment.priority,
      'PriorityText': _assignment.priorityText,
    });
    setState(() {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssignmentPage()));
    });
  }

  void archiveAssignment() async {
    final format = DateFormat('dd.MM.yyyy');
    int archiveDateMilliseconds = DateTime.now().millisecondsSinceEpoch;
    String weekday = convertWeekday(DateTime.now().weekday);
    await Firestore.instance.collection('archive_${DateTime.now().year}').document(widget.id).setData({
      'NumberOfElements': _assignment.numberOfElements,
      'OrderType': _assignment.orderType,
      'InstallationDate': _assignment.installationDate,
      'Name': _assignment.consumerName,
      'CreationDate': _assignment.creationDate,
      'ArchiveDate': '$weekday ${format.format(DateTime.fromMillisecondsSinceEpoch(archiveDateMilliseconds))}',
      'ArchiveDateMilliseconds': archiveDateMilliseconds,
      'Id': widget.id,
    });
    await Firestore.instance.collection('assignments').document(widget.id).delete();
    setState(() {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssignmentPage()));
    });
  }

  void deleteAssignment() async {
    await Firestore.instance.collection('assignments').document(widget.id).delete();
    setState(() {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssignmentPage()));
    });
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
}
