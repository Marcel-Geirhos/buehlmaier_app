import 'package:flutter/material.dart';

class HelpFunctions {
  static String convertWeekday(int weekday) {
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
