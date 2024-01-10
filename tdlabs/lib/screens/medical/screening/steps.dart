// ignore_for_file: prefer_const_constructors_in_immutables, unnecessary_statements

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'test_select_screen.dart';

class Steps extends StatefulWidget {
  Steps({Key? key,}) : super(key: key);
  @override
  _StepsState createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  ControlsDetails? details2;
  int _currentStep = 0;
  StepperType stepperType = StepperType.horizontal;
  bool onComplete = false;
  int swipe = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-01.png"),
              fit: BoxFit.fill),
        ),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top,
        ),
        child: Column(children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 10 / 100,
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "SIMKA".tr,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                      onTap: () {
                        complete(context);
                      },
                      child: Text("Skip".tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              color: Colors.blue))),
                ],
              ),
            ),
          ),
          _simkaSteps(),
        ]),
      ),
    ));
  }

  _simkaSteps() {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        height: MediaQuery.of(context).size.height * 80 / 100,
        width: 400,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(),
        child: Container(
          padding: const EdgeInsets.only(top: 5),
          child: Stepper(
            type: stepperType,
            physics: const ClampingScrollPhysics(),
            currentStep: _currentStep,
            onStepTapped: (step) => tapped(step),
            onStepContinue: continued,
            onStepCancel: cancel,
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return (onComplete)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: SizedBox(
                        height: 50,
                        child: CupertinoButton(
                            borderRadius: BorderRadius.circular(15),
                            color: CupertinoTheme.of(context).primaryColor,
                            disabledColor: CupertinoColors.inactiveGray,
                            onPressed: () {
                              complete(context);
                            },
                            child: Text(
                              'Proceed'.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
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
                content: GestureDetector(
                  onHorizontalDragEnd: (DragEndDetails details2,) =>_onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Step 1'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        "Scan Qr Code\nEnsure that QR Code is in designated area".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Image.asset(
                          'assets/images/step-01.png',
                          height: MediaQuery.of(context).size.height * 40 / 100,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Swipe to continue'.tr+' ->',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Color.fromARGB(255, 104, 104, 104),
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 0,
                state:_currentStep >= 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(''),
                content: GestureDetector(
                   onHorizontalDragEnd: (DragEndDetails details2,) =>_onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Step 2'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      Text(
                        "Record RTK Antigen Self-Test Process".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Image.asset(
                        'assets/images/step-02.png',
                        height: MediaQuery.of(context).size.height * 30 / 100,
                      ),
                      Text(
                        "Ensure that you and your device are 1 Meter Apart before recording" .tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 104, 104, 104),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Ensure that you and the test kit are clearly visible and follow instructions for self-test kit process".tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 104, 104, 104),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 1,
                state:_currentStep >= 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(
                  '',
                ),
                content: GestureDetector(
                   onHorizontalDragEnd: (DragEndDetails details2,) =>_onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Step 3'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Wait for 15 minutes for the results to show".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Image.asset(
                        'assets/images/step-03.png',
                        height: MediaQuery.of(context).size.height * 50 / 100,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 2,
                state: _currentStep >= 2 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(
                  '',
                ),
                content: GestureDetector(
                  onHorizontalDragEnd: (DragEndDetails details2,) =>_onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Step 4'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      Text(
                        "Select your Point of Care for Self-Test".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Image.asset(
                        'assets/images/step-04.png',
                        height: MediaQuery.of(context).size.height * 50 / 100,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 3,
                state:_currentStep >= 3 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(''),
                content: GestureDetector(
                   onHorizontalDragEnd: (DragEndDetails details2,) =>_onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Step 5'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Capture picture of test kit and upload result \nPlease ensure that the result image is clear before submitting"
                            .tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Image.asset(
                        'assets/images/step-05.png',
                        height: MediaQuery.of(context).size.height * 40 / 100,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 4,
                state: _currentStep >= 4 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(''),
                content: GestureDetector(
                   onHorizontalDragEnd: (DragEndDetails details2,) =>_onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Step 6'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Proceed with payment' .tr,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Image.asset(
                        'assets/images/step-06.png',
                        height: MediaQuery.of(context).size.height * 40 / 100,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 5,
                state:_currentStep >= 5 ? StepState.complete : StepState.indexed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0) {}
    if (details.primaryVelocity!.compareTo(0) == -1) {
      setState(() {
        if (_currentStep < 5) {
          _currentStep++;
        } else {
          complete(context);
        }
      });
    } else {
      setState(() {
        if (_currentStep > 0) {
          _currentStep--;
        } else {
          _currentStep;
        }
      });
    }
  }

  void complete(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return TestSelectScreen(
        validationType: 1,
      );
    }));
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
}
