// ignore_for_file: must_be_immutable, unused_local_variable

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:tdlabs/models/health/activities.dart';

class ActivityTrack extends StatefulWidget {
  List<HealthWorkoutActivityType> activities;
  ActivityTrack({Key? key, required this.activities}) : super(key: key);

  @override
  State<ActivityTrack> createState() => _ActivityTrackState();
}

class _ActivityTrackState extends State<ActivityTrack> {
  int _pickerIndex = 0;
  List<Widget> pickerItems = [];
  List<String> type = [];
  List<HealthWorkoutActivityType> type2 = [];
  String activityTypeName = "";
  String time = "";
  String date = "";
  String _currentTime = "";
  DateTime datetime = DateTime.now();
  int min = 0;
  final _energyBurnedController = TextEditingController();
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool countdown = false;
  int energy = 0;
  @override
  void initState() {
    super.initState();
    assignType();
    _energyBurnedController.text = "500";
    time = DateFormat.jm().format(datetime).toString();
    date = DateFormat.MMMEd().format(datetime).toString();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) _timer!.cancel();
  }

  void assignType() {
    for (int i = 0; i < widget.activities.length; i++) {
      type2.add(widget.activities[i]);
      List<String> temp = widget.activities[i].name.toString().split('_');
      

      if (temp.length == 2) {
        type.add("${temp[0].toLowerCase().capitalizeFirst!} ${temp[1].toLowerCase().capitalizeFirst!}");
      } else if (temp.length == 3) {
        type.add("${temp[0].toLowerCase().capitalizeFirst!} ${temp[1].toLowerCase().capitalizeFirst!} ${temp[2].toLowerCase().capitalizeFirst!}");
      }else{
        type.add(temp[0].toLowerCase().capitalizeFirst!);
      }
      var text = Text(
        type[i].tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      );
      pickerItems.add(text);
    }
    activityTypeName = type[0];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
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
                    ],
                  ),
                ),
              ),
              const Divider(),
              (countdown == true || _currentTime == "" || _currentTime == "0")
                  ? Padding(
                      padding: const EdgeInsets.all(15),
                      child: GestureDetector(
                        onTap: () {
                          _showPicker();
                        },
                        child: Column(
                          children: [
                            const SizedBox(
                              width: 120,
                              child: Text(
                                'Activity Type: ',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 104, 104, 104),
                                ),
                              ),
                            ),
                            Container(
                              width: 175,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      activityTypeName,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(255, 104, 104, 104),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              const SizedBox(
                height: 85,
              ),
              SizedBox(
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _startTimer();
                    });
                  },
                  child: (_currentTime == "" || _currentTime == "0")
                      ? Column(
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              size: 50,
                            ),
                            Text(
                              'Start $activityTypeName',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 22,
                                color: Color.fromARGB(255, 104, 104, 104),
                              ),
                            ),
                          ],
                        )
                      : (countdown == false)
                          ? Column(
                              children: [
                                Text(
                                  activityTypeName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  _currentTime,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 35,
                                    color: Color.fromARGB(255, 104, 104, 104),
                                  ),
                                ),
                                const Divider(),
                                 Text(
                                  energy.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 28,
                                    color:Color.fromARGB(255, 104, 104, 104) ,
                                  ),
                                ),
                                 Text(
                                  "Energy Burned",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                    color: CupertinoTheme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _currentTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 35,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                            ),
                ),
              ),
              const SizedBox(
                height: 85,
              ),
              (countdown == true || _currentTime == "" || _currentTime == "0")
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _stopTimer();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.red,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.stop,
                                  color: Colors.white, size: 35),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_timer!.isActive) {
                              _pauseTimer();
                            } else {
                              _resumeTimer();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                  (_timer!.isActive)
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 35),
                            ),
                          ),
                        ),
                      ],
                    )
            ],
          )),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer!.tick > 3) {
        setState(() {
          countdown = false;
          _elapsedTime += const Duration(seconds: 1);
           if (_timer!.tick == 5) {
            // Increment energy value by a set amount every 10 seconds
            energy += 1;
          }
          if (_elapsedTime.inSeconds % 10 == 0) {
            // Increment energy value by a set amount every 10 seconds
            energy += 1;
          }
        });
        _currentTime = _elapsedTime.toString().split('.')[0];
      } else {
        setState(() {
          countdown = true;
          _currentTime = _timer!.tick.toString();
        });
      }
    });
  }

  void _resumeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime += const Duration(seconds: 1);
        if (_elapsedTime.inSeconds % 10 == 0) {
            // Increment energy value by a set amount every 10 seconds
            energy += 1;
          }
      });
      _currentTime = _elapsedTime.toString().split('.')[0];
    });
  }

  void _pauseTimer() {
    setState(() {
      _timer!.cancel();
    });
  }

  Future<void> _stopTimer() async {
    HealthFactory health = HealthFactory();
    final now = DateTime.now();
    min = _elapsedTime.inMinutes;
   List<Map<String, dynamic>> acs = [{}];
       if(energy != 0){
    setState(() {
      acs = [
        {
          "name": activityTypeName,
          "code": widget.activities[_pickerIndex].toString(),
          "energy_burned": double.parse(energy.toString()),
          "distance": 0,
          "energy_unit": "HealthDataUnit.KILOCALORIE",
          "distance_unit": "HealthDataUnit.METER",
          "is_hidden": 0
        }
      ];
    });

        var workout = await health.writeWorkoutData(
        type2[_pickerIndex], now.subtract(Duration(minutes: min)), now,
        totalEnergyBurned: energy);
         var response = await Activity.create(context, acs);
      if(workout == false || response!.status == false){
      }
    }
    setState(() {
      _currentTime = "";
      _elapsedTime = const Duration(seconds: 0);
      _timer!.cancel();
    });
    Navigator.pop(context);
  }

  _showPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        activityTypeName = type[_pickerIndex];
                      });
                      Navigator.of(context).pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                    child: Text('Confirm'.tr),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: _pickerIndex),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    _pickerIndex = value;
                  });
                },
                itemExtent: 32.0,
                children: pickerItems,
              ),
            ),
          ],
        );
      },
    );
  }

}
