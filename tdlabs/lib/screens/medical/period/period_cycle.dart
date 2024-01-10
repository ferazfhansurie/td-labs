// ignore_for_file: must_be_immutable, library_prefixes, unnecessary_null_comparison

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tdlabs/models/health/period.dart';
import 'package:get/get.dart' as Get;

import 'period_steps.dart';

class CycleAnalysis extends StatefulWidget {
  UserMenstrual? um;
  CycleAnalysis({Key? key, this.um}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _CycleAnalysisState();
  }
}

class _CycleAnalysisState extends State<CycleAnalysis> {
  int last = 0;
  int long = 0;
  final DateTime? dateNow = DateTime.now();
  String text = "";
  int quantity = 0;
  List<int> cycleList = [21, 22, 23, 24, 25, 26, 28, 29, 30, 31];
  List<String> monthList = [
    'January',
    'February',
    'March',
    'April',
    "May",
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  var daystop = "";
  bool onComplete = false;
  int difference = 0;
  int difference2 = 0;
  final EventList<Event> _markedDateMap = EventList<Event>(
    events: {},
  );
  List<dynamic> cycles = [];
  List<dynamic> startDates = [];
  List<dynamic> ovulationDates = [];

  @override
  // void initState() {
  //   DateTime dateNow = DateTime.now(); // Current dat
  //   super.initState();
  //   cycles.addAll(widget.um!.menstrualCycles!);
  //   // Get all start dates from menstrualCycles list
  //   startDates = cycles.map((cycle) => cycle['start_date']).toList();
  //   ovulationDates = cycles.map((cycle) => cycle['start_ovulation']).toList();
  //   DateTime nextStartDate = DateTime.parse(startDates[0]);
  //   DateTime nextOvulationDate = DateTime.parse(ovulationDates[0]);
  //   // Initialize formatter to format date
  //   var formatter = DateFormat("yyyy-MM-dd");
  //   // Sort the startDates list to find the next upcoming start date
  //   startDates.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
  //   ovulationDates
  //       .sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
  //   for (var start in startDates) {
  //     var parsedStart = DateTime.parse(start);
  //     if (parsedStart.isAfter(dateNow)) {
  //       nextStartDate = parsedStart;
  //       String startStr = formatter.format(nextStartDate);
  //       String dateNowStr = formatter.format(dateNow);
  //       difference = formatter
  //           .parse(startStr)
  //           .difference(formatter.parse(dateNowStr))
  //           .inDays;
  //       break;
  //     }
  //   }
  //   for (var ovulation in ovulationDates) {
  //     var parsedStart = DateTime.parse(ovulation);
  //     if (parsedStart.isAfter(dateNow)) {
  //       nextOvulationDate = parsedStart;
  //       String startStr = formatter.format(nextOvulationDate);
  //       String dateNowStr = formatter.format(dateNow);
  //       difference2 = formatter
  //           .parse(startStr)
  //           .difference(formatter.parse(dateNowStr))
  //           .inDays;
  //       break;
  //     }
  //   }
  //   for (int i = 0; i < cycles.length; i++) {
  //     final cycle = cycles[i];
  //     _markedDateMap.add(
  //         DateTime.parse(cycle['start_period']),
  //         Event(
  //           date: DateTime.parse(cycle['start_period']),
  //           title: 'Start Period',
  //           icon: Column(
  //             children: [
  //               const Icon(
  //                 Icons.bloodtype,
  //                 color: Colors.red,
  //               ),
  //               Text(
  //                 "Start".tr,
  //                 style: const TextStyle(fontSize: 8, color: Colors.red),
  //               )
  //             ],
  //           ),
  //         ));
  //     _markedDateMap.add(
  //         DateTime.parse(cycle['end_period']),
  //         Event(
  //           date: DateTime.parse(cycle['end_period']),
  //           title: 'End Period',
  //           icon: Column(
  //             children: [
  //               const Icon(
  //                 Icons.bloodtype,
  //                 color: Colors.red,
  //               ),
  //               Text(
  //                 "End".tr,
  //                 style: const TextStyle(fontSize: 8, color: Colors.red),
  //               )
  //             ],
  //           ),
  //         ));
  //     _markedDateMap.add(
  //         DateTime.parse(cycle['start_ovulation']),
  //         Event(
  //           date: DateTime.parse(cycle['start_ovulation']),
  //           title: 'Start Ovulation',
  //           icon: Column(
  //             children: [
  //               const Icon(
  //                 CupertinoIcons.thermometer,
  //                 color: Colors.blue,
  //               ),
  //               Text(
  //                 "Start".tr,
  //                 style: const TextStyle(fontSize: 8, color: Colors.blue),
  //               )
  //             ],
  //           ),
  //         ));
  //
  //     _markedDateMap.add(
  //         DateTime.parse(cycle['end_ovulation']),
  //         Event(
  //           date: DateTime.parse(cycle['end_ovulation']),
  //           title: 'End Ovulation',
  //           icon: Column(
  //             children: [
  //               const Icon(
  //                 CupertinoIcons.thermometer,
  //                 color: Colors.blue,
  //               ),
  //               Text(
  //                 "End".tr,
  //                 style: const TextStyle(fontSize: 8, color: Colors.blue),
  //               )
  //             ],
  //           ),
  //         ));
  //     _markedDateMap.add(
  //         DateTime.parse(cycle['peak_ovulation']),
  //         Event(
  //           date: DateTime.parse(cycle['peak_ovulation']),
  //           title: 'Peak Ovulation',
  //           icon: Column(
  //             children: [
  //               const Icon(
  //                 CupertinoIcons.thermometer,
  //                 color: Colors.blue,
  //               ),
  //               Text(
  //                 "Peak".tr,
  //                 style: const TextStyle(fontSize: 8, color: Colors.blue),
  //               )
  //             ],
  //           ),
  //         ));
  //     _markedDateMap.add(
  //         DateTime.parse(cycle['test_pregnancy_date']),
  //         Event(
  //           date: DateTime.parse(cycle['test_pregnancy_date']),
  //           title: 'Pregnancy Test',
  //           icon: Column(
  //             children: [
  //               Image.asset(
  //                 'assets/images/pregnant-icon.png',
  //                 color: Colors.pink,
  //                 height: 25,
  //               ),
  //               Text(
  //                 "Test".tr,
  //                 style: const TextStyle(fontSize: 8, color: Colors.pink),
  //               )
  //             ],
  //           ),
  //         ));
  //   }
  // }

  void initState() {
    super.initState();
    DateTime dateNow = DateTime.now(); // Current date

    cycles.addAll(widget.um!.menstrualCycles!);

    // Get all start dates from menstrualCycles list
    startDates = cycles.map((cycle) => cycle['start_date']).toList();
    ovulationDates = cycles.map((cycle) => cycle['start_ovulation']).toList();

    DateTime nextStartDate = DateTime.parse(startDates[0]);
    DateTime nextOvulationDate = DateTime.parse(ovulationDates[0]);
    // Initialize formatter to format date
    var formatter = DateFormat("yyyy-MM-dd");
    // Sort the startDates list to find the next upcoming start date
    startDates.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
    ovulationDates
        .sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
    for (var start in startDates) {
      var parsedStart = DateTime.parse(start);
      if (parsedStart.isAfter(dateNow)) {
        nextStartDate = parsedStart;
        String startStr = formatter.format(nextStartDate);
        String dateNowStr = formatter.format(dateNow);
        difference = formatter
            .parse(startStr)
            .difference(formatter.parse(dateNowStr))
            .inDays;
        break;
      }
    }
    for (var ovulation in ovulationDates) {
      var parsedStart = DateTime.parse(ovulation);
      if (parsedStart.isAfter(dateNow)) {
        nextOvulationDate = parsedStart;
        String startStr = formatter.format(nextOvulationDate);
        String dateNowStr = formatter.format(dateNow);
        difference2 = formatter
            .parse(startStr)
            .difference(formatter.parse(dateNowStr))
            .inDays;

        break;
      }
    }

    for (int i = 0; i < cycles.length; i++) {
      final cycle = cycles[i];

      for (int i = 0; i < 6; i++) {
        _markedDateMap.add(
            DateTime.parse(cycle['start_period']).add(Duration(days: i)),
            Event(
              date: DateTime.parse(cycle['start_period']),
              title: 'Start Period',
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: (i == 0)
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                        )
                      : BorderRadius.circular(0),
                  color: Colors.pink[300],
                ),
                width: 48,
                height: 35,
              ),
            ));
      }

