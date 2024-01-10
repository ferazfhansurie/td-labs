// ignore_for_file: must_be_immutable, unused_field, prefer_final_fields, non_constant_identifier_names, deprecated_member_use, duplicate_ignore
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tdlabs/screens/user/profile_form.dart';
import 'package:tdlabs/utils/web_service.dart';

import '../screening/test_form.dart';
import 'travelstep.dart';

class TravelSelectScreen extends StatefulWidget {
  const TravelSelectScreen({
    Key? key,
  }) : super(key: key);

  @override
  _TravelSelectScreenState createState() => _TravelSelectScreenState();
}

class _TravelSelectScreenState extends State<TravelSelectScreen> {
  bool isLoading = true;
  bool showSelfTest = false;
  bool isAcceptPolicy = false;
  bool _validationPicked = false;
  int policy = 0;
  int? _validationType;
  bool cont = false;
  int _page = 0;
  int? _pageCount = 1;
  bool _isLoading = false;
  List<dynamic> package = [
    'Book PCR',
    'Book PCR + Wechat',
    'Agent 1 Stop Solution'
  ];

  List<Poc> _list = [];
  @override
  void initState() {
    super.initState();
    _fetchPocs();
    checkProfile(context);
    _checkPermission();
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
                    SingleChildScrollView(
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
                                    "Traveller Program".tr,
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

  Future<List<Poc>?> _fetchPocs() async {
    final webService = WebService(context);
    if (!_isLoading && (_page < _pageCount!)) {
      _page++;
      _isLoading = true;
      webService.setEndpoint('screening/pocs').setPage(_page);
      Map<String, String> filter = {};
      filter.addAll({'is_travel_report': '1'});
      var response = await webService.setFilter(filter).send();
      if (response == null) return null;
      if (response.status) {
        final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<Poc> pocs =parseList.map<Poc>((json) => Poc.fromJson(json)).toList();
        setState(() {
          if (_list.isNotEmpty) {
            for (int i = 0; i < _list.length; i++) {
              pocs.removeWhere((element) => element.name == _list[i].name);
            }
          }
          _list.addAll(pocs);
        });
        _pageCount = response.pagination!['pageCount'];
      }
    }
    _isLoading = false;
    return _list;
  }

  _selfTestBuilder() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: package.length,
      itemBuilder: (context, index) {
        var num = index + 1;
        String name = package[index];
        return GestureDetector(
          onTap: () {
            if (index == 0) {
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return TestFormScreen(
                  optTestId: 1,
                  optTestName: name,
                  poc: _list[0],
                  price: 168,
                  travel: true,
                );
              }));
            } else {
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return TravelSteps(
                    name: package[index],
                    type:  (index == 1)
                            ? 7
                            : 8,
                    poc: _list[0]);
              }));
            }
          },
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 75,
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 18.0),
                                child: Text(
                                  num.toString(),
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    width: 140,
                                    child: Text(name.tr,
                                        style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              )
                            ])),
                  ),
                ],
              ),
            )
          ]),
        );
      },
    );
  }


  Widget _dividerBrand() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Package Option".tr,
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
      onPressed: () {},
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
                    'Please make sure the result is clearly seen before submitting your result.'
                        .tr,
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
