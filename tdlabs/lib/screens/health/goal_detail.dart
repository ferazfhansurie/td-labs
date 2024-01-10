// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:tdlabs/models/health/activities.dart';
import 'package:tdlabs/screens/health/activity_add.dart';
import 'package:tdlabs/screens/health/activity_summary.dart';
import 'package:tdlabs/screens/health/activity_track.dart';
import 'package:tdlabs/screens/health/goal.dart';
import '../../adapters/util/activity_view.dart';
import '../../config/main.dart';
import '../../models/health/biodata.dart';
import '../../models/health/goals.dart';
import '../../models/user/user.dart';
import '../../utils/web_service.dart';
import '../user/bio_form.dart';

class GoalDetail extends StatefulWidget {
  final DateTime? time;
  final int? sales;
  const GoalDetail({Key? key, this.time, this.sales}) : super(key: key);
  @override
  State<GoalDetail> createState() => _GoalDetailState();
}

class _GoalDetailState extends State<GoalDetail> {
  String _name = '';
  String accessToken = '';
  String _points = '';
  NumberFormat myFormat = NumberFormat("#,##0.00", "en_US");
  late Widget _statusWidget;
  double goal = 0.0;
  Goal? _goal;
  String steps = "0";
  String bpm = "0";
  String calories = "0";
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final bmiController = TextEditingController();
  late Timer _timer;
  String _currentTime = "";
  List<Activity> activities = [];
  List<int> stepsPerDay = List.filled(7, 0);
  List<double> percent = List.filled(7, 0);
  int achieved = 0;
  bool isLoading = false;
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  String _getCurrentTime() {
    DateTime now = DateTime.now();
    String period = now.hour < 12 ? 'AM' : 'PM';
    int hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    String hourString = hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');
    String second = now.second.toString().padLeft(2, '0');
    return "$hourString:$minute:$second $period";
  }

  Future<BioData?> fetchBio(BuildContext context) async {
    final webService = WebService(context);
    BioData? bioData;
    var response =
        await webService.setEndpoint('identity/user-biodatas/get').send();
    if (response == null) return null;
    if (response.status) {
      BioData bioData = BioData.fromJson(jsonDecode(response.body.toString()));
      weightController.text = bioData.weight!;
      heightController.text = bioData.height!;
      bmiController.text = bioData.bmi!;
    }
    return bioData;
  }

  List<Map<String, dynamic>> activity = [];
  List<Map<String, dynamic>> goals = [
    {
      "name": "Steps",
      "icon": Icons.directions_walk,
      "value": 0,
    },
    {
      "name": "Heart Rate",
      "icon": Icons.favorite,
      "value": 0,
    },
    {
      "name": "Calories",
      "icon": Icons.local_fire_department,
      "value": 0,
    }
  ];
  List<HealthWorkoutActivityType>? add_activities = [];
  Future<void> _fetchUser() async {
    User? user = await User.fetchOne(context); // get current user
    var response = await Activity.get(context);
    final Map<String, Icon> activityIcons = {
      "WEIGHTLIFTING": const Icon(Icons.fitness_center),
      "HIKING": const Icon(Icons.hiking),
      "RUNNING": const Icon(Icons.directions_run),
      "WALKING": const Icon(Icons.directions_walk),
      "CYCLING": const Icon(Icons.directions_bike),
      "SWIMMING": const Icon(Icons.pool),
      "ROWING": const Icon(Icons.rowing),
      "YOGA": const Icon(Icons.self_improvement),
      "DANCE": const Icon(Icons.dangerous),
      "MARTIAL_ARTS": const Icon(Icons.fitness_center),
      "MEDITATION": const Icon(Icons.self_improvement),
      "WHEELCHAIR": const Icon(Icons.accessible_forward),
      "CLIMBING": const Icon(Icons.assistant_outlined),
      "SKIING": const Icon(Icons.ac_unit),
      "SNOWBOARDING": const Icon(Icons.ac_unit),
      "BOXING": const Icon(Icons.sports_mma),
      "KICKBOXING": const Icon(Icons.sports_mma),
      "KARATE": const Icon(Icons.self_improvement),
      "TAI_CHI": const Icon(Icons.self_improvement),
      "PILATES": const Icon(Icons.self_improvement),
      "ZUMBA": const Icon(Icons.dangerous),
      "SPINNING": const Icon(Icons.directions_bike),
      "CIRCUIT_TRAINING": const Icon(Icons.fitness_center),
      "CROSSFIT": const Icon(Icons.fitness_center),
      "HIIT": const Icon(Icons.fitness_center),
      "TRIATHLON": const Icon(Icons.fitness_center),
      "BASKETBALL": const Icon(Icons.sports_basketball),
      "FOOTBALL": const Icon(Icons.sports_football),
      "SOCCER": const Icon(Icons.sports_soccer),
      "VOLLEYBALL": const Icon(Icons.sports_volleyball),
      "TENNIS": const Icon(Icons.sports_tennis),
      "BASEBALL": const Icon(Icons.sports_baseball),
      "ICE_HOCKEY": const Icon(CupertinoIcons.sportscourt),
      "SKATEBOARDING": const Icon(Icons.skateboarding),
      "SURFING": const Icon(Icons.surfing),
      "SNOWSHOEING": const Icon(Icons.ac_unit),
      "CURLING": const Icon(Icons.sports_hockey),
      "WRESTLING": const Icon(Icons.sports_mma),
      "WATER_POLO": const Icon(Icons.pool),
    };
    if (user != null) {
      setState(() {
        _name = user.name!;
        var convert2 = double.parse(user.credit!);
        _points = myFormat.format(convert2);
        var arr = _points.split('.');
        _points = arr[0];
      });
    }
    if (response!.status) {
      setState(() {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        activities =
            parseList.map<Activity>((json) => Activity.fromJson(json)).toList();
        for (int i = 0; i < activities.length; i++) {
          if (!activity.any((a) =>
              a['name'] == activities[i].name!.toLowerCase().capitalizeFirst)) {
            var icon = activityIcons[activities[i].name] ??
                const Icon(Icons.directions_walk);
            activity.add({
              'name': activities[i].name,
              'icon': icon,
              'created': activities[i].created_at
            });
          }
        }
      });
    }
  }

