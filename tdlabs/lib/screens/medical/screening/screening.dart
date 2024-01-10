// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/screening/opt_test.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tdlabs/screens/user/profile_form.dart';
import '../../../adapters/test/opt_test2.dart';
import 'steps.dart';
import 'test_form.dart';
import 'test_select_screen.dart';

class EBookSelectScreen extends StatefulWidget {
  const EBookSelectScreen({
    Key? key,
  }) : super(key: key);
  @override
  _EBookSelectScreenState createState() => _EBookSelectScreenState();
}

class _EBookSelectScreenState extends State<EBookSelectScreen> {
  final List<OptTest> _listPoc = OptTest.fetchPocTest();
  late List<OptTest> _listSelf;
  bool isLoading = true;
  bool showSelfTest = false;
  bool isAcceptPolicy = false;
  // ignore: unused_field
  final bool _validationPicked = false;
  int policy = 0;
  final List<String>? _listImages = [
    "assets/images/pcr-icon.png",
    "assets/images/rtk-icon.png",
    "assets/images/antibody-icon.png",
    "assets/images/booster-icon.png",
  ];
  bool cont = false;
  @override
  void initState() {
    super.initState();
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
                padding:  EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  children: [
                    Center(
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
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.only(right: 15),
                              child: Text(
                                "Covid Screening".tr,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer()
                          ],
                        ),
                      ),
                    ),
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
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                  builder: (context) {
                                            return TestSelectScreen(
                                              validationType: 0,
                                            );
                                          }));
                                        },
                                        child: Container(
                                            height: 65,
                                            width: 285,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.blueGrey),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Image.asset(
                                                    "assets/images/icons-medical-white-02.png",
                                                    height: 60,
                                                    fit: BoxFit.fitHeight),
                                                Text(
                                                    "General Validation(Free)"
                                                        .tr,
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                const Spacer()
                                              ],
                                            )),
                                      ),
                                    ),
                              
                                  ],
                                ),
                                _dividerBrand(),
                                const SizedBox(
                                  height: 15,
                                ),
                                _testBuilder(),
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

  Widget _dividerBrand() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Others".tr,
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

  Widget _testBuilder() {
    return FutureBuilder(
        future: _fetchList(context),
        builder: (context, snapshot) {
          if ((snapshot.data != null)) {
            return Expanded(
              flex: 0,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _listPoc.length,
                itemBuilder: (context, index) {
                  OptTest optTest = _listPoc[index];
                  return (showSelfTest)
                      ? GestureDetector(
                          onTap: () {
                            (optTest.id != 2)
                                ? Navigator.of(context).push(
                                    CupertinoPageRoute(builder: (context) {
                                    return TestFormScreen(
                                      optTestId: optTest.id,
                                      optTestName: optTest.name,
                                      travel: false,
                                    );
                                  }))
                                : null;
                          },
                          child: OptTestAdapter2(
                              index: index,
                              image: _listImages!,
                              optTest: optTest),
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

  showAlertDialogInfo(BuildContext context, int? optTest_id) {
    Widget continueButton = CupertinoButton(
      child: Text(
        'Continue'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
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
                    'info-sample-before-test'.tr,
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
    Widget cancelButton = CupertinoButton(
      onPressed: () {},
      child: Container(),
    );
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
