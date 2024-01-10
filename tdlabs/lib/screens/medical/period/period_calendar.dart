import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:tdlabs/models/health/period.dart';

// ignore: must_be_immutable
class PeriodCalendar extends StatefulWidget {
  UserMenstrual? um;
  PeriodCalendar({Key? key, this.um}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _PeriodCalendarState();
  }
}

class _PeriodCalendarState extends State<PeriodCalendar> {
  int last = 0;
  int long = 20;
  final DateTime? _selectedDate = DateTime.now();
  String date = "";
  String text = "";
  int quantity = 21;
  List<int> cycleList = [21, 22, 23, 24, 25, 26, 28, 29, 30, 31];
  final EventList<Event> _markedDateMap = EventList<Event>(
    events: {},
  );
  @override
  void initState() {
    super.initState();
    date = _selectedDate!.toLocal().toString().substring(0, 10);
    _markedDateMap.add(
        DateTime.parse(widget.um!.start_date!),
        Event(
          date: DateTime.parse(widget.um!.start_date!),
          title: 'Start Period',
          icon: const Icon(Icons.start),
        ));

    _markedDateMap.add(
        DateTime.parse(widget.um!.end_date!),
        Event(
          date: DateTime.parse(widget.um!.end_date!),
          title: 'End Period',
          icon: const Icon(Icons.start),
        ));
    _markedDateMap.add(
        DateTime.parse(widget.um!.start_ovulation!),
        Event(
          date: DateTime.parse(widget.um!.start_ovulation!),
          title: 'Start Ovulation',
          icon: const Icon(Icons.start),
        ));

    _markedDateMap.add(
        DateTime.parse(widget.um!.end_ovulation!),
        Event(
          date: DateTime.parse(widget.um!.end_ovulation!),
          title: 'End Ovulation',
          icon: const Icon(Icons.start),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/Background-01.png"),
                        fit: BoxFit.fill),
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 45,
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
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  "Calendar",
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                const Spacer()
                              ],
                            ),
                          ),
                        ),
                        _calendarDisplay(),
                      ],
                    ),
                  )))),
    );
  }

  _calendarDisplay() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      height: 385,
      child: Card(
        child: Column(
          children: [
            CalendarCarousel(
              markedDatesMap: _markedDateMap,
              markedDateCustomTextStyle: const TextStyle(
                fontSize: 25,
                color: Colors.blue,
              ),
              headerTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 49, 42, 130), fontSize: 22),
              weekdayTextStyle:
                  const TextStyle(color: Color.fromARGB(255, 49, 42, 130)),
              onDayPressed: (date, events) {},
              weekendTextStyle: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              thisMonthDayBorderColor: const Color.fromARGB(255, 49, 42, 130),
              weekFormat: false,
              height: 350.0,
              showIconBehindDayText: false,
              customGridViewPhysics: const NeverScrollableScrollPhysics(),
              markedDateShowIcon: true,
              selectedDayTextStyle: const TextStyle(
                color: Colors.yellow,
              ),
              todayTextStyle: const TextStyle(
                color: Color.fromARGB(255, 52, 169, 176),
                fontSize: 20,
              ),
              markedDateIconBuilder: (event) {
                return Container(
                    color: Colors.white,
                    child: Icon(
                      Icons.bloodtype,
                      color: Colors.red.shade500,
                      size: 35,
                    ));
                    
              },
              todayButtonColor: Colors.transparent,
              todayBorderColor: const Color.fromARGB(255, 49, 42, 130),
              markedDateMoreShowTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

//defining cycle api

class Cycle {
  DateTime? start;
  DateTime? end;
  int? duration;
  DateTime? periodStart;
  DateTime? periodEnd;
  DateTime? fertilityStart;
  DateTime? fertilityEnd;
  Cycle(
      {this.start,
      this.end,
      this.duration,
      this.periodStart,
      this.periodEnd,
      this.fertilityStart,
      this.fertilityEnd});
}
