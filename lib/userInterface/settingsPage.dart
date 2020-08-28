import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _designState;
  int counterWindows;
  int counterDoors;
  int counterPost;
  Future _loadedSettings;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _loadedSettings = loadSettings();
    counterWindows = 0;
    counterDoors = 0;
    counterPost = 0;
    if (DynamicTheme.of(context).brightness == Brightness.dark) {
      _designState = true;
    } else {
      _designState = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _loadedSettings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                doorsSetting(),
                windowsSetting(),
                postSetting(),
                Divider(thickness: 1.5),
                darkLightModeSetting(),
                saveSettings(),
              ],
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
    );
  }

  Widget doorsSetting() {
    return ListTile(
      title: Row(
        children: [
          Text('Türen pro Woche:'),
          Padding(
            padding: const EdgeInsets.only(left: 80.0),
            child: IconButton(
              onPressed: () => setState(() {
                if (counterDoors > 0) {
                  counterDoors--;
                }
              }),
              icon: Icon(Icons.remove),
            ),
          ),
          Text('$counterDoors'),
          IconButton(
            onPressed: () => setState(() {
              counterDoors++;
            }),
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget windowsSetting() {
    return ListTile(
      title: Row(
        children: [
          Text('Fenster pro Woche:'),
          Padding(
            padding: const EdgeInsets.only(left: 70.0),
            child: IconButton(
              onPressed: () => setState(() {
                if (counterWindows > 0) {
                  counterWindows--;
                }
              }),
              icon: Icon(Icons.remove),
            ),
          ),
          Text('$counterWindows'),
          IconButton(
            onPressed: () => setState(() {
              counterWindows++;
            }),
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget postSetting() {
    return ListTile(
      title: Row(
        children: [
          Text('Pfosten Riegel pro Woche:'),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              onPressed: () => setState(() {
                if (counterPost > 0) {
                  counterPost--;
                }
              }),
              icon: Icon(Icons.remove),
            ),
          ),
          Text('$counterPost'),
          IconButton(
            onPressed: () => setState(() {
              counterPost++;
            }),
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget darkLightModeSetting() {
    return ListTile(
      title: Row(
        children: [
          Text('Dark Design:'),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Switch(
              value: _designState,
              onChanged: (bool newState) => setState(() {
                _designState = newState;
                changeBrightness();
              }),
            ),
          ),
        ],
      ),
    );
  }

  void changeBrightness() {
    if (_designState) {
      DynamicTheme.of(context).setBrightness(Brightness.dark);
    } else {
      DynamicTheme.of(context).setBrightness(Brightness.light);
    }
  }

  Widget saveSettings() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 12.0, right: 12.0),
        child: SizedBox(
          width: double.infinity,
          child: RaisedButton(
            onPressed: () => updateSettings(context),
            child: Text('Speichern', style: TextStyle(fontSize: 18.0)),
          ),
        ),
      ),
    );
  }

  Future<void> loadSettings() async {
    DocumentSnapshot settingData = await Firestore.instance.collection('settings').document('settings').get();
    counterWindows = settingData['Z_fenster'];
    counterDoors = settingData['Z_tuer'];
    counterPost = settingData['Z_pfosten'];
  }

  void updateSettings(BuildContext context) async {
    try {
      Firestore.instance.collection('settings').document('settings').updateData({
        'Z_fenster': counterWindows,
        'Z_pfosten': counterPost,
        'Z_tuer': counterDoors,
      });
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Einstellungen wurden erfolgreich gespeichert.')));
    } catch (error) {
      print("ERROR: " + error.toString());
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Unbekannter Fehler aufgetreten.')));
    }
  }
}
