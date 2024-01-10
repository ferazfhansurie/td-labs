// ignore_for_file: unused_local_variable, avoid_unnecessary_containers, curly_braces_in_flow_control_structures, unnecessary_null_comparison, avoid_renaming_method_parameters

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/screening/self-test.dart';
import 'package:tdlabs/models/screening/test.dart';
import 'package:tdlabs/screens/history/transfer_details.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class SelfTestResultConfirmation extends StatefulWidget {
  SelfTest? selfTest;
  Test? test;
  // ignore: non_constant_identifier_names
  int? ai_result;
  // ignore: non_constant_identifier_names
  int test_id;
  String? imageUrl;
  bool fromHistory;
  SelfTestResultConfirmation(
      {Key? key,
      this.selfTest,
      // ignore: non_constant_identifier_names
      this.ai_result,
      // ignore: non_constant_identifier_names
      required this.test_id,
      this.test,
      this.imageUrl,
      required this.fromHistory})
      : super(key: key);
  @override
  _SelfTestResultConfirmationState createState() =>_SelfTestResultConfirmationState();
}

class _SelfTestResultConfirmationState extends State<SelfTestResultConfirmation> {
  Uint8List? image;
  // ignore: non_constant_identifier_names
  int? confirmed_result;
  String result = '';
  bool pressAttention1 = false;
  bool pressAttention2 = false;
  bool pressAttention3 = false;
  @override
  void initState() {
    //implement initState
    super.initState();
    if (widget.selfTest != null) convertImage();
  }

