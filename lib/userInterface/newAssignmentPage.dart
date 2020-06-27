import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class NewAssignmentPage extends StatefulWidget {
  @override
  _NewAssignmentPageState createState() => _NewAssignmentPageState();
}

class _NewAssignmentPageState extends State<NewAssignmentPage> {
  String _date;
  int currentStep = 0;
  bool complete = false;
  String _currentOrderType;
  StepperType stepperType = StepperType.horizontal;
  TextEditingController _consumerName = TextEditingController();
  CalendarController _calendarController = CalendarController();
  List<DropdownMenuItem<String>> _dropdownMenuOrderType;
  List<String> _orderType = [
    'Holzfenster IV 68',
    'Holzfenster IV 78',
    'Holzfenster IV 88',
    'Holz Alu Fenster IV 68',
    'Holz Alu Fenster IV 78',
    'Holz Alu Fenster IV 88',
    'Haustüre',
    'Pfosten Riegel',
    'Leisten',
    'Sonstiges'
  ];

  @override
  void initState() {
    super.initState();
    _dropdownMenuOrderType = getDropdownMenuItemsForOrderType();
    _currentOrderType = _dropdownMenuOrderType[0].value;
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _consumerName.dispose();
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
              steps: [
                Step(
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
                ),
                Step(
                  title: const Text('Auftragsart: '),
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
                ),
                Step(
                  title: const Text('Anzahl Elemente: '),
                  isActive: true,
                  state: StepState.indexed,
                  content: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Anzahl Elemente'),
                      ),
                    ],
                  ),
                ),
                Step(
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
                ),
                Step(
                  title: const Text('Priorität: '),
                  isActive: true,
                  state: StepState.indexed,
                  content: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Priorität'),
                      ),
                    ],
                  ),
                ),
              ],
              currentStep: currentStep,
              onStepContinue: next,
              onStepCancel: cancel,
              onStepTapped: (step) => goTo(step),
            ),
          ),
          RaisedButton(
            onPressed: () => {},
            child: Text('Erstellen'),
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
    setState(() => currentStep = step);
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
