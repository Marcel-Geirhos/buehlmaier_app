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
  Assignment _assignment;
  String _currentOrderType;
  TextEditingController _consumerName = TextEditingController();
  TextEditingController _numberOfElements = TextEditingController();
  List<DropdownMenuItem<String>> _dropdownMenuOrderType;
  DocumentSnapshot _assignments;
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
    _loadAssignments = loadAssignments();
    _dropdownMenuOrderType = getDropdownMenuItemsForOrderType();
    _currentOrderType = _dropdownMenuOrderType[0].value;
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
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
              child: Column(
                children: [
                  consumerName(),
                  orderType(),
                  numberOfElements(),
                  installationDate(),
                  glassDeliveryDate(),
                  aluminumDeliveryDate(),
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
        IconButton(
          icon: Icon(FontAwesomeIcons.calendarPlus, size: 22.0),
          onPressed: () {
            setState(() {
              selectGlassDeliveryDate(context);
            });
          },
        ),
        Text('Glas bestellt am: '),
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

  Widget aluminumDeliveryDate() {
    return Row(
      children: [
        IconButton(
          icon: Icon(FontAwesomeIcons.calendarPlus, size: 22.0),
          onPressed: () {
            setState(() {
              selectAluminumDeliveryDate(context);
            });
          },
        ),
        Text('Alu bestellt am: '),
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
        _assignments.data['Status']);
  }

  Future<void> updateAssignment() async {
    await Firestore.instance.collection('assignments').document(widget.id).updateData({
      'Name': _assignment.consumerName,
      'OrderType': _assignment.orderType,
      'NumberOfElements': _assignment.numberOfElements,
      'InstallationDate': _assignment.installationDate,
      'GlassDeliveryDate': _assignment.glassDeliveryDate,
      'AluminumDeliveryDate': _assignment.aluminumDeliveryDate,
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
