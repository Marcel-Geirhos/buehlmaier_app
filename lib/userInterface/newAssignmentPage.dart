import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';
import 'package:buehlmaier_app/userInterface/assignmentPage.dart';

class NewAssignmentPage extends StatefulWidget {
  @override
  _NewAssignmentPageState createState() => _NewAssignmentPageState();
}

class _NewAssignmentPageState extends State<NewAssignmentPage> {
  int currentStep = 0;
  bool complete = false;
  String _currentOrderType;
  String _currentPriority;
  String _date;
  StepperType stepperType = StepperType.horizontal;
  TextEditingController _consumerName = TextEditingController();
  TextEditingController _numberOfElements = TextEditingController();
  CalendarController _calendarController = CalendarController();
  List<DropdownMenuItem<String>> _dropdownMenuOrderType;
  List<DropdownMenuItem<String>> _dropdownMenuPriority;
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
  List<String> _priority = ['Muss / Ist in Produktion', 'Kann produziert werden', 'Warten auf Freigabe'];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _dropdownMenuOrderType = getDropdownMenuItemsForOrderType();
    _currentOrderType = _dropdownMenuOrderType[0].value;
    _dropdownMenuPriority = getDropdownMenuItemsForPriority();
    _currentPriority = _dropdownMenuPriority[0].value;
    _calendarController = CalendarController();
    _progressDialog = ProgressDialog(context);
    _progressDialog.style(message: 'Neuer Auftrag wird erstellt...');
  }

  @override
  void dispose() {
    _consumerName.dispose();
    _numberOfElements.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neuer Auftrag'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stepper(
              controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                return Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Visibility(
                        visible: currentStep == 4 ? false : true,
                        child: RaisedButton(
                          onPressed: onStepContinue,
                          child: Text('Weiter', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 16.0),
                      child: Visibility(
                        visible: currentStep == 0 ? false : true,
                        child: RaisedButton(
                          onPressed: onStepCancel,
                          child: Text('Zurück', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                );
              },
              steps: [
                consumerNameStep(),
                orderTypeStep(),
                numberOfElementsStep(),
                dateStep(),
                prioStep(),
              ],
              currentStep: currentStep,
              onStepContinue: next,
              onStepCancel: cancel,
              onStepTapped: (step) => goTo(step),
            ),
          ),
          Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 12.0, right: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () => createNewAssignment(context),
                    child: Text('Erstellen', style: TextStyle(fontSize: 18.0)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Step consumerNameStep() {
    return Step(
      title: Text('Name des Kunden: ${_consumerName.text.toString()}'),
      isActive: true,
      state: StepState.indexed,
      content: Column(
        children: [
          TextFormField(
            controller: _consumerName,
            decoration: InputDecoration(
              labelText: 'Kundenname',
              prefixIcon: Icon(Icons.person, size: 22.0),
              contentPadding: const EdgeInsets.all(0),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Step orderTypeStep() {
    return Step(
      title: Text('Auftragsart: $_currentOrderType'),
      isActive: true,
      state: StepState.indexed,
      content: Column(
        children: [
          DropdownButton(
            value: _currentOrderType,
            items: _dropdownMenuOrderType,
            onChanged: changedDropdownOrderType,
          ),
        ],
      ),
    );
  }

  Step numberOfElementsStep() {
    return Step(
      title: Text('Anzahl Elemente: ${_numberOfElements.text.toString()}'),
      isActive: true,
      state: StepState.indexed,
      content: Column(
        children: [
          TextFormField(
            controller: _numberOfElements,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Anzahl Elemente'),
          ),
        ],
      ),
    );
  }

  Step dateStep() {
    return Step(
      title: Text('Einbautermin: ${_date == null ? '' : _date.toString()}'),
      isActive: true,
      state: StepState.indexed,
      content: Column(
        children: [
          TableCalendar(
            calendarController: _calendarController,
            locale: 'en_US',
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(
                color: Colors.green.shade700,
              ),
            ),
            onDaySelected: (date, events) {
              int year = date.year;
              int month = date.month;
              int day = date.day;
              String weekday = convertWeekday(date.weekday);
              _date = '$weekday $day.$month.$year';
            },
            calendarStyle: CalendarStyle(
              todayColor: Theme.of(context).backgroundColor,
              todayStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              weekendStyle: TextStyle(
                color: Colors.green.shade700,
              ),
              outsideWeekendStyle: TextStyle(
                color: Colors.green.shade700,
              ),
              selectedColor: Colors.blueAccent,
              selectedStyle: TextStyle(
                fontSize: 17.0,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              centerHeaderTitle: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Step prioStep() {
    return Step(
      title: Text('Priorität: $_currentPriority'),
      isActive: true,
      state: StepState.indexed,
      content: Column(
        children: [
          DropdownButton(
            value: _currentPriority,
            items: _dropdownMenuPriority,
            onChanged: changedDropdownPrio,
          ),
        ],
      ),
    );
  }

  next() {
    currentStep + 1 != 5 ? goTo(currentStep + 1) : setState(() => complete = true);
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() {
      currentStep = step;
      FocusScope.of(context).unfocus();
    });
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForOrderType() {
    List<DropdownMenuItem<String>> items = new List();
    for (String orderType in _orderType) {
      items.add(new DropdownMenuItem(value: orderType, child: new Text(orderType)));
    }
    return items;
  }

  void changedDropdownOrderType(String selectedChoice) {
    setState(() {
      _currentOrderType = selectedChoice;
    });
  }

  // TODO eine Funktion für alle Dopdownmenüs
  List<DropdownMenuItem<String>> getDropdownMenuItemsForPriority() {
    List<DropdownMenuItem<String>> items = new List();
    for (String priority in _priority) {
      items.add(new DropdownMenuItem(value: priority, child: new Text(priority)));
    }
    return items;
  }

  void changedDropdownPrio(String selectedChoice) {
    setState(() {
      _currentPriority = selectedChoice;
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

  void createNewAssignment(BuildContext context) async {
    final format = DateFormat('dd.MM.yyyy');
    int creationDateMilliseconds = DateTime.now().millisecondsSinceEpoch;
    String weekday = convertWeekday(DateTime.now().weekday);
    if (_consumerName.text.isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Bitte einen Kundenname eingeben.')));
    } else if (_numberOfElements.text.isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Bitte Anzahl Elemente eingeben.')));
    } else {
      _progressDialog.show();
      try {
        String autoGeneratedId = Firestore.instance.collection('assignments').document().documentID;
        await Firestore.instance.collection('assignments').document(autoGeneratedId).setData({
          'NumberOfElements': _numberOfElements.text.toString(),
          'OrderType': _currentOrderType,
          'Aluminum': _currentOrderType.contains('Alu') ? 0 : 2,
          'AluminumDeliveryDate': '',
          'InstallationDate': _date,
          'Name': _consumerName.text.toString(),
          'PriorityText': _currentPriority,
          'Priority': 0,
          'CreationDate': '$weekday ${format.format(DateTime.fromMillisecondsSinceEpoch(creationDateMilliseconds))}',
          'IsGlassOrdered': false,
          'IsAluminumOrdered': false,
          'GlassDeliveryDate': '',
          'Id': autoGeneratedId,
          'Status': 0,
          'StatusText': 'Unbearbeiteter Auftrag',
        });
      } catch (error) {
        print('Neuer Auftrag erstellen fehlgeschagen: ' + error);
      }
      _progressDialog.hide();
      setState(() {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssignmentPage()));
      });
    }
  }
}
