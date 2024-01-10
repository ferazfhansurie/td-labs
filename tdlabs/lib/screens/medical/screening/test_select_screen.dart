// ignore_for_file: must_be_immutable, unused_field, prefer_final_fields, non_constant_identifier_names, deprecated_member_use, duplicate_ignore

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/screening/opt_test.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tdlabs/screens/medical/screening/other_form.dart';
import 'package:tdlabs/screens/medical/screening/self_test_form.dart';
import 'package:tdlabs/screens/user/profile_form.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../adapters/test/opt_test.dart';

class TestSelectScreen extends StatefulWidget {
  int validationType;

  TestSelectScreen({Key? key, required this.validationType}) : super(key: key);

  @override
  _TestSelectScreenState createState() => _TestSelectScreenState();
}

class _TestSelectScreenState extends State<TestSelectScreen> {
  final List<OptTest> _listPoc = OptTest.fetchPocTest();
  late List<OptTest> _listSelf;
  bool isLoading = true;
  bool showSelfTest = false;
  bool isAcceptPolicy = false;
  bool _validationPicked = false;
  int policy = 0;
  int? _validationType;
  bool cont = false;

  @override
  void initState() {
    super.initState();
    _validationType = widget.validationType;
    _fetchList(context);
    checkProfile(context);
    _checkPermission();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showSelfTest = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/Background-01.png"),
                  fit: BoxFit.fill),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                 
                ),
                child: Column(
                  children: [
                    (isLoading)
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: Colors.white,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
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
                                        Text(
                                          "Self Test Select".tr,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        const Spacer()
                                      ],
                                    ),
                                  ),
                                ),
                                _dividerBrand(),
                                const SizedBox(
                                  height: 15,
                                ),
                                _selfTestBuilder(),
                                const SizedBox(
                                  height: 85,
                                ),
                                _demoButton()
                              ],
                            ),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _selfTestBuilder() {
    return FutureBuilder(
        future: _fetchList(context),
        builder: (context, snapshot) {
          if ((snapshot.data != null)) {
            return Expanded(
              flex: 0,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _listSelf.length,
                itemBuilder: (context, index) {
                  OptTest optTest = _listSelf[index];
                  return (showSelfTest)
                      ? GestureDetector(
                          onTap: () {
                            if (optTest.id == 7) {
                              Navigator.pop(context);
                              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                return OtherFormScreen(
                                  optTestId: optTest.id,
                                  payed: false,
                                  validationType: _validationType,
                                );
                              }));
                            } else {
                              showAlertDialogInfo(context, optTest.id);
                            }
                          },
                          child: OptTestAdapter(optTest: optTest),
                        )
                      : const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()));
                },
              ),
            );
          } else {
            return Container();
          }
        });
  }

  _demoButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 36,
          width: 75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.white,
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 24, 112, 141).withOpacity(0.6),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: GestureDetector(
              onTap: () {
                _launchURL('https://www.youtube.com/watch?v=0H5cYCHim1s&t=1s&ab_channel=MyCSP');
              },
              child: Row(
                children: [
                  Image.asset("assets/images/icons-colored-demo.png",
                      height: 55, fit: BoxFit.fill),
                   Text(
                    "Demo".tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        decoration: TextDecoration.underline),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _dividerBrand() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Brand".tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  showAlertDialogInfo(BuildContext context, int? optTest_id) {
    // set up the buttons
    // ignore: deprecated_member_use, unused_local_variable
    Widget cancelButton = CupertinoButton(
      onPressed: () {},
      child: Container(),
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text(
        'Continue'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return SelfTestForm(
            optTestId: optTest_id,
            method: 1,
            validationType: widget.validationType,
            cont: cont,
          );
        }));
      },
    );
    // set up the AlertDialog
    Widget alert = Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              'Info'.tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Please make sure the result is clearly seen before submitting your result.'.tr,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Divider(
                    height: 20,
                    thickness: 2,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                  Image.asset(
                    (optTest_id == 6)
                        ? "assets/images/raycus-test-kit-example.jpeg"
                        : "assets/images/self-test-kit-sample.png",
                    height: MediaQuery.of(context).size.height * 40 / 100,
                  ),
                  Divider(
                    height: 20,
                    thickness: 2,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      continueButton,
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      onPressed: () {},
      child: Container(),
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text(
        'Continue'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return const ProfileFormScreen();
        }));
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        'Info'.tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      content: Text(
        'Please complete your profile to proceed'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }

  Future<void> checkProfile(BuildContext context) async {
    User? user = await User.fetchOne(context);
    showAlertDialog(context);
    if (user != null) {
      List<String> check = [];
      check = User.checkProceedTest(user);
      if (check.isEmpty) {
        Navigator.pop(context);
      }
    }
  }

  Future<List<OptTest>> _fetchList(BuildContext context) async {
    _listSelf = (await OptTest.fetchSelfTest(context))!;
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    return _listSelf;
  }

  _checkPermission() async {
    // ignore: unused_local_variable
    var statusLocation = await Permission.locationWhenInUse.request();
    // ignore: unused_local_variable
    var statusStorage = await Permission.storage.request();
    // ignore: unused_local_variable
    var statusCamera = await Permission.camera.request();
    // ignore: unused_local_variable
    var permissionLocationStatus = await Permission.locationWhenInUse.status;
    // ignore: unused_local_variable
    var permissionCameraStatus = await Permission.camera.status;
    // ignore: unused_local_variable
    var permissionStorageStatus = await Permission.storage.status;
  }
}
