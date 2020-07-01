import 'package:flutter/foundation.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Workload {
  final String name;
  final int count;
  final charts.Color barColor;

  Workload({@required this.name, @required this.count, @required this.barColor});
}