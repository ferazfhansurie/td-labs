// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../models/user/user.dart';
import '../../widgets/graph/graph_day.dart';
import '../../widgets/graph/graph_month.dart';

class ActivitySummary extends StatefulWidget {
  String name;
  int? created;
  Icon? image;
  Color? color;
  ActivitySummary({Key? key, required this.name, this.created, this.image,this.color})
      : super(key: key);

  @override
  State<ActivitySummary> createState() => _ActivitySummaryState();
}

class _ActivitySummaryState extends State<ActivitySummary>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _showFirst = true;
  String accessToken = '';
  String _points = '';
  NumberFormat myFormat = NumberFormat("#,##0.00", "en_US");
  String total_steps = "0";
  List<Map<String, dynamic>> activity = [
    {'day': 'Monday', 'steps': '0', 'burn': '0'},
    {'day': 'Tuesday', 'steps': '0', 'burn': '0'},
    {'day': 'Wednesday', 'steps': '0', 'burn': '0'},
    {'day': 'Thursday', 'steps': '0', 'burn': '0'},
    {'day': 'Friday', 'steps': '0', 'burn': '0'},
    {'day': 'Saturday', 'steps': '0', 'burn': '0'},
    {'day': 'Sunday', 'steps': '0', 'burn': '0'},
  ];
  List<Map<String, dynamic>> activity_daily = [
    {
      'time': 'Morning',
      'steps': '0',
      'energy': "0",
      'icon': const Icon(Icons.wb_sunny)
    },
    {
      'time': 'Afternoon',
      'steps': '0',
      'energy': "0",
      'icon': const Icon(Icons.wb_cloudy)
    },
    {
      'time': 'Evening',
      'steps': '0',
      'energy': "0",
      'icon': const Icon(Icons.brightness_3)
    },
    {
      'time': 'Night',
      'steps': '0',
      'energy': "0",
      'icon': const Icon(Icons.nightlight)
    },
  ];
  String morningSteps = '0.0';
  String lunchSteps = '0.0';
  String eveningSteps = '0.0';
  String nightSteps = '0.0';
  String morningWork = '0.0';
  String lunchWork = '0.0';
  String eveningWork = '0.0';
  String nightWork = '0.0';
  List<double> dailyTotalSteps = [0, 0, 0, 0, 0, 0, 0];
  List<double> dailyTotalWork = [0, 0, 0, 0, 0, 0, 0];
  List<String> dayName = [];
  DateTime _selectedDate = DateTime.now();
  bool isLoading = false;
  double total_step_week = 0;
  double total_work_week = 0;
  String total_work = "0";
  List<double> steps = [];
  List<double> energy = [];
  final ScrollController scrollController = ScrollController();
  void _decrementDate() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _getHealthDay();
  }

  void _incrementDate() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _getHealthDay();
  }

  void _decrementWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      dayName.clear();
      dailyTotalSteps = [0, 0, 0, 0, 0, 0, 0];
      dailyTotalWork = [0, 0, 0, 0, 0, 0, 0];
    });
    _getHealthWeek();
  }

  void _incrementWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      dayName.clear();
      dailyTotalSteps = [0, 0, 0, 0, 0, 0, 0];
      dailyTotalWork = [0, 0, 0, 0, 0, 0, 0];
    });
    _getHealthWeek();
  }

  Future<void> _fetchUser() async {
    User? user = await User.fetchOne(context); // get current user
    if (user != null) {
      setState(() {
        var convert2 = double.parse(user.credit!);
        _points = myFormat.format(convert2);
        var arr = _points.split('.');
        _points = arr[0];
      });
    }
  }

  Future<void> _refreshContent() async {
    _fetchUser();
    if (widget.created != null) {
      _selectedDate =
          DateTime.fromMillisecondsSinceEpoch(widget.created! * 1000);
    } /*
    _getHealthDay();
    _getHealthWeek();
*/
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
    if (mounted) {
      _refreshContent();
    }
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _getHealthWeek() async {
    HealthFactory health = HealthFactory();
    if (widget.name == "Steps") {
      var types = [HealthDataType.STEPS];
      setState(() {
        isLoading = true;
      });
      for (int i = 0; i < 7; i++) {
        DateTime startDate = _selectedDate.subtract(Duration(
          days: i,
        ));

        DateTime endDate = _selectedDate.subtract(Duration(
          days: i,
        ));
        DateTime startTime =
            DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        DateTime endTime = DateTime(
            _selectedDate.year, _selectedDate.month, endDate.day, 23, 59, 59);
        List<HealthDataPoint> data = await health.getHealthDataFromTypes(
          startTime,
          endTime,
          types,
        );
        dayName.add(DateFormat('EEEE').format(startDate));
        for (var point in data) {
          switch (point.type) {
            case HealthDataType.STEPS:
              int steps = int.parse(point.value.toString());
              dailyTotalSteps[i] += steps;
              break;
            default:
              break;
          }
        }
      }
      // Update the state with the step count, heart rate, and calories burned
      var list2 = [];
      setState(() {
        total_step_week = 0;
        for (int i = 0; i < 7; i++) {
          total_step_week += dailyTotalSteps[i];
          activity[i]['day'] = dayName[i];
          activity[i]['steps'] = dailyTotalSteps[i].toStringAsFixed(0);
        }
        list2.clear();
        setState(() {
          isLoading = false;
        });
      });
    } else {
      var types = [HealthDataType.WORKOUT];
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < 7; i++) {
        DateTime startDate = _selectedDate.subtract(Duration(
          days: i,
        ));

        DateTime endDate = _selectedDate.subtract(Duration(
          days: i,
        ));
        DateTime startTime =
            DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        DateTime endTime = DateTime(
            _selectedDate.year, _selectedDate.month, endDate.day, 23, 59, 59);
        List<HealthDataPoint> data = await health.getHealthDataFromTypes(
          startTime,
          endTime,
          types,
        );
        WorkoutHealthValue work;

        dayName.add(DateFormat('EEEE').format(startDate));
        for (var point in data) {
          switch (point.type) {
            case HealthDataType.WORKOUT:
              work = point.value as WorkoutHealthValue;
              var temp = work.workoutActivityType.toString().split('.');
              if (widget.name == temp[1].toLowerCase().capitalizeFirst) {
                dailyTotalWork[i] +=
                    int.parse(work.totalEnergyBurned.toString());
              }

              break;
            default:
              break;
          }
        }
      }
      // Update the state with the step count, heart rate, and calories burned
      var list2 = [];
      setState(() {
        total_work_week = 0;
        for (int i = 0; i < 7; i++) {
          total_work_week += dailyTotalWork[i];
          activity[i]['day'] = dayName[i];
          activity[i]['steps'] = dailyTotalWork[i].toStringAsFixed(0);
        }
        list2.clear();
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  _getHealthDay() async {
    HealthFactory health = HealthFactory();
    if (widget.name == "Steps") {
      DateTime morningStartTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 0);
      DateTime morningEndTime = DateTime(_selectedDate.year,
          _selectedDate.month, _selectedDate.day, 9, 59, 59);
      DateTime lunchStartTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 10);
      DateTime lunchEndTime = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 15, 59, 59);
      DateTime eveningStartTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 16);
      DateTime eveningEndTime = DateTime(_selectedDate.year,
          _selectedDate.month, _selectedDate.day, 19, 59, 59);
      DateTime nightStartTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 20);
      DateTime nightEndTime = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 23, 59, 59);
      // Fetch health data from the last 30 days
      List<HealthDataPoint> stepsData = await health.getHealthDataFromTypes(
        morningStartTime,
        nightEndTime,
        [HealthDataType.STEPS],
      );
      List<HealthDataPoint> morningStepsData =
          await health.getHealthDataFromTypes(
        morningStartTime,
        morningEndTime,
        [HealthDataType.STEPS],
      );
      List<HealthDataPoint> lunchStepsData =
          await health.getHealthDataFromTypes(
        lunchStartTime,
        lunchEndTime,
        [HealthDataType.STEPS],
      );
      List<HealthDataPoint> eveningStepsData =
          await health.getHealthDataFromTypes(
        eveningStartTime,
        eveningEndTime,
        [HealthDataType.STEPS],
      );
      List<HealthDataPoint> nightStepsData =
          await health.getHealthDataFromTypes(
        nightStartTime,
        nightEndTime,
        [HealthDataType.STEPS],
      );

      // Initialize variables for step count in each time period
      int morningTotalSteps = 0;
      int lunchTotalSteps = 0;
      int eveningTotalSteps = 0;
      int nightTotalSteps = 0;

      // Initialize variables for step count, heart rate, and calories burned
      int totalSteps = 0;
      // Loop through the health data points and retrieve the values
      for (var point in stepsData) {
        switch (point.type) {
          case HealthDataType.STEPS:
            totalSteps += int.parse(point.value.toString());
            break;
          default:
            break;
        }
      }
      for (var point in morningStepsData) {
        switch (point.type) {
          case HealthDataType.STEPS:
            morningTotalSteps += int.parse(point.value.toString());
            break;
          default:
            break;
        }
      }
      for (var point in lunchStepsData) {
        switch (point.type) {
          case HealthDataType.STEPS:
            lunchTotalSteps += int.parse(point.value.toString());
            break;
          default:
            break;
        }
      }
      for (var point in eveningStepsData) {
        switch (point.type) {
          case HealthDataType.STEPS:
            eveningTotalSteps += int.parse(point.value.toString());
            break;
          default:
            break;
        }
      }
      for (var point in nightStepsData) {
        switch (point.type) {
          case HealthDataType.STEPS:
            nightTotalSteps += int.parse(point.value.toString());
            break;
          default:
            break;
        }
      }

      // Update the state with the step count, heart rate, and calories burned
      var list = [];
      setState(() {
        total_steps = totalSteps.toString();
        morningSteps = morningTotalSteps.toString();
        list.add(morningSteps);
        lunchSteps = lunchTotalSteps.toString();
        list.add(lunchSteps);
        eveningSteps = eveningTotalSteps.toString();
        list.add(eveningSteps);
        nightSteps = nightTotalSteps.toString();
        list.add(nightSteps);
        steps.clear();
        for (int i = 0; i < 4; i++) {
          steps.add(double.parse(list[i]));
          activity_daily[i]['steps'] = list[i];
        }
        list.clear();
      });
    } else {
      DateTime morningStartTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 0);
      DateTime morningEndTime = DateTime(_selectedDate.year,
          _selectedDate.month, _selectedDate.day, 9, 59, 59);
      DateTime lunchStartTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 10);
      DateTime lunchEndTime = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 15, 59, 59);
      DateTime eveningStartTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 16);
      DateTime eveningEndTime = DateTime(_selectedDate.year,
          _selectedDate.month, _selectedDate.day, 19, 59, 59);
      DateTime nightStartTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 20);
      DateTime nightEndTime = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 23, 59, 59);
      // Fetch health data from the last 30 days
      List<HealthDataPoint> workoutData = await health.getHealthDataFromTypes(
        morningStartTime,
        nightEndTime,
        [HealthDataType.WORKOUT],
      );
      List<HealthDataPoint> morningWorkoutData =
          await health.getHealthDataFromTypes(
        morningStartTime,
        morningEndTime,
        [HealthDataType.WORKOUT],
      );

      List<HealthDataPoint> lunchWorkoutData =
          await health.getHealthDataFromTypes(
        lunchStartTime,
        lunchEndTime,
        [HealthDataType.WORKOUT],
      );
      List<HealthDataPoint> eveningWorkoutData =
          await health.getHealthDataFromTypes(
        eveningStartTime,
        eveningEndTime,
        [HealthDataType.WORKOUT],
      );
      List<HealthDataPoint> nightWorkoutData =
          await health.getHealthDataFromTypes(
        nightStartTime,
        nightEndTime,
        [HealthDataType.WORKOUT],
      );

      // Initialize variables for step count in each time period
      int morningTotalWork = 0;
      int lunchTotalWork = 0;
      int eveningTotalWork = 0;
      int nightTotalWork = 0;

      // Initialize variables for step count, heart rate, and calories burned
      int totalWork = 0;
      WorkoutHealthValue work;
      // Loop through the health data points and retrieve the values
      for (var point in workoutData) {
        switch (point.type) {
          case HealthDataType.WORKOUT:
            work = point.value as WorkoutHealthValue;
            var temp = work.workoutActivityType.toString().split('.');
            if (widget.name == temp[1].toLowerCase().capitalizeFirst) {
              totalWork += int.parse(work.totalEnergyBurned.toString());
            }
            break;
          default:
            break;
        }
      }
      for (var point in morningWorkoutData) {
        switch (point.type) {
          case HealthDataType.WORKOUT:
            work = point.value as WorkoutHealthValue;

            var temp = work.workoutActivityType.toString().split('.');
            if (widget.name == temp[1].toLowerCase().capitalizeFirst) {
              morningTotalWork += int.parse(work.totalEnergyBurned.toString());
            }
            break;
          default:
            break;
        }
      }
      for (var point in lunchWorkoutData) {
        switch (point.type) {
          case HealthDataType.WORKOUT:
            work = point.value as WorkoutHealthValue;
            var temp = work.workoutActivityType.toString().split('.');
            if (widget.name == temp[1].toLowerCase().capitalizeFirst) {
              lunchTotalWork += int.parse(work.totalEnergyBurned.toString());
            }
            break;
          default:
            break;
        }
      }
      for (var point in eveningWorkoutData) {
        switch (point.type) {
          case HealthDataType.WORKOUT:
            work = point.value as WorkoutHealthValue;

            var temp = work.workoutActivityType.toString().split('.');
            if (widget.name == temp[1].toLowerCase().capitalizeFirst) {
              eveningTotalWork += int.parse(work.totalEnergyBurned.toString());
            }
            break;
          default:
            break;
        }
      }
      for (var point in nightWorkoutData) {
        switch (point.type) {
          case HealthDataType.WORKOUT:
            work = point.value as WorkoutHealthValue;
            var temp = work.workoutActivityType.toString().split('.');
            if (widget.name == temp[1].toLowerCase().capitalizeFirst) {
              nightTotalWork += int.parse(work.totalEnergyBurned.toString());
            }
            break;
          default:
            break;
        }
      }

      // Update the state with the step count, heart rate, and calories burned
      var list = [];
      setState(() {
        total_work = totalWork.toString();
        morningWork = morningTotalWork.toString();
        list.add(morningWork);
        lunchWork = lunchTotalWork.toString();
        list.add(lunchWork);
        eveningWork = eveningTotalWork.toString();
        list.add(eveningWork);
        nightWork = nightTotalWork.toString();
        list.add(nightWork);
        energy.clear();
        for (int i = 0; i < 4; i++) {
          activity_daily[i]['energy'] = list[i];
          energy.add(double.parse(list[i]));
        }
        list.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 242, 244),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
           
          ),
          height: MediaQuery.of(context).size.height + 30,
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  decoration:  BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(45.0),
                      bottomRight: Radius.circular(45.0),
                    ),
                    color: widget.color,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _decrementDate,
                            icon: const Icon(
                              Icons.chevron_left,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 120,
                            height: 130,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                    height: 90,
                                    child: Column(
                                      children: [
                                        Icon(
                                          widget.image!.icon,
                                          size: 65,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          widget.name.tr,
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _incrementDate,
                            icon: const Icon(
                              Icons.chevron_right,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 5),
                        child: Container(
                          decoration:  BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(45.0),
                              bottomRight: Radius.circular(45.0),
                            ),
                             color: widget.color,
                          ),
                          child: Column(
                            children: [
                              CalendarCarousel(
                                selectedDayButtonColor:widget.color!,
                                selectedDayBorderColor: Colors.black,
                                selectedDateTime: DateTime.now(),
                                showHeader: false,
                                daysTextStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                weekdayTextStyle:
                                    const TextStyle(color: Colors.white),
                                onDayPressed: (date, events) {},
                                weekendTextStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                thisMonthDayBorderColor:
                                    const Color.fromARGB(255, 49, 42, 130),
                                weekFormat: true,
                                height: 80.0,
                                showIconBehindDayText: false,
                                customGridViewPhysics:
                                    const NeverScrollableScrollPhysics(),
                                markedDateShowIcon: true,
                                todayButtonColor: Colors.transparent,
                                todayBorderColor:
                                    const Color.fromARGB(255, 49, 42, 130),
                                markedDateMoreShowTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),
              Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  alignment: Alignment.bottomLeft,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Performance',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      Row(
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.blue),
                          ),
                          Icon(
                            (Icons.arrow_right_alt),
                            color: Colors.black,
                            size: 30,
                          )
                        ],
                      ),
                    ],
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.height * 35 / 100,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: 4,
                  itemBuilder: ((context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'W${index + 1}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w300),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 70 / 100,
                            height: 65,
                            child: StepBarMonthlyChart(
                              index: index,
                              data: const [5, 0, 3, 10, 23, 1, 0],
                              day: const [
                                'Monday',
                                'Tuesday',
                                'Wednesday',
                                'Thursday',
                                'Firday',
                                'Saturday',
                                'Sunday',
                              ],
                            ),
                          ),
                          const Text(
                            '10%',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w300),
                          ),
                          const Icon((Icons.arrow_drop_up),
                              color: Color.fromARGB(255, 83, 212, 169))
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 33 / 100,
                    child: Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 55,
                          lineWidth: 2.0,
                          percent: 0.6,
                          progressColor:
                              const Color.fromARGB(255, 255, 145, 111),
                          center: CircularPercentIndicator(
                              radius: 45.0,
                              lineWidth: 2.0,
                              percent: 0.9,
                              animation: true,
                              animationDuration: 1200,
                              center: CircularPercentIndicator(
                                  radius: 35.0,
                                  lineWidth: 2.0,
                                  percent: 0.5,
                                  animation: true,
                                  animationDuration: 1200,
                                  center: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "60%",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  progressColor:
                                      const Color.fromARGB(255, 223, 123, 92)),
                              progressColor:
                                  const Color.fromARGB(255, 223, 123, 92)),
                        ),
                        const Text(
                          'Target',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 33 / 100,
                    child: Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 55,
                          lineWidth: 2.0,
                          percent: 0.55,
                          progressColor:
                              const Color.fromARGB(255, 83, 212, 169),
                          center: CircularPercentIndicator(
                              radius: 45.0,
                              lineWidth: 2.0,
                              percent: 0.9,
                              animation: true,
                              animationDuration: 1200,
                              center: CircularPercentIndicator(
                                  radius: 35.0,
                                  lineWidth: 2.0,
                                  percent: 0.5,
                                  animation: true,
                                  animationDuration: 1200,
                                  center: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "55%",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  progressColor:
                                      const Color.fromARGB(255, 83, 212, 169)),
                              progressColor:
                                  const Color.fromARGB(255, 83, 212, 169)),
                        ),
                        const Text(
                          'Distance',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 33 / 100,
                    child: Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 55,
                          lineWidth: 2.0,
                          percent: 0.8,
                          progressColor:
                              const Color.fromARGB(255, 216, 57, 183),
                          center: CircularPercentIndicator(
                              radius: 45.0,
                              lineWidth: 2.0,
                              percent: 0.9,
                              animation: true,
                              animationDuration: 1200,
                              center: CircularPercentIndicator(
                                  radius: 35.0,
                                  lineWidth: 2.0,
                                  percent: 0.5,
                                  animation: true,
                                  animationDuration: 1200,
                                  center: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "80%",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  progressColor:
                                      const Color.fromARGB(255, 216, 57, 183)),
                              progressColor:
                                  const Color.fromARGB(255, 216, 57, 183)),
                        ),
                        const Text(
                          'Speed',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget myWidgetWeek() {
    final String formattedDate = DateFormat.yMMMMd().format(_selectedDate);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _decrementWeek,
              icon: const Icon(Icons.arrow_left, size: 60),
            ),
            Container(
              padding: const EdgeInsets.only(left: 22, top: 20),
              height: MediaQuery.of(context).size.height * 5 / 77,
              child: Center(
                child: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),
            ),
            IconButton(
              onPressed: _incrementWeek,
              icon: const Icon(Icons.arrow_right, size: 60),
            ),
          ],
        ),
        const Divider(),
        if (dayName.length == 7 && widget.name == "Steps" && energy.isNotEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width * 34 / 40,
            height: MediaQuery.of(context).size.height * 12 / 50,
            child: StepBarMonthlyChart(
              data: dailyTotalSteps,
              day: dayName,
            ),
          ),
        if (dayName.length == 7 && widget.name != "Steps" && energy.isNotEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width * 34 / 40,
            height: MediaQuery.of(context).size.height * 12 / 50,
            child: StepBarMonthlyChart(
              data: dailyTotalWork,
              day: dayName,
            ),
          ),
        if (isLoading == false) const Divider(),
        if (isLoading == false)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
            alignment: Alignment.center,
            child: Row(
              children: [
                if (widget.name == "Steps")
                  const Icon(
                    Icons.directions_walk,
                    size: 40,
                  ),
                if (widget.name != "Steps")
                  const Icon(
                    Icons.local_fire_department,
                    size: 40,
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                          fontSize: 18.0,
                          color: CupertinoTheme.of(context).primaryColor),
                    ),
                    if (widget.name == "Steps")
                      Text(
                        total_step_week.toStringAsFixed(0) + " steps",
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    if (widget.name != "Steps")
                      Text(
                        total_work_week.toStringAsFixed(0) + " energy burned",
                        style: const TextStyle(fontSize: 16.0),
                      ),
                  ],
                ),
              ],
            ),
          ),
        if (_showFirst && widget.name == "Steps")
          Container(
            width: MediaQuery.of(context).size.width * 5 / 5.7,
            padding: const EdgeInsets.only(top: 10.0, left: 10),
            child: const Text(
              'Steps are a useful measure of how much you\'re moving around, and can help you'
              'spot changes in your activity levels',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          ),
        if (_showFirst) const Divider(),
        if (isLoading == true)
          Container(
            padding: const EdgeInsets.only(top: 20),
            child: const Column(
              children: [
                Text(
                  'Fetching Data...',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
                CircularProgressIndicator(),
              ],
            ),
          ),
        if (isLoading == false)
          Expanded(
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              thickness: 15,
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: activity.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      activity[index]['day'],
                      style: TextStyle(
                          fontSize: 16.0,
                          color: CupertinoTheme.of(context).primaryColor),
                    ),
                    subtitle:
                        Text(activity[index]['steps'].toString() + " steps"),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget myWidgetDay() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
        const Divider(),
        if (widget.name == "Steps" && steps.isNotEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width * 34 / 40,
            height: MediaQuery.of(context).size.height * 12 / 50,
            child: StepBarDayChart(
              data: steps,
            ),
          ),
        if (widget.name != "Steps" && energy.isNotEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width * 34 / 40,
            height: MediaQuery.of(context).size.height * 12 / 50,
            child: StepBarDayChart(
              data: energy,
            ),
          ),
        const Divider(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
          alignment: Alignment.center,
          child: Row(
            children: [
              if (widget.name == "Steps")
                const Icon(
                  Icons.directions_walk,
                  size: 40,
                ),
              if (widget.name != "Steps")
                const Icon(
                  Icons.local_fire_department,
                  size: 40,
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                        fontSize: 18.0,
                        color: CupertinoTheme.of(context).primaryColor),
                  ),
                  if (widget.name == "Steps")
                    Text(
                      total_steps + " steps",
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  if (widget.name != "Steps")
                    Text(
                      total_work + " kJ",
                      style: const TextStyle(fontSize: 16.0),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (_showFirst && widget.name == "Steps")
          Container(
            width: MediaQuery.of(context).size.width * 5 / 5.7,
            padding: const EdgeInsets.only(top: 10.0, left: 10),
            child: const Text(
              'Steps are a useful measure of how much you\'re moving around, and can help you '
              'spot changes in your activity levels',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400),
            ),
          ),
        if (_showFirst) const Divider(),
        Container(
          height: MediaQuery.of(context).size.height * 6 / 20,
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 25,
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: activity_daily.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 5 / 250),
                        activity_daily[index]['icon'],
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 5 / 170),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity_daily[index]['time'],
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color:
                                      CupertinoTheme.of(context).primaryColor),
                            ),
                            if (widget.name == "Steps")
                              Text(
                                activity_daily[index]['steps'] + " steps",
                                style: const TextStyle(fontSize: 14.0),
                              ),
                            if (widget.name != "Steps")
                              Text(
                                activity_daily[index]['energy'] + " kJ",
                                style: const TextStyle(fontSize: 14.0),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(),
      ],
    );
  }
}
