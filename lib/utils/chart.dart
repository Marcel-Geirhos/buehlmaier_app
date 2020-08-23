import 'package:flutter/material.dart';
import 'package:buehlmaier_app/models/workload.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class WorkloadChart extends StatelessWidget {
  final List<Workload> data;

  WorkloadChart({@required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Workload, String>> series = [
      charts.Series(
          id: "Workload",
          data: data,
          seriesColor: charts.ColorUtil.fromDartColor(Colors.white),
          domainFn: (Workload series, _) => series.name,
          measureFn: (Workload series, _) => series.count,
          colorFn: (Workload series, _) => series.barColor),
    ];
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'Auslastung',
                style: TextStyle(fontSize: 28.0, letterSpacing: 1.2),
              ),
              Expanded(
                child: charts.BarChart(
                  series,
                  animate: true,
                  animationDuration: Duration(milliseconds: 1200),
                  domainAxis: new charts.OrdinalAxisSpec(
                    renderSpec: new charts.SmallTickRendererSpec(
                      // Tick and Label styling here.
                      labelStyle: new charts.TextStyleSpec(
                          fontSize: 16, // size in Pts.
                          color: charts.MaterialPalette.white),
                      // Change the line colors to match text color.
                      lineStyle: new charts.LineStyleSpec(color: charts.MaterialPalette.white),
                    ),
                  ),
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                    renderSpec: new charts.GridlineRendererSpec(
                      // Tick and Label styling here.
                      labelStyle: new charts.TextStyleSpec(
                          fontSize: 16, // size in Pts.
                          color: charts.MaterialPalette.white),
                      // Change the line colors to match text color.
                      lineStyle: new charts.LineStyleSpec(color: charts.MaterialPalette.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsChart extends StatelessWidget {
  final List<Workload> data;
  final int index;

  StatisticsChart({@required this.data, @required this.index});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Workload, String>> series = [
      charts.Series(
          id: "Workload",
          data: data,
          seriesColor: charts.ColorUtil.fromDartColor(Colors.white),
          domainFn: (Workload series, _) => series.name,
          measureFn: (Workload series, _) => series.count,
          colorFn: (Workload series, _) => series.barColor),
    ];
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'Jahr',
                style: TextStyle(fontSize: 28.0, letterSpacing: 1.2),
              ),
              Expanded(
                child: charts.BarChart(
                  series,
                  animate: true,
                  animationDuration: Duration(milliseconds: 1200),
                  domainAxis: new charts.OrdinalAxisSpec(
                    renderSpec: new charts.SmallTickRendererSpec(
                      // Tick and Label styling here.
                      labelStyle: new charts.TextStyleSpec(
                          fontSize: 16, // size in Pts.
                          color: charts.MaterialPalette.white),
                      // Change the line colors to match text color.
                      lineStyle: new charts.LineStyleSpec(color: charts.MaterialPalette.white),
                    ),
                  ),
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                    renderSpec: new charts.GridlineRendererSpec(
                      // Tick and Label styling here.
                      labelStyle: new charts.TextStyleSpec(
                          fontSize: 16, // size in Pts.
                          color: charts.MaterialPalette.white),
                      // Change the line colors to match text color.
                      lineStyle: new charts.LineStyleSpec(color: charts.MaterialPalette.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
