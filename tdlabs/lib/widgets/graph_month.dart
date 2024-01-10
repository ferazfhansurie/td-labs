// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StepBarMonthlyChart extends StatelessWidget {
  List<double> data;
  List<String> day;
  StepBarMonthlyChart({Key? key, required this.data,required this.day}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <ChartSeries>[
          LineSeries<ChartData, String>(
              dataSource: [
            ChartData(day[0].substring(0,3), data[0], CupertinoTheme.of(context).primaryColor),
            ChartData(day[1].substring(0,3), data[1], CupertinoTheme.of(context).primaryColor),
            ChartData(day[2].substring(0,3), data[2], CupertinoTheme.of(context).primaryColor),
            ChartData(day[3].substring(0,3), data[3], CupertinoTheme.of(context).primaryColor),
            ChartData(day[4].substring(0,3), data[4], CupertinoTheme.of(context).primaryColor),
            ChartData(day[5].substring(0,3), data[5], CupertinoTheme.of(context).primaryColor),
            ChartData(day[6].substring(0,3), data[6], CupertinoTheme.of(context).primaryColor)
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
