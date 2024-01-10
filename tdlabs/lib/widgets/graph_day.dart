// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StepBarDayChart extends StatelessWidget {
  List<double> data;
  StepBarDayChart({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <ChartSeries>[
          LineSeries<ChartData, String>(
              dataSource: [
            ChartData('12AM', 0, CupertinoTheme.of(context).primaryColor),
            ChartData('12PM', data[0], CupertinoTheme.of(context).primaryColor),
            ChartData('4PM', data[1], CupertinoTheme.of(context).primaryColor),
            ChartData('7PM', data[2], CupertinoTheme.of(context).primaryColor),
            ChartData('12AM ', data[3], CupertinoTheme.of(context).primaryColor)
              ],
              // Bind the color for all the data points from the data source
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y),
        ])));
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
