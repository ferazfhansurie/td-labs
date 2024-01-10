// ignore_for_file: prefer_const_constructors_in_immutables, unnecessary_statements, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/poc/poc.dart';

import '../screening/test_form.dart';

class TravelSteps extends StatefulWidget {
  String? name;
  int? type;
  Poc? poc;
  TravelSteps({Key? key, this.name, this.type,this.poc}) : super(key: key);
  @override
  _TravelStepsState createState() => _TravelStepsState();
}

class _TravelStepsState extends State<TravelSteps> {
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
        padding: EdgeInsets.only(
         
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
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    child: Text(
                      widget.name!.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 19,
                      ),
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
        data: ThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                background: Colors.transparent,
              ),
        ),
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
                  onHorizontalDragEnd: (
                    DragEndDetails details2,
                  ) =>
                      _onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Step 1'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        (widget.type == 7)
                            ? "Book your appointment at point of care, date & session"
                                .tr
                            : "Book your agent before proceed your payment transfer"
                                .tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Image.asset(
                          (widget.type == 7)
                              ? 'assets/images/p2step-01.png'
                              : 'assets/images/p3step-01.png',
                          height: MediaQuery.of(context).size.height * 40 / 100,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Swipe to continue'.tr + ' ->',
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
                state:
                    _currentStep >= 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(''),
                content: GestureDetector(
                  onHorizontalDragEnd: (
                    DragEndDetails details2,
                  ) =>
                      _onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Step 2'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      Text(
                        (widget.type == 7)
                            ? "Confirm your check out summary before proceed your payment transfer"
                                .tr
                            : "You will receive receipt of payment & required fill in your information at the link of Google Form provided"
                                .tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Image.asset(
                        (widget.type == 7)
                            ? 'assets/images/p2step-02.png'
                            : 'assets/images/p3step-02.png',
                        height: MediaQuery.of(context).size.height * 40 / 100,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 1,
                state:
                    _currentStep >= 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(
                  '',
                ),
                content: GestureDetector(
                  onHorizontalDragEnd: (
                    DragEndDetails details2,
                  ) =>
                      _onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Step 3'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        (widget.type == 7)
                            ? "You will receive a receipt of payment & required fill in your information at the link of Google Form provided"
                                .tr
                            : "Within 24 hours, the agent will contact and guide you"
                                .tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Image.asset(
                        (widget.type == 7)
                            ? 'assets/images/p2step-03.png'
                            : 'assets/images/p3step-03.png',
                        height: MediaQuery.of(context).size.height * 40 / 100,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 2,
                state:
                    _currentStep >= 2 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(
                  '',
                ),
                content: GestureDetector(
                  onHorizontalDragEnd: (
                    DragEndDetails details2,
                  ) =>
                      _onHorizontalDrag(details2),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Step 4'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        (widget.type == 7)
                            ? "After all the information have been fill in at Google Form, our customer service will assist to update the result to WeChat mini app program International Version of Epidemic Prevention Health Code"
                                .tr
                            : "Agent will assist to obtain the report, organize airport transportation and boarding services"
                                .tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      Image.asset(
                        (widget.type == 7)
                            ? 'assets/images/p2step-04.png'
                            : 'assets/images/p3step-04.png',
                        height: MediaQuery.of(context).size.height * 40 / 100,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 3,
                state:
                    _currentStep >= 32 ? StepState.complete : StepState.indexed,
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
        if (_currentStep < 3) {
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
    Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          return TestFormScreen(
                            optTestId: (widget.name == "Book PCR + Wechat")
                                    ? 7
                                    : 8,
                            optTestName: widget.name,
                            poc: widget.poc,
                            price: (widget.name == "Book PCR + Wechat")
                                    ? 198
                                    : 599,
                            travel: true,
                          );
                        }));
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 4 ? setState(() => _currentStep += 1) : null;
    _currentStep >= 3 ? onComplete = true : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }
}
