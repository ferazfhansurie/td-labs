// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StepBarMonthlyChart extends StatelessWidget {
  List<double> data;
  List<String> day;
  int? index;
  StepBarMonthlyChart({Key? key, required this.data, required this.day,this.index})
      : super(key: key);
  final List<Color> colors = [
    const Color.fromARGB(255, 83, 212, 169),
      const Color.fromARGB(255, 255, 145, 111),
      const Color.fromARGB(255, 216, 57, 183),
      const Color.fromARGB(255, 222, 74, 98),
      
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 242, 242, 244),
        body: Center(
            child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: CategoryAxis(),
                series: <ChartSeries>[
              LineSeries<ChartData, String>(
                  dataSource: [
                    ChartData(day[0].substring(0, 3), data[0],colors[index!]),
                    ChartData(day[1].substring(0, 3), data[1],colors[index!]),
                    ChartData(day[2].substring(0, 3), data[2],colors[index!]),
                    ChartData(day[3].substring(0, 3), data[3],colors[index!]),
                    ChartData(day[4].substring(0, 3), data[4],colors[index!]),
                    ChartData(day[5].substring(0, 3), data[5],colors[index!]),
                    ChartData(day[6].substring(0, 3), data[6],colors[index!])
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
