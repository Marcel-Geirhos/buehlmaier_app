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
  bool _isGlassOrdered = false;
  bool _isAluminumOrdered = false;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _loadAssignments = loadAssignments();
    _dropdownMenuOrderType = getDropdownMenuItemsForOrderType();
    _currentOrderType = _dropdownMenuOrderType[0].value;
    _dropdownMenuStatus = getDropdownMenuItemsForStatus();
    _currentStatus = _dropdownMenuStatus[0].value;
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
              padding: const EdgeInsets.fromLTRB(12.0, 24.0, 16.0, 0.0),
              child: Column(
                children: [
                  consumerName(),
                  orderType(),
                  numberOfElements(),
                  installationDate(),
                  glassDeliveryDate(),
                  aluminumDeliveryDate(),
                  status(),
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
        IconButton(
          icon: Icon(FontAwesomeIcons.calendarPlus, size: 22.0),
          onPressed: () {
            setState(() {
              selectInstallationDate(context);
            });
          },
        ),
        Text('Einbautermin: '),
        Text(_assignment.installationDate),
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
          value: _isGlassOrdered,
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
        Text('Glas Liefertermin: '),
        Text(_assignment.glassDeliveryDate == '' ? 'noch nicht bestellt' : _assignment.glassDeliveryDate),
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
      });
    }
  }

  void checkGlassOrdered(bool newValue) => setState(() {
    _isGlassOrdered = newValue;
    if (_isGlassOrdered) {
      // TODO: hier weitermachen! Here goes your functionality that remembers the user.
    } else {
      // TODO: Forget the user
    }
  });

  Widget aluminumDeliveryDate() {
    return Row(
      children: [
        Checkbox(
          value: _isAluminumOrdered,
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
        Text('Alu Liefertermin: '),
        Text(_assignment.aluminumDeliveryDate == '' ? 'noch nicht bestellt' : _assignment.aluminumDeliveryDate),
      ],
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
      });
    }
  }

  void checkAluminumOrdered(bool newValue) => setState(() {
    _isAluminumOrdered = newValue;
    if (_isAluminumOrdered) {
      // TODO: Here goes your functionality that remembers the user.
    } else {
      // TODO: Forget the user
    }
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
                      _assignment.status = 0;
                    } else if (_currentStatus == 'Holzarbeiten in Bearbeitung') {
                      _assignment.status = 1;
                    } else if (_currentStatus == 'Bereit zum Lackieren') {
                      _assignment.status = 2;
                    } else if (_currentStatus == 'Beim Lackieren und Ausschlagen') {
                      _assignment.status = 3;
                    } else if (_currentStatus == 'Fertig zum Einbau') {
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

  Widget buttonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: () => updateAssignment(),
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
    _assignments = await Firestore.instance.collection('assignments').document(widget.id).get();
    _assignment = new Assignment(
        _assignments.data['Name'],
        _assignments.data['OrderType'],
        _assignments.data['NumberOfElements'],
        _assignments.data['InstallationDate'],
        _assignments.data['GlassDeliveryDate'],
        _assignments.data['AluminumDeliveryDate'],
        _assignments.data['Status'],
        _assignments.data['StatusString']);
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
      'StatusString': _currentStatus,
    });
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