  Future<void> _refreshContent() async {
    activity.clear();

    await _getHealth();

    await _fetchUser();

    fetchBio(context);
  }

  @override
  void initState() {
    super.initState();
    _startTimer();

    if (mounted) {
      _refreshContent();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  Future<Goal?> _fetchGoals() async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('identity/user-biodata-goals/get');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      setState(() {
        Goal temp = Goal.fromJson(jsonDecode(response.body.toString()));
        _goal = temp;
      });
    }
    return _goal;
  }

  @override
  Widget build(BuildContext context) {
    status();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 242, 244),
      body: RefreshIndicator(
        onRefresh: _refreshContent,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(
                   
                  ),
                  child: _header()),
              Padding(
                padding: const EdgeInsets.only(
                  top: 15,
                  left: 15,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 5 / 10,
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(80.0),
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 52, 169, 176),
                                Color.fromARGB(255, 49, 42, 130),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    45 /
                                    100,
                                child: (isLoading == false)
                                    ? _healthWidget()
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text('Loading',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              )),
                                          CircularProgressIndicator()
                                        ],
                                      ),
                              ))),
                    ],
                  ),
                ),
              ),
              activity_Customize(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 5 / 22,
                width: double.infinity,
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 0, right: 16, left: 22),
                  itemCount: activity.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final List<Color> colors = [
                      const Color.fromARGB(255, 0, 170, 235),
                      const Color.fromARGB(255, 27, 117, 184),
                      const Color.fromARGB(255, 83, 212, 169),
                    ];

                    Color getColorForIndex(int index) {
                      return colors[index % colors.length];
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivitySummary(
                                    name: activity[index]['name'],
                                    created: activity[index]['created'],
                                    image: activity[index]['icon'],
                                    color: getColorForIndex(index)),
                              ));
                        },
                        child: ActivityView(
                            name: activity[index]['name'],
                            image: activity[index]['icon'],
                            color: getColorForIndex(index),
                            index: index),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 5 / 250),
              body_Measure(),
              SizedBox(height: MediaQuery.of(context).size.height * 5 / 220),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          showAdd();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: CupertinoTheme.of(context).primaryColor,
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.add, color: Colors.white, size: 35),
          ),
        ),
      ),
    );
  }

  _getHealth() async {
    await _fetchGoals();
    stepsPerDay = List.filled(7, 0);
    HealthFactory health = HealthFactory();
    var types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WORKOUT,
    ];
    final Map<String, Icon> activityIcons = {
      "WEIGHTLIFTING": const Icon(Icons.fitness_center),
      "HIKING": const Icon(Icons.hiking),
      "RUNNING": const Icon(Icons.directions_run),
      "WALKING": const Icon(Icons.directions_walk),
      "CYCLING": const Icon(Icons.directions_bike),
      "SWIMMING": const Icon(Icons.pool),
      "ROWING": const Icon(Icons.rowing),
      "YOGA": const Icon(Icons.self_improvement),
      "DANCE": const Icon(Icons.dangerous),
      "MARTIAL_ARTS": const Icon(Icons.fitness_center),
      "MEDITATION": const Icon(Icons.self_improvement),
      "WHEELCHAIR": const Icon(Icons.accessible_forward),
      "CLIMBING": const Icon(Icons.assistant_outlined),
      "SKIING": const Icon(Icons.ac_unit),
      "SNOWBOARDING": const Icon(Icons.ac_unit),
      "BOXING": const Icon(Icons.sports_mma),
      "KICKBOXING": const Icon(Icons.sports_mma),
      "KARATE": const Icon(Icons.self_improvement),
      "TAI_CHI": const Icon(Icons.self_improvement),
      "PILATES": const Icon(Icons.self_improvement),
      "ZUMBA": const Icon(Icons.dangerous),
      "SPINNING": const Icon(Icons.directions_bike),
      "CIRCUIT_TRAINING": const Icon(Icons.fitness_center),
      "CROSSFIT": const Icon(Icons.fitness_center),
      "HIIT": const Icon(Icons.fitness_center),
      "TRIATHLON": const Icon(Icons.fitness_center),
      "BASKETBALL": const Icon(Icons.sports_basketball),
      "FOOTBALL": const Icon(Icons.sports_football),
      "SOCCER": const Icon(Icons.sports_soccer),
      "VOLLEYBALL": const Icon(Icons.sports_volleyball),
      "TENNIS": const Icon(Icons.sports_tennis),
      "BASEBALL": const Icon(Icons.sports_baseball),
      "ICE_HOCKEY": const Icon(CupertinoIcons.sportscourt),
      "SKATEBOARDING": const Icon(Icons.skateboarding),
      "SURFING": const Icon(Icons.surfing),
      "SNOWSHOEING": const Icon(Icons.ac_unit),
      "CURLING": const Icon(Icons.sports_hockey),
      "WRESTLING": const Icon(Icons.sports_mma),
      "WATER_POLO": const Icon(Icons.pool),
    };
    setState(() {
      isLoading = true;
    });
    var now = DateTime.now();
    // Set the date range for the query
    DateTime startTime = now.subtract(const Duration(hours: 12));
    DateTime endTime = now;
    bool requested = await health.requestAuthorization(types);
    // Fetch health data from the last 30 days
    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
      startTime,
      endTime,
      types,
    );
    // Initialize variables for step count, heart rate, and calories burned
    int totalSteps = 0;
    double heartRate = 0.0;
    double caloriesBurned = 0.0;
    double bmi = 0.0;
    double bfp = 0.0;
    int mindful = 0;
    double sleep = 0.0;
    int exercise = 0;
    WorkoutHealthValue work;

    add_activities!.addAll(HealthWorkoutActivityType.values.toList());
    activity.add({'name': "Steps", 'icon': const Icon(Icons.directions_walk)});
    // Loop through the health data points and retrieve the values
    for (var point in healthData) {
      switch (point.type) {
        case HealthDataType.WORKOUT:
          setState(() {
            work = point.value as WorkoutHealthValue;
            var temp = work.workoutActivityType.toString().split('.');
            var iconName = temp[1];
            var icon =
                activityIcons[iconName] ?? const Icon(Icons.directions_walk);
            if (!activity.any(
                (a) => a['name'] == temp[1].toLowerCase().capitalizeFirst)) {
              activity.add({
                'name': temp[1].toLowerCase().capitalizeFirst,
                'icon': icon
              });
            }
          });
          break;
        case HealthDataType.STEPS:
          totalSteps += int.parse(point.value.toString());
          break;
        case HealthDataType.HEART_RATE:
          heartRate += double.parse(point.value.toString());
          break;
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          caloriesBurned += double.parse(point.value.toString());
          break;
        case HealthDataType.EXERCISE_TIME:
          exercise += int.parse(point.value.toString());
          break;
        default:
          break;
      }
    }
    print(weightController.text);
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
    // Update the state with the step count, heart rate, and calories burned
    setState(() {
      steps = totalSteps.toString();
      bpm = heartRate.toStringAsFixed(0);
      calories = caloriesBurned.toStringAsFixed(0);
      for (int i = 0; i < goals.length; i++) {
        if (goals[i]['name'] == "Steps") {
          goals[i]['value'] = steps;
        } else if (goals[i]['name'] == "Heart Rate") {
          goals[i]['value'] = bpm;
        } else if (goals[i]['name'] == "Calories") {
          goals[i]['value'] = calories;
        } else if (goals[i]['name'] == "Body Mass Index") {
          goals[i]['value'] = bmi;
        } else if (goals[i]['name'] == "Body Fat Percentage") {
          goals[i]['value'] = bfp;
        } else if (goals[i]['name'] == "Mindfulness") {
          goals[i]['value'] = mindful;
        } else if (goals[i]['name'] == "Exercise") {
          goals[i]['value'] = exercise;
        } else if (goals[i]['name'] == "Sleep") {
          goals[i]['value'] = sleep.toStringAsFixed(0);
        }
      }
    });

    setState(() {
      achieved = 0;
      for (int i = 0; i < 7; i++) {
        percent[i] = stepsPerDay[i] / _goal!.steps;
        if (percent[i] >= 1) {
          achieved++;
        }
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Widget _header() {
    return Column(
      children: [
        (!MainConfig.modeLive)
            ? const Padding(
                padding: EdgeInsets.only(top: 40),
              )
            : Container(),
        Row(children: [
          Row(
            children: [
              Column(
                key: const Key("user_info"),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Handle back button press here
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 25,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 3 / 700),
                      Text(
                        "Hello, ".tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color.fromARGB(255, 104, 104, 104),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          _name.length > 20
                              ? _name.substring(0, 20) + '...'
                              : _name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 5 / 220,
                    child: Center(
                      child: Row(
                        children: [
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 3 / 60),
                          Text(
                            "Reward Pts ".tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Color.fromARGB(255, 104, 104, 104),
                            ),
                          ),
                          Text(
                            "+" + _points + " TDC ",
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Color.fromARGB(255, 104, 104, 104),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ]),
      ],
    );
  }

  Widget _healthWidget() {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 5 / 19,
                    height: MediaQuery.of(context).size.height * 5 / 20,
                    child: ListView.builder(
                        itemCount: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: ((context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    goals[index]['icon'],
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        (goals[index]['value'] != 0 &&
                                                goals[index]['value'] != "0" &&
                                                goals[index]['value'] != null)
                                            ? goals[index]['value'].toString()
                                            : "No Data",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize:
                                                (goals[index]['value'] != 0 &&
                                                        goals[index]['value'] !=
                                                            "0")
                                                    ? 26
                                                    : 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.zero,
                                        child: Text(
                                          goals[index]['name'],
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 10,
                                              color: Color.fromARGB(
                                                  255, 214, 214, 214),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color.fromARGB(255, 214, 214, 214),
                              ),
                            ],
                          );
                        }))),
                Padding(
                    padding: const EdgeInsets.only(right: 10.0, top: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _statusWidget,
                      ],
                    )),
              ],
            ),
            const Divider(
              color: Colors.white,
              thickness: 2,
            ),
            SizedBox(
                width: 400,
                height: 119,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Positioned(
                      right: 20,
                      child: SizedBox(
                        height: 120,
                        child: SfCartesianChart(
                          primaryXAxis: NumericAxis(
                            axisLine:
                                const AxisLine(width: 0), // Hide X-axis line
                            majorTickLines: const MajorTickLines(
                                width: 0), // Hide X-axis tick lines
                            labelStyle: const TextStyle(
                                color:
                                    Colors.transparent), // Hide X-axis labels
                          ),
                          primaryYAxis: NumericAxis(
                            axisLine:
                                const AxisLine(width: 0), // Hide Y-axis line
                            majorTickLines: const MajorTickLines(
                                width: 0), // Hide Y-axis tick lines
                            labelStyle: const TextStyle(
                                color:
                                    Colors.transparent), // Hide Y-axis labels
                          ),
                          plotAreaBorderWidth: 0,
                          series: <CartesianSeries>[
                            FastLineSeries<dynamic, dynamic>(
                              color: Colors.white,
                              width: 1,
                              dataSource: <dynamic>[
                                {'x': 1, 'y': 0},
                                {'x': 2, 'y': 0},
                                {'x': 3, 'y': 0},
                                {'x': 4, 'y': 0},
                                {'x': 5, 'y': 0},
                              ],
                              xValueMapper: (dynamic point, _) => point['x'],
                              yValueMapper: (dynamic point, _) => point['y'],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 32,
                      top: 12,
                      child: SizedBox(
                        width: 250,
                        height: 65,
                        child: SfSparkLineChart(
                          color: const Color.fromARGB(255, 100, 233, 104),
                          axisLineWidth: 0,
                          data: const <double>[
                            1,
                            5,
                            -6,
                            0,
                            1,
                            -2,
                            7,
                            -7,
                            -4,
                            -10,
                            13,
                            -6,
                            7,
                            5,
                            11,
                            5,
                            3
                          ],
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  status() {
    double complete = (_goal != null) ? double.parse(steps) / _goal!.steps : 0;
    if (complete <= 1) {
      complete = complete;
    } else {
      complete = 1;
    }
    _statusWidget = GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return const GoalScreen();
        })).then((value) => {_refreshContent()});
      },
      child: CircularPercentIndicator(
        radius: 80,
        lineWidth: 15.0,
        percent: 1,
        progressColor: Colors.white,
        center: CircularPercentIndicator(
            backgroundColor: Colors.white,
            radius: 75.0,
            lineWidth: 5.0,
            percent: complete,
            animation: true,
            animationDuration: 1200,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (_goal != null)
                      ? (complete * 100).toStringAsFixed(0) + "%"
                      : "0 %",
                  style: const TextStyle(
                      fontSize: 38,
                      color: Color.fromARGB(255, 100, 233, 104),
                      fontWeight: FontWeight.w700),
                ),
                const Text(
                  "Complete",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            progressColor: const Color.fromARGB(255, 100, 233, 104)),
      ),
    );
  }

  Widget activity_Customize() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15), // Add padding here
      child: ListTile(
        title: Text('Activities',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color.fromARGB(255, 104, 104, 104),
            )),
      ),
    );
  }

  Widget body_Measure() {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return BioForm();
          }));
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 5 / 5,
          child: Column(
            children: <Widget>[
              SizedBox(
                // new container for body measurement
                width: MediaQuery.of(context).size.width * 5 / 6,
                height: MediaQuery.of(context).size.height * 5 / 60,
                child: const Padding(
                  padding: EdgeInsets.only(left: 1.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Body Measurements',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 104, 104, 104),
                        )),
                  ),
                ),
              ),
              // existing container for weight
              Container(
                width: MediaQuery.of(context).size.width * 5 / 6,
                height: MediaQuery.of(context).size.height * 6 / 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child:( weightController.text != "")? Column(
                  children: <Widget>[
                    // existing weight content
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding:
                                EdgeInsets.only(left: 4, bottom: 8, top: 16),
                            child: Text('Weight',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 104, 104, 104),
                                )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 3),
                                    child: Text(
                                      weightController.text,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 32,
                                        color:
                                            Color.fromARGB(255, 104, 104, 104),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 2, bottom: 8),
                                    child: Text(
                                      'kg',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromARGB(255, 104, 104, 104),
                                        fontSize: 18,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.grey.withOpacity(0.5),
                                        size: 16,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          _currentTime,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            letterSpacing: 0.0,
                                            color: Color.fromARGB(
                                                255, 104, 104, 104),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 8),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 5 / 400,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  heightController.text + ' ' + 'cm',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 104, 104, 104),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    ' Height',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 104, 104, 104),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      bmiController.text + ' ' + 'BMI',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(255, 104, 104, 104),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        'BMI',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                              255, 104, 104, 104),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    // ...
                  ],
                ):Container(
                  child: Center(
                    child: Text('Tap to fill',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 104, 104, 104),
                          )),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget water_Reminder() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 15, 114, 196),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(8.0)),
              ),
              child: const Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 68, bottom: 12, right: 16, top: 12),
                    child: Text(
                      'Prepare your stomach for lunch with one or two glass of water',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color.fromARGB(255, 104, 104, 104),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  showAdd() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Scaffold(
            floatingActionButton: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: CupertinoTheme.of(context).primaryColor,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.close, color: Colors.white, size: 35),
                ),
              ),
            ),
            backgroundColor: Colors.white.withOpacity(0.8),
            body: Container(
              color: Colors.transparent,
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 580.0, right: 15),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        var newactivity = await Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          return ActivityAdd(activities: add_activities!);
                        }));

                        if (newactivity != null) {
                          _refreshContent();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 125,
                            child: Text(
                              'Add Activity',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 104, 104, 104),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.edit,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        var newactivity = await Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          return ActivityTrack(activities: add_activities!);
                        }));
                        if (newactivity != null) {
                          _getHealth();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 125,
                            child: Text(
                              'Track Activity',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 104, 104, 104),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.directions_walk,
                                  color: Colors.white, size: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
