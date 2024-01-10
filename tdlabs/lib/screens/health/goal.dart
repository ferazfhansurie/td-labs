// ignore_for_file: prefer_final_fields, must_be_immutable, avoid_unnecessary_containers, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_field

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tdlabs/models/health/goals.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/spinbox/spin_box_goal.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({
    Key? key,
  }) : super(key: key);
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  int steps = 1000;
  int bpm = 50;
  int calories = 200;
  int achieved = 0;
  Goal? goal;
  List<Map<String, dynamic>> goals = [
    {
      "name": "Steps",
      "icon": Icons.directions_walk,
      "desc":
          "Keep Moving each day to meet your steps goal and avoid sedentary time",
      "goal": 1000,
      'step': 500,
    },
    {
      "name": "Heart Rate",
      "icon": Icons.favorite,
      "desc":
          "Set a daily goal for your heart rate to maintain a healthy cardiovascular system",
      "goal": 50,
      'step': 10,
    },
    {
      "name": "Calories",
      "icon": Icons.local_fire_department,
      "desc":
          "Set a daily goal for your calorie burn to maintain a healthy weight and energy balance",
      "goal": 200,
      'step': 50,
    }
  ];
  List<Map<String, dynamic>> types = [
    {
      "name": 'Steps',
      "icon": Icons.directions_walk,
      "desc":
          "Keep Moving each day to meet your steps goal and avoid sedentary time",
      "goal": 1000,
      "step": 500,
      "selected": false
    },
    {
      "name": 'Heart Rate',
      "icon": Icons.favorite,
      "desc":
          "Set a daily goal for your heart rate to maintain a healthy cardiovascular system",
      "goal": 50,
      "step": 10,
      "selected": false
    },
    {
      "name": 'Calories',
      "desc":
          "Set a daily goal for your calorie burn to maintain a healthy weight and energy balance",
      "goal": 200,
      "step": 50,
      "icon": Icons.local_fire_department,
      "selected": false
    },
    {
      "name": 'Body Mass Index',
      "desc":
          "Monitor your weight in relation to your height to assess overall health and the risk of developing certain diseases",
      "goal": 18,
      "step": 1,
      "icon": Icons.monitor_weight,
      "selected": false
    },
    {
      "name": 'Body Fat Percentage',
      "desc":
          "Monitor your weight in relation to your height to assess overall health and the risk of developing certain diseases",
      "goal": 5,
      "step": 1,
      "icon": Icons.percent,
      "selected": false
    },
    {
      "name": 'Mindfulness',
      "desc":
          "Reduce stress and anxiety, and improve mental well-being by practicing mindfulness techniques such as meditation, deep breathing, and yoga",
      "goal": 1,
      "step": 1,
      "icon": Icons.self_improvement,
      "selected": false
    },
    {
      "name": 'Sleep',
      "desc":
          "Improve sleep quality by setting a daily sleep goal and tracking your sleep patterns",
      "goal": 1,
      "step": 1,
      "icon": Icons.bed,
      "selected": false
    },
    {
      "name": 'Exercise',
      "desc":
          "Stay motivated and monitor your progress towards achieving your fitness goals by setting a daily exercise goal",
      "goal": 1,
      "step": 1,
      "icon": Icons.fitness_center,
      "selected": false
    },
  ];
  List<int> stepsPerDay = List.filled(7, 0);
  List<double> percent = List.filled(7, 0);
  @override
  void initState() {
    _fetchGoals();
    _getHistory();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getHistory() async {
    HealthFactory health = HealthFactory();
    var types = [
      HealthDataType.STEPS,
    ];

    var now = DateTime.now();
    // Set the date range for the query
    DateTime startTime = now.subtract(const Duration(hours: 12));
    DateTime endTime = now;
    for (int i = 0; i < stepsPerDay.length; i++) {
      if (i != 0) {
        startTime = startTime.subtract(const Duration(days: 1));
        endTime = endTime.subtract(const Duration(days: 1));
      }
      // Initialize variables for step count for each day

      // Fetch health data for the date range
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        startTime,
        endTime,
        types,
      );
      // Loop through the health data points and retrieve the step count for each day

      for (var point in healthData) {
        if (point.type == HealthDataType.STEPS) {
          // Get the day index for the data point
          stepsPerDay[i] += int.parse(point.value.toString());
        }
      }
      // Update the state with the step count for each day
    }

    setState(() {
      for (int i = 0; i < 7; i++) {
        percent[i] = stepsPerDay[i] / goal!.steps;
        if (percent[i] >= 1) {
          achieved++;
        }
      }
    });
  }

  Future<Goal?> _submitGoals(int steps) async {
    final webService = WebService(context);
    webService
        .setMethod('POST')
        .setEndpoint('identity/user-biodata-goals/update');
    Map<String, String> data = {};
    data['steps'] = steps.toString();
    data['duration'] = "0";
    var response = await webService.setData(data).send();
    if (response == null) return null;
    if (response.status) {
       Navigator.pop(context, steps);
    }
    return goal;
  }

  Future<Goal?> _fetchGoals() async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('identity/user-biodata-goals/get');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      Goal temp = Goal.fromJson(jsonDecode(response.body.toString()));
      if (temp != null) {
        setState(() {
          goal = temp;
        });
      }
    }
    return goal;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          child: SingleChildScrollView(
              child: Column(
            children: [
              const SizedBox(
                height: 35,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: CupertinoTheme.of(context).primaryColor,
                          size: 25,
                        ),
                      ),
                      const Spacer(),
                      /* GestureDetector(
                        onTap: () {
                          _showSettings();
                        },
                        child: Icon(
                          Icons.settings,
                          color: CupertinoTheme.of(context).primaryColor,
                          size: 25,
                        ),
                      ),*/
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 80 / 100,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    if (goal == null)
                      Container(
                          padding: const EdgeInsets.only(top: 35),
                          child:
                              const Center(child: CircularProgressIndicator())),
                    if (goal != null)
                      Flexible(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        goals[index]['name'],
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 18,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Icon(
                                        goals[index]['icon'],
                                        size: 18,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    goals[index]['desc'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SpinBoxGoal(
                                    min: goals[0]['goal'],
                                    max: 100000,
                                    value: goal!.steps,
                                    step: goals[index]['step'],
                                    onChanged: (value) {
                                      setState(() {
                                        steps = value;
                                      });
                                    },
                                  ),
                                  const Divider(),
                                ],
                              );
                            }),
                      ),
                    if (goal != null)
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 178, 178, 178)
                                    .withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 4,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          width: 650,
                          height: 120,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Daily Goals",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 18,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      const Icon(Icons.emoji_events)
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Last 7 Days",
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "$achieved/7",
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const Text(
                                          "Achieved",
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 50,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 7,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(0.5),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Visibility(
                                                      replacement: Container(
                                                        height: 10,
                                                      ),
                                                      visible:
                                                          (percent[index] >= 1),
                                                      child: const Icon(
                                                          Icons.check,
                                                          size: 10)),
                                                  CircularPercentIndicator(
                                                    radius: 15,
                                                    lineWidth: 5.0,
                                                    percent:
                                                        (percent[index] > 1)
                                                            ? 1
                                                            : percent[index],
                                                    progressColor:
                                                        const Color.fromARGB(
                                                            255, 26, 152, 226),
                                                    center:
                                                        CircularPercentIndicator(
                                                            backgroundColor:
                                                                Colors.white,
                                                            radius: 10.0,
                                                            lineWidth: 5.0,
                                                            percent: (percent[
                                                                        index] >
                                                                    1)
                                                                ? 1
                                                                : percent[
                                                                    index],
                                                            animation: true,
                                                            animationDuration:
                                                                1200,
                                                            progressColor:
                                                                const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    100,
                                                                    233,
                                                                    104)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
              SizedBox(
                width: 200,
                height: 46,
                child: CupertinoButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  disabledColor: CupertinoColors.inactiveGray,
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    setState(() {
                      goals[0]['steps'] = steps;
                    });
                    await _submitGoals(steps);
                   
                  },
                  child: Text('Submit'.tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          color: Colors.white)),
                ),
              )
            ],
          )),
        ),
      ),
    );
  }

}