      _markedDateMap.add(
          DateTime.parse(cycle['end_period']),
          Event(
            date: DateTime.parse(cycle['end_period']),
            title: 'End Period',
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                color: Colors.pink[300],
              ),
              width: 48,
              height: 35,
            ),
          ));

      for (int i = 0; i < 4; i++) {
        if (DateTime.parse(cycle['start_ovulation'])
                .add(Duration(days: i))
                .difference(DateTime.parse(cycle['peak_ovulation']))
                .inDays ==
            0) {
          _markedDateMap.add(
              DateTime.parse(cycle['peak_ovulation']),
              Event(
                date: DateTime.parse(cycle['peak_ovulation']),
                title: 'Peak Ovulation',
                icon: const SizedBox(
                  width: 10,
                  height: 80,
                  child: Icon(
                    CupertinoIcons.thermometer,
                    color: Colors.blue,
                  ),
                ),
              ));
        } else {
          _markedDateMap.add(
            DateTime.parse(cycle['start_ovulation']).add(Duration(days: i)),
            Event(
              date: DateTime.parse(cycle['start_ovulation']),
              title: 'Start Ovulation',
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: (i == 0)
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                        )
                      : BorderRadius.circular(0),
                  color: Colors.blue,
                ),
                width: 48,
                height: 35,
              ),
            ),
          );
        }
      }

