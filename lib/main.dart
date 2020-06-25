import 'package:flutter/material.dart';
import 'package:buehlmaier_app/userInterface/assignmentPage.dart';

void main() => runApp(
  MaterialApp(
    themeMode: ThemeMode.dark,
    darkTheme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
    home: AssignmentPage(),
  ),
);
