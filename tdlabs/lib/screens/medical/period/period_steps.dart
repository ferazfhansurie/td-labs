// ignore_for_file: must_be_immutable, library_prefixes

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/health/cycle.dart';
import 'package:tdlabs/models/health/period.dart';
import 'package:tdlabs/screens/medical/period/period_cycle.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/spinbox/spin_box2.dart';
import 'package:get/get.dart' as Get;
class PeriodSteps extends StatefulWidget {
  UserMenstrual? um;
  PeriodSteps({Key? key, this.um}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _PeriodStepsState();
  }
}

class _PeriodStepsState extends State<PeriodSteps> {
  int last = 0;
  int long = 20;
  String dates = "";
  String quantity = "14";
  final int _last = 7;
  List<Cycle> cycleList = [];
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
  int _pickerIndex = 0;
  int _currentStep = 0;
  bool onComplete = false;
  @override
  void initState() {
    super.initState();
    _fetchCycle();
  }

  Future<void> _fetchUM() async {
    var um = await UserMenstrual.fetch(context);
    // Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return CycleAnalysis(
        um: um,
      );
    }));
  }

  void complete(BuildContext context) {
    Navigator.pop(context);
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 6 ? setState(() => _currentStep += 1) : null;
    _currentStep >= 5 ? onComplete = true : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 35,
                            )),
                      ),
                      Material(
                        child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                            height: MediaQuery.of(context).size.height,
                            width: 400,
                          ),
                          child: Theme(
                            data: ThemeData(
                                primarySwatch: Colors.orange,
                                colorScheme: const ColorScheme.light(
                                    primary: Color.fromARGB(255, 49, 42, 130))),
                            child: Container(
                              padding: const EdgeInsets.only(top: 5),
                              child: Stepper(
                                type: StepperType.horizontal,
                                physics: const ClampingScrollPhysics(),
                                currentStep: _currentStep,
                                onStepTapped: (step) => tapped(step),
                                onStepContinue: continued,
                                onStepCancel: cancel,
                                controlsBuilder: (BuildContext context,
                                    ControlsDetails details) {
                                  return (onComplete)
                                      ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50.0),
                                    child: SizedBox(
                                      height: 50,
                                      child: CupertinoButton(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                          color:
                                          CupertinoTheme.of(context)
                                              .primaryColor,
                                          disabledColor:
                                          CupertinoColors.black,
                                          onPressed: () {
                                            complete(context);
                                          },
                                          child: const Text(
                                            'Proceed',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight:
                                                FontWeight.w300,
                                                fontSize: 15),
                                          )),
                                    ),
                                  )
                                      : Container(
                                    padding: const EdgeInsets.all(8.0),
                                  );
                                },
                                steps: <Step>[
                                  Step(
                                    title: const Text(
                                      '',
                                    ),
                                    content: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 450,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          child: Column(
                                            children: [
                                              Text(
                                                'When did your last period start?'.tr,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 169, 176),
                                                    fontSize: 20),
                                              ),
                                              CalendarCarousel(
                                                onDayPressed: (date, events) {
                                                  setState(() {
                                                    _currentStep = 1;
                                                    dates = date.day
                                                        .toString() +
                                                        "/" +
                                                        date.month.toString() +
                                                        "/" +
                                                        date.year.toString();
                                                  });
                                                },
                                                prevDaysTextStyle:
                                                const TextStyle(
                                                    fontFamily:
                                                    'Montserrat',
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 169, 176),
                                                    fontSize: 20),
                                                daysTextStyle: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 169, 176),
                                                    fontSize: 20),
                                                headerTextStyle:
                                                const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 49, 42, 130),
                                                    fontSize: 20),
                                                weekdayTextStyle:
                                                const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 49, 42, 130)),
                                                todayButtonColor: Colors.white,
                                                todayTextStyle: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 169, 176),
                                                    fontSize: 20),
                                                weekendTextStyle:
                                                const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 52, 169, 176),
                                                  fontSize: 20,
                                                ),
                                                thisMonthDayBorderColor:
                                                const Color.fromARGB(
                                                    255, 49, 42, 130),
                                                selectedDayButtonColor:
                                                const Color.fromARGB(
                                                    255, 49, 42, 130),
                                                selectedDayTextStyle:
                                                const TextStyle(
                                                    fontSize: 20),
                                                weekFormat: false,
                                                height: 398.0,
                                                showIconBehindDayText: true,
                                                customGridViewPhysics:
                                                const NeverScrollableScrollPhysics(),
                                                maxSelectedDate: DateTime.now(),
                                                markedDateShowIcon: true,
                                                markedDateIconMaxShown: 2,
                                                markedDateIconBuilder: (event) {
                                                  return const Icon(
                                                      Icons.help_outline);
                                                },
                                                markedDateMoreShowTotal: true,
                                                locale: Get.Get.locale.toString(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    isActive: _currentStep >= 0,
                                    state: _currentStep >= 0
                                        ? StepState.complete
                                        : StepState.indexed,
                                  ),
                                  Step(
                                    title: const Text(
                                      '',
                                    ),
                                    content: Column(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () async {
                                            _showCyclePicker();
                                          },
                                          child: Container(
                                            height: 450,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 2),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'How long is your menstrual cycle?'.tr,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 52, 169, 176),
                                                      fontSize: 20),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(15),
                                                  child: Container(

                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          40),
                                                      color:CupertinoTheme.of(context).primaryColor,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          Text(
                                                            quantity.toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                'Montserrat',
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20),
                                                          ),
                                                          const Icon(Icons
                                                              .arrow_drop_down,color: Colors.white,)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    isActive: _currentStep == 1,
                                    state: _currentStep >= 1
                                        ? StepState.complete
                                        : StepState.indexed,
                                  ),
                                  Step(
                                    title: const Text(
                                      '',
                                    ),
                                    content: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 450,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 2),
                                          child: Column(
                                            children: [
                                              Text(
                                                'How many days did your period last?'.tr,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 169, 176),
                                                    fontSize: 20),
                                              ),
                                              Padding(
                                                  padding:
                                                  const EdgeInsets.all(15),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        color: CupertinoColors
                                                            .systemBackground,
                                                        border: Border.all(
                                                            color: CupertinoColors
                                                                .systemGrey5),
                                                      ),
                                                      width: 150,
                                                      child: SpinBox2(
                                                        max: 10,
                                                        min: 1,
                                                        value: _last,
                                                      ))),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 80.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _submitForm(context);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:BorderRadius.circular(40),
                                                      color:CupertinoTheme.of(context).primaryColor,
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(
                                                        "Start Tracking".tr,
                                                        textAlign:TextAlign.center,
                                                        style: const TextStyle(
                                                            fontFamily:'Montserrat',
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    isActive: _currentStep >= 2,
                                    state: _currentStep >= 2
                                        ? StepState.complete
                                        : StepState.indexed,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))));
  }

  Future<List<Cycle>?> _fetchCycle() async {
    final webService = WebService(context);
    webService.setEndpoint('option/list/menstrual-cycle');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Cycle> states =parseList.map<Cycle>((json) => Cycle.fromJson(json)).toList();
      setState(() {
        cycleList.addAll(states);
      });
    }

    return cycleList;
  }

  _showCyclePicker() {
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
                    child:  Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(""); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    child:  Text('Confirm'.tr),
                    onPressed: () {
                      setState(() {});
                      _currentStep++;
                      quantity = cycleList[_pickerIndex].name;
                      Navigator.of(context).pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:FixedExtentScrollController(initialItem: _pickerIndex),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _pickerIndex = value;
                    });
                  }
                },
                itemExtent: 32.0,
                children: [
                  for (var cycle in cycleList)
                    Text(
                      cycle.name,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 104, 104, 104),
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    UserMenstrual um = UserMenstrual();
    Response? response;
    final GlobalKey progressDialogKey = GlobalKey<State>();
    if (mounted) {
      setState(() {
        um.cycle = int.parse(quantity);
        um.menstruation_days = _last;
        um.start_date = dates;
      });
    }
    if (widget.um == null) {
      ProgressDialog.show(context, progressDialogKey);
      response = await UserMenstrual.create(context, um);
      ProgressDialog.hide(progressDialogKey);
      if (response!.status) {
        await _fetchUM();
        Toast.show(context, 'default', 'Record created.');
      }
    } else {
      ProgressDialog.show(context, progressDialogKey);
      response = await UserMenstrual.update(context, um);
      ProgressDialog.hide(progressDialogKey);
      if (response!.status) {
        var array = jsonDecode(response.body.toString());

        if (array != null) {
          await _fetchUM();
          Toast.show(context, 'default', 'Record updated.');
        }
      }
    }
  }
}

//defining cycle api