  @override
  void dispose() {
    //implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Offset> _points = <Offset>[];
    return WillPopScope(
      onWillPop: () async => (widget.fromHistory) ? true : false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: CupertinoPageScaffold(
          child: Column(children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Background-02.png"),
                    fit: BoxFit.fill),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
                 
                  bottom: MediaQuery.of(context).padding.bottom),
              child: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Result Confirmation".tr,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _resultConfirmCard()
                ],
              )),
            )
          ]),
        ),
      ),
    );
  }

  _resultConfirmCard() {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 90 / 100,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _divider('Ai Result Confirmation'.tr),
                const SizedBox(height: 10),
                (image != null)
                    ? Image.memory(
                        image!,
                        fit: BoxFit.fitHeight,
                        height: MediaQuery.of(context).size.height * 0 / 100,
                        width: MediaQuery.of(context).size.width * 30 / 100,
                      )
                    : (widget.imageUrl != '')
                        ? FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,image:
                            widget.imageUrl!,
                            fit: BoxFit.fitHeight,
                            height:MediaQuery.of(context).size.height * 30 / 100,
                            width: MediaQuery.of(context).size.width * 30 / 100,
                          )
                        : SizedBox(
                            height:MediaQuery.of(context).size.height * 30 / 100,
                            width: MediaQuery.of(context).size.width * 30 / 100,
                            child: const Icon(
                              CupertinoIcons.photo,
                              size: 100,
                            ),
                          ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Image.asset(
                        'assets/images/result.png',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Our AI system detected the result as '.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              (widget.ai_result == 1)
                  ? Card(
                      color: Colors.green,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Text(
                          'Negative'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : (widget.ai_result == 2)
                      ? Card(
                          color: Colors.red,
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Text(
                              'Positive'.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Card(
                          color: Colors.grey,
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Text(
                              'Invalid'.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        child: Image.asset(
                          'assets/images/positive.png',
                          width: MediaQuery.of(context).size.width * 25 / 100,
                        ),
                      ),
                      Container(
                        child: Image.asset(
                          'assets/images/negative.png',
                          width: MediaQuery.of(context).size.width * 25 / 100,
                        ),
                      ),
                      Container(
                        child: Image.asset(
                          'assets/images/invalid.png',
                          width: MediaQuery.of(context).size.width * 25 / 100,
                        ),
                      ),
                    ]),
                Text(
                  'Please confirm the result.'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: (widget.ai_result != 0)
                          ? ElevatedButton(
                              onPressed: () {
                                if (!pressAttention2 && !pressAttention3) {
                                  if (mounted) {
                                    setState(() {
                                      confirmed_result = 2;
                                      pressAttention1 = !pressAttention1;
                                    });
                                  }
                                  if (pressAttention1) {
                                    confirmResult(context);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pressAttention1
                                    ? const Color.fromARGB(255, 0, 57, 104)
                                    : Colors.red,
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width *18 /100,
                                alignment: Alignment.center,
                                child: Text(
                                  'Positive'.tr,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (!pressAttention2 && !pressAttention3) {
                                  if (mounted) {
                                    setState(() {
                                      confirmed_result = 2;
                                      pressAttention1 = !pressAttention1;
                                    });
                                  }
                                  if (pressAttention1) {
                                    confirmResult(context);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pressAttention1
                                    ? const Color.fromARGB(255, 0, 57, 104)
                                    : Colors.red,
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width *18 /100,
                                alignment: Alignment.center,
                                child: Text('Positive'.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                    ),
                    Container(
                      child: (widget.ai_result != 0)
                          ? ElevatedButton(
                              onPressed: () {
                                if (!pressAttention1 && !pressAttention3) {
                                  if (mounted) {
                                    setState(() {
                                      pressAttention2 = !pressAttention2;
                                      confirmed_result = 1;
                                    });
                                  }
                                  if (pressAttention2) {
                                    confirmResult(context);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pressAttention2
                                    ? const Color.fromARGB(255, 0, 57, 104)
                                    : Colors.green,
                              ),
                              child: Container(
                                  width: MediaQuery.of(context).size.width * 20 /100,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Negative'.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (!pressAttention1 && !pressAttention3) {
                                  if (mounted) {
                                    setState(() {
                                      pressAttention2 = !pressAttention2;
                                      confirmed_result = 1;
                                    });
                                  }
                                  if (pressAttention2) {
                                    confirmResult(context);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pressAttention2
                                    ? const Color.fromARGB(255, 0, 57, 104)
                                    : Colors.green,
                              ),
                              child: Container(
                                  width: MediaQuery.of(context).size.width *18 /100,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Negative'.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!pressAttention1 &&
                              !pressAttention2) if (mounted) {
                            setState(() {
                              pressAttention3 = !pressAttention3;
                              confirmed_result = 0;
                            });
                          }
                          if (pressAttention3) {
                            confirmResult(context);
                          }
                          // submitForm(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pressAttention3
                              ? const Color.fromARGB(255, 0, 57, 104)
                              : Colors.grey,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 18 / 100,
                          alignment: Alignment.center,
                          child: (widget.ai_result != 0)
                              ? Text(
                                  "Invalid".tr,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  "Invalid".tr,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  confirmResult(BuildContext context) {
    Widget continueButton = CupertinoButton(
      child: Text(
        'Yes'.tr,
        style: const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.green,
            fontWeight: FontWeight.w300),
      ),
      onPressed: () {
        if (mounted) {
          submitForm(context);
        }
      },
    );
    Widget cancelButton = CupertinoButton(
      child: Text(
        'No'.tr,
        style: const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.red,
            fontWeight: FontWeight.w300),
      ),
      onPressed: () {
        setState(() {
          pressAttention1 = false;
          pressAttention2 = false;
          pressAttention3 = false;
        });
        Navigator.of(context).pop();
      },
    );
    // ignore: deprecated_member_use

    // set up the AlertDialog
    Widget alert = Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              "I hereby confirm that this Self Test was conducted according to procedures stated in this app and the sample is authentically my own".tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w300),
            ),
            actions: [
              cancelButton,
              continueButton,
            ],
          ),
        ],
      ),
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void convertImage() {
    if (mounted) {
      setState(() {
        image = base64Decode(widget.selfTest!.image!);
      });
    }
  }

  void checkStatus() {
    if (mounted) {
      setState(() {
        switch (confirmed_result) {
          case 0:
            result = 'Invalid'.tr;
            break;
          case 1:
            result = 'Negative'.tr;
            break;
          case 2:
            result = 'Positive'.tr;
            break;
          default:
        }
      });
    }
  }

  Widget _divider(String name) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color.fromARGB(255, 0, 57, 104),
                  fontWeight: FontWeight.w300,
                  fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitForm(BuildContext context) async {
    SelfTest selfTest = SelfTest();
    // ignore: non_constant_identifier_names
    int test_id = 0;
    if (widget.test_id != null) {
      setState(() {
        test_id = widget.test_id;
      });
    } else {
      setState(() {
        test_id = widget.test!.id!;
      });
    }
    if (mounted) {
      setState(() {
        selfTest.confirmed_result = confirmed_result;
      });
    }
    List<String> errors = [];
    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    var response = await SelfTest.submitForm(context, selfTest, test_id);
    ProgressDialog.hide(progressDialogKey);
    if (response != null) {
      if (response.status) {
        var array = jsonDecode(response.body.toString());
        var testId = array["id"];
        Toast.show(context, 'default', 'Result Recorded');
        if (!widget.fromHistory) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context, true);
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return TransferDetails(
              testID: testId,
            );
          }));
        } else {
          Navigator.pop(context, true);
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return TransferDetails();
          }));
        }
      } else if (response.error.isNotEmpty) {
        errors.add(response.error.values.toList()[0]);
      } else {
        errors.add('Server connection timeout.');
      }
    }
    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }
}

class SignaturePainter extends CustomPainter {
  SignaturePainter(this.points);
  final List<Offset> points;
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter other) => other.points != points;
}
