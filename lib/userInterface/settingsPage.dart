import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int counterWindows;
  int counterDoors;
  int counterPost;
  Future _loadedSettings;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _loadedSettings = loadSettings();
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
                saveSettings(),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Center(child: CircularProgressIndicator());
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
          Text('Fenster pro Woche'),
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

  Widget saveSettings() {
    return Builder(
      builder: (context) => OutlineButton(
        child: Text('Einstellungen speichern'),
        onPressed: () => updateSettings(context),
        borderSide: BorderSide(width: 2.0, color: Color(0xFF555555)),
        padding: EdgeInsets.symmetric(horizontal: 60.0),
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
