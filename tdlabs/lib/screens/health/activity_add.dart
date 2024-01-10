// ignore_for_file: must_be_immutable, unused_local_variable

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:tdlabs/models/health/activities.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/widgets/search/sliver_search_bar.dart';

class ActivityAdd extends StatefulWidget {
  List<HealthWorkoutActivityType> activities;
  ActivityAdd({Key? key, required this.activities}) : super(key: key);

  @override
  State<ActivityAdd> createState() => _ActivityAddState();
}

class _ActivityAddState extends State<ActivityAdd> {
  int _pickerIndex = 0;
  List<Widget> pickerItems = [];
  List<String> type = [];
  String activityTypeName = "";
  String time = "";
  String date = "";
  DateTime datetime = DateTime.now();
  int min = 0;
  Duration _duration = const Duration(minutes: 15);
  final _energyBurnedController = TextEditingController();
  String search = '';
  List<HealthWorkoutActivityType> activities = [];
  @override
  void initState() {
    super.initState();
    assignType(0);
    _energyBurnedController.text = "";
    time = DateFormat.jm().format(datetime).toString();
    date = DateFormat.MMMEd().format(datetime).toString();
  }

  void assignType(int pickerIndex) {
    activities.clear();
    pickerItems.clear();
    activities.addAll(widget.activities);
    for (int i = 0; i < widget.activities.length; i++) {
      List<String> temp = widget.activities[i].name.toString().split('_');
      type.add(temp[0].toLowerCase().capitalizeFirst!);
      if (temp.length == 2) {
        type.add("${temp[0].toLowerCase().capitalizeFirst!} ${temp[1].toLowerCase().capitalizeFirst!}");
      } else if (temp.length == 3) {
        type.add("${temp[0].toLowerCase().capitalizeFirst!} ${temp[1].toLowerCase().capitalizeFirst!} ${temp[2].toLowerCase().capitalizeFirst!}");
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
    activityTypeName = type[pickerIndex];
  }

  void assignType2(String value, String search) {
    type.clear();
    pickerItems.clear(); // clear previous items before adding new ones
    for (int i = 0; i < activities.length; i++) {
      List<String> temp = activities[i].name.toString().split('_');
      List<String> filteredTemp = temp
          .where((item) => item.toLowerCase().contains(value.toLowerCase()))
          .toList();

      if (filteredTemp.isNotEmpty) {
        // add only if there's at least one filtered item
        type.add(filteredTemp[0].toLowerCase().capitalizeFirst!);

        if (temp.length == 2) {
          type.add("${temp[0].toLowerCase().capitalizeFirst!} ${temp[1].toLowerCase().capitalizeFirst!}");
        } else if (temp.length == 3) {
          type.add("${temp[0].toLowerCase().capitalizeFirst!} ${temp[1].toLowerCase().capitalizeFirst!} ${temp[2].toLowerCase().capitalizeFirst!}");
        }

        var text = Text(
          type[type.length - 1].tr, // use the last added item
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
          ),
        );
        pickerItems.add(text);
      }
      Navigator.pop(context);
      _showPicker(search);
    }
  }

  Future<void> _writeWorkout() async {
    HealthFactory health = HealthFactory();
    List<Map<String, dynamic>> acs = [{}];
    final now = DateTime.now();
    min = _duration.inMinutes;
    setState(() {
      acs = [
        {
          "name": activityTypeName,
          "code": widget.activities[_pickerIndex].toString(),
          "energy_burned": double.parse(_energyBurnedController.text),
          "distance": 0,
          "energy_unit": "HealthDataUnit.KILOCALORIE",
          "distance_unit": "HealthDataUnit.METER",
          "is_hidden": 0
        }
      ];
    });
    var workout = await health.writeWorkoutData(widget.activities[_pickerIndex],
        now.subtract(Duration(minutes: min)), now,
        totalEnergyBurned: int.parse(_energyBurnedController.text));
    var response = await Activity.create(context, acs);
    Navigator.pop(context, workout);
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
              Padding(
                padding: const EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    _showPicker(search);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Activity: ',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                      ),
                      Text(
                        activityTypeName,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          color: Color.fromARGB(255, 104, 104, 104),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () async {
                    await DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        onChanged: (dateTemp) {}, onConfirm: (dateTemp) {
                      setState(() {
                        time = DateFormat.jm().format(dateTemp).toString();
                        date = DateFormat.MMMEd().format(dateTemp).toString();
                      });
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Start: ',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                      ),
                      Text(
                        "$date \n$time",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          color: Color.fromARGB(255, 104, 104, 104),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(15),
                child: GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Duration: ',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                      ),
                      DurationPicker(
                        width: 175,
                        height: 175,
                        duration: _duration,
                        onChange: (val) {
                          setState(() => _duration = val);
                        },
                        snapToMins: 5.0,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(15),
                child: GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Energy Burned: ',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 46,
                        width: 75,
                        child: CupertinoTextField(
                          controller: _energyBurnedController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          placeholder: 'Enter Energy Burned',
                          placeholderStyle: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 100,
                        child: Text(
                          ' kJ',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(
                height: 75,
              ),
              SizedBox(
                width: 200,
                height: 46,
                child: CupertinoButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  disabledColor: CupertinoColors.inactiveGray,
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    setState(() {});
                    if (_energyBurnedController.text != "") {
                      _writeWorkout();
                    } else {
                      Toast.show(
                          context, "danger", "Please enter energy burned");
                    }
                  },
                  child: const Text('Add Activity',
                      style: TextStyle(
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

  _showPicker(String search) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
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
                      type.clear();
                      assignType(_pickerIndex);
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
                  SizedBox(
                      height: 50,
                      width: 175,
                      child: Sliver_SearchBar(
                          value: search,
                          onSubmitted: (value) {
                            assignType2(value, value);
                          })),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        type.clear();
                        assignType(_pickerIndex);
                      });

                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
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
              height: 250,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: _pickerIndex),
                backgroundColor: Colors.white,
                magnification: 1.2,
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
