import 'package:flutter/material.dart';
import 'package:buehlmaier_app/utils/systemSettings.dart';

class ArchivPage extends StatefulWidget {
  @override
  _ArchivPageState createState() => _ArchivPageState();
}

class _ArchivPageState extends State<ArchivPage> {

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archiv'),
        centerTitle: true,
      ),
      body: Container(),
    );
  }
}
