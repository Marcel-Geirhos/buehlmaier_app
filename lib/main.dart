import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:buehlmaier_app/userInterface/assignmentPage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(
      DynamicTheme(
        defaultBrightness: Brightness.dark,
        data: (brightness) => ThemeData(
          primarySwatch: Colors.indigo,
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            theme: theme,
            home: AssignmentPage(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate
            ],
            supportedLocales: [
              const Locale('de')
            ],
          );
        },
      ),
    );