// Add the end ovulation event after the loop
      _markedDateMap.add(
        DateTime.parse(cycle['end_ovulation']),
        Event(
          date: DateTime.parse(cycle['end_ovulation']),
          title: 'End Ovulation',
          icon: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              color: Colors.blue,
            ),
            width: 48,
            height: 35,
          ),
        ),
      );

      _markedDateMap.add(
          DateTime.parse(cycle['test_pregnancy_date']),
          Event(
            date: DateTime.parse(cycle['test_pregnancy_date']),
            title: 'Pregnancy Test',
            icon: SizedBox(
              width: 0,
              height: 50,
              child: Image.asset(
                'assets/images/pregnant-icon.png',
                color: Colors.pink,
                height: 22,
              ),
            ),
          ));
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return CupertinoPageScaffold(
  //       child: SizedBox(
  //           width: MediaQuery.of(context).size.width,
  //           height: MediaQuery.of(context).size.height,
  //           child: Container(
  //              color: Colors.white,
  //               child: SingleChildScrollView(
  //                 physics: const AlwaysScrollableScrollPhysics(),
  //                 child: Column(
  //                   children: [
  //                     const SizedBox(
  //                       height: 45,
  //                     ),
  //                     Center(
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(15),
  //                         child: Row(
  //                           children: [
  //                             GestureDetector(
  //                               onTap: () {
  //                                 Navigator.pop(context);
  //                               },
  //                               child: const Icon(
  //                                 Icons.arrow_back_ios_new,
  //                                 color: Colors.black,
  //                                 size: 25,
  //                               ),
  //                             ),
  //                             const Spacer(),
  //                             Text(
  //                               "Period Tracker".tr,
  //                               style: const TextStyle(
  //                                 fontFamily: 'Montserrat',
  //                                 color: Colors.black,
  //                                 fontSize: 20,
  //                               ),
  //                             ),
  //                             const Spacer()
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         _cycleDisplay(),
  //                         _cycleDisplay2(),
  //                       ],
  //                     ),
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: _iconDescription(),
  //                         ),
  //                         Expanded(
  //                           child: _iconDescription2(),
  //                         ),
  //                       ],
  //                     ),
  //                     _calendarDisplay(),
  //                     SizedBox(height: MediaQuery.of(context).size.height * 0.008),
  //                     _button(),
  //
  //                   ],
  //                 ),
  //               ))));
  // }
  Future<void> _refreshContent() async {}

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshContent,
      child: Scaffold(
        backgroundColor: const Color(0xffF2F2F4),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 5 / 100),
              _header(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 5 / 16,
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
                            padding: const EdgeInsets.only(top: 16),
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 5 / 18,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      _cycleDisplay(),
                                      _cycleDisplay2(),
                                    ],
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.only(bottom: 10, top: 4),
                                    width: MediaQuery.of(context).size.width *
                                        100 /
                                        120,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _button2(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              _calendarDisplay(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.008),
              Container(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                width: MediaQuery.of(context).size.width * 100 / 120,
                child: Row(
                  children: [
                    Expanded(
                      child: _iconDescription(),
                    ),
                    Expanded(
                      child: _iconDescription2(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _calendarDisplay() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 6),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2.2,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(
                  color: Colors.grey, // Change the color here
                  width: 2.0,
                ),
              ),
              child: CalendarCarousel(
                childAspectRatio: 1.3,
                dayPadding: 0,
                pageScrollPhysics: const NeverScrollableScrollPhysics(),
                nextDaysTextStyle:
                    const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                showIconBehindDayText: true,
                markedDateIconMaxShown: 5,
                weekDayFormat: WeekdayFormat.narrow,
                markedDatesMap: _markedDateMap,
                weekFormat: false,
                headerTextStyle: const TextStyle(
                    color: Color.fromARGB(255, 49, 42, 130), fontSize: 20),
                weekdayTextStyle:
                    const TextStyle(color: Color.fromARGB(255, 49, 42, 130)),
                onDayPressed: (date, events) {},
                weekendTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                prevDaysTextStyle:
                    const TextStyle(color: Color.fromARGB(255, 49, 42, 130)),
                thisMonthDayBorderColor: const Color.fromARGB(255, 49, 42, 130),
                selectedDayTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 52, 169, 176),
                  fontSize: 22,
                ),
                selectedDayButtonColor: Colors.white,
                todayTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 52, 169, 176),
                  fontSize: 20,
                ),
                markedDateIconBuilder: (Event event) {
                  return Container(color: Colors.white, child: event.icon);
                },
                todayButtonColor: Colors.transparent,
                todayBorderColor: const Color.fromARGB(255, 49, 42, 130),
                locale: Get.Get.locale.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            SizedBox(
              height: 30,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
            const Spacer(),
            Text(
              "Period Tracker".tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }

  _cycleDisplay() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: CircularPercentIndicator(
        rotateLinearGradient: true,
        linearGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[
            // Color.fromARGB(255, 231, 59, 59),
            // Color.fromARGB(255, 177, 5, 5),
            Colors.pink, // replace with the built-in pink color
            Colors.pink,
          ], // Gradient from https://learnui.design/tools/gradient-generator.html
          tileMode: TileMode.clamp,
        ),
        radius: 65.0,
        lineWidth: 16.0,
        percent: 1,
        animation: true,
        animationDuration: 1200,
        center: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            height: MediaQuery.of(context).size.height * 1 / 7.8,
            width: MediaQuery.of(context).size.width * 1 / 3.5,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: difference.toString() + ' \n',
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 231, 59, 59),
                          fontSize: 24),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Days to Next Period'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 85, 85, 85),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _cycleDisplay2() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: CircularPercentIndicator(
        rotateLinearGradient: true,
        linearGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[
            // Color.fromARGB(255, 52, 169, 176),
            // Color.fromARGB(255, 49, 42, 130),
            Colors.blue,
            Colors.blue,
          ], // Gradient from https://learnui.design/tools/gradient-generator.html
          tileMode: TileMode.clamp,
        ),
        radius: 65.0,
        lineWidth: 16.0,
        percent: 1,
        animation: true,
        animationDuration: 1200,
        center: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            height: MediaQuery.of(context).size.height * 1 / 7.8,
            width: MediaQuery.of(context).size.width * 1 / 3.5,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: difference2.toString() + "\n",
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 52, 169, 176),
                          fontSize: 24),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Days to Next Ovulation'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 85, 85, 85),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _button2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return PeriodSteps(
                um: widget.um,
              );
            }));
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              "Edit Cycle",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }


  _iconDescription() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(left: 1),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 1 / 30),
                Container(
                  width: MediaQuery.of(context).size.width * 1 / 39,
                  height: MediaQuery.of(context).size.height * 1 / 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink, // set your desired color here
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 1 / 45),
                const Text(
                  'Period',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1 / 12,
                  height: MediaQuery.of(context).size.height * 1 / 30,
                  child: Image.asset(
                    'assets/images/pregnant-icon.png',
                    color: Colors.pink,
                  ),
                ),
                const Text(
                  'Pregnancy Test',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _iconDescription2() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 1 / 39,
                  height: MediaQuery.of(context).size.height * 1 / 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue, // set your desired color here
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 1 / 58),
                const Text(
                  'Ovulation',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1 / 40,
                  height: MediaQuery.of(context).size.height * 1 / 43,
                  child: const Icon(
                    CupertinoIcons.thermometer,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 1 / 50),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: const Text(
                    'Peak Ovulation',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
