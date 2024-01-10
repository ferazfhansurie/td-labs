// ignore_for_file: library_prefixes, non_constant_identifier_names, prefer_final_fields, unused_local_variable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as Get;
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlabs/screens/medical/e-consult/consult_poc.dart';
import 'package:tdlabs/screens/wellness/qiaolz.dart';
import 'package:tdlabs/widgets/button/morebutton.dart';
import '../../config/main.dart';
import '../../models/util/redeem.dart';
import '../../models/user/user.dart';
import '../../utils/web_service.dart';
import '../info/subscription.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  int redeem_limit = 0;
  String accessToken = '';
  String _points = '';
  String _date = '';
  List<Redeem> _list = [];
  int? redeem_count;
  String? avatar;
  double latest_app_ver = 0.0;
  int language = 0;
  int _healthStatus = 0;
  String tdc = "";
  String _testDate = '';
  int testPositive = 0;
  NumberFormat myFormat = NumberFormat("#,##0.00", "en_US");
  int test = 0;
  bool? valid_redeem;
  String reward = '';
  final locales = [
    {
      'name': 'English',
      'locale': const Locale('en', 'US'),
    },
    {'name': 'Bahasa Malaysia', 'locale': const Locale('ms', 'MY')},
    {'name': '简体中文'.tr, 'locale': const Locale('zh', 'ZH')},
  ];
  final keyIsFirstLoaded = 'is_first_loaded';

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _getAccessToken();
      _refreshContent();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(
                 
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(
                 
                ),
                child: SingleChildScrollView(
                  child: Column(children: [
                    Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(45.0),
                            bottomRight: Radius.circular(45.0),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 48, 186, 168),
                              Color.fromARGB(255, 49, 53, 131),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 30 / 100,
                            ),
                            Container(
                              alignment: Alignment.center,
                              height: 75,
                              child: Text(
                                "More".tr,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      children: [
                        _newsButton(),
                        const SizedBox(
                          height: 50,
                        ),
                        const Text("Coming Soon",
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const ConsultPocScreen();
                                      }));
                                    },
                                    child: Container(
                                        height: 75,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color.fromARGB(255, 48, 186, 168),
                                              Color.fromARGB(255, 49, 42, 130),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Image.asset(
                                            'assets/images/icons-news-colored-06.png',
                                            fit: BoxFit.fill)),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      "TD Consult\n(Coming Soon)",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 104, 104, 104),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 45,
                              ),
                              GestureDetector(
                                onTap: () async {
                               
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        height: 75,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color.fromARGB(255, 48, 186, 168),
                                              Color.fromARGB(255, 49, 42, 130),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Image.asset(
                                            'assets/images/icons-news-colored-07.png',
                                            fit: BoxFit.fill)),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        "MYCSR\n(Coming Soon)",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 104, 104, 104),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newsButton() {
    return Container(
      padding: const EdgeInsets.all(5),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 105,
          crossAxisCount: 3,
          crossAxisSpacing: 5.0,
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          int number = index + 1;
          return HomeButton(
              enabledButton: false,
              home: false,
              index: index,
              limit: redeem_limit,
              count: redeem_count,
              points: _points,
              date: _date,
              redeem: _list,
              url: (!MainConfig.modeLive)
                  ? 'http://dev.tdlabs.co/subscription?token=' + accessToken
                  : 'http://cloud.tdlabs.co/subscription?token=' + accessToken,
              image: 'assets/images/icons-news-colored-0' +
                  number.toString() +
                  '.png',
              image2: 'assets/images/icons-medical-white-0' +
                  number.toString() +
                  '.png',
              label: (index == 0)
                  ? 'Traveller Program'.tr
                  : (index == 1)
                      ? 'Smart Programme'.tr
                      : (index == 2)
                          ? 'Rewards'.tr
                          : (index == 3)
                              ? 'Dependants'
                              : (index == 4)
                                  ? 'Help Desk'
                                  : (index == 5)
                                      ? 'Dependants'
                                      : (index == 6)
                                          ? 'Traveller Program'
                                          : 'Upcoming Events'.tr);
        },
      ),
    );
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    accessToken = sharedPreferences.getString('api.access_token')!;
    return accessToken;
  }

  _checkPermission() async {
    var statusLocation = await Permission.locationWhenInUse.request();
    var statusStorage = await Permission.storage.request();
    var statusCamera = await Permission.camera.request();
    var permissionLocationStatus = await Permission.locationWhenInUse.status;
    var permissionCameraStatus = await Permission.camera.status;
    var permissionStorageStatus = await Permission.storage.status;
  }

  Future<void> _fetchUser() async {
    User? user = await User.fetchOne(context); // get current user
   

    if (user != null) {
      setState(() {
        if (user.avatar_url != null) {
          avatar = user.avatar_url;
        }
        latest_app_ver = double.parse(user.latest_app_ver!.toString());
        language = user.language!;
        _healthStatus = user.healthStatus!;
        var convert = double.parse(user.credit_cash!);
        tdc = myFormat.format(convert);
        var convert2 = double.parse(user.credit!);
        _points = myFormat.format(convert2);
        var arr = _points.split('.');
        _points = arr[0];
        _testDate = (user.latest_test_at != null)
            ? user.latest_test_at!.substring(0, 2)
            : "0";
        if (_healthStatus == 4) {
          testPositive = int.tryParse((user.stat_lock != null)
              ? user.stat_lock!.substring(8, 10)
              : "0")!;
          test = int.tryParse(_testDate)!;
        }
        if (_healthStatus != 0) {
          test = int.tryParse(_testDate)!;
        }
        
      });
      updateLocale(locales[language]['locale'] as Locale?, context);
      if (MainConfig.test == false) {
        if (user.policyAccepted != 1 &&
            Theme.of(context).platform == TargetPlatform.android) {
          showAlertPermissionConsentDialog(context);
        } else {
          _checkPermission();
        }
      }
    }
  }

  Future<void> _refreshContent() async {
    _fetchUser();
    if (MainConfig.test == false) {
      _checkRedeem();
    }
  }

  void updateLocale(Locale? locale, BuildContext context) {
    Get.Get.updateLocale(locale!);
  }

  showAlertPermissionConsentDialog(BuildContext context) async {
    bool isAgreed = false;
    int isAgreedNum = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLoaded;
    bool? getFromPref = prefs.getBool(keyIsFirstLoaded);
    if (getFromPref != null) {
      isFirstLoaded = getFromPref;
    } else {
      isFirstLoaded = true;
    }
  }

  Future<List?> _checkRedeem() async {
    _list.clear();
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('plan/rewards/get-package');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Redeem> redeem =
          parseList.map<Redeem>((json) => Redeem.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _list.addAll(redeem);
          valid_redeem = _list[0].is_valid!;
          reward = (valid_redeem == true) ? _list[0].reward_amount! : "0";
          var arr = reward.split('.');
          reward = arr[0];
          redeem_limit =
              (_list[0].redeem_limit != null) ? _list[0].redeem_limit! : 0;
          redeem_count =
              (_list[0].redeem_count != null) ? _list[0].redeem_count! : 0;
          _date = (_list[0].redeem_at != null)
              ? _list[0].redeem_at.toString()
              : "0";
        });
      }
      if (valid_redeem == true) {
        showAlertDialog(context);
      }
    }
    return _list;
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      child: Text(
        'Cancel'.tr,
        style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
            color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text(
        'Collect'.tr,
        style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return Subscription(
            limit: redeem_limit,
            count: redeem_count,
            date: _date,
            points: _points,
            redeem: _list,
            tabIndex: 0,
            url: (!MainConfig.modeLive)
                ? 'http://dev.tdlabs.co/subscription?token=' + accessToken
                : 'http://cloud.tdlabs.co/subscription?token=' + accessToken,
          );
        }));
      },
    );

    Widget alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      content: Container(
        height: 200,
        width: 115,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 52, 169, 176),
              Color.fromARGB(255, 49, 42, 130),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: RichText(
                text: TextSpan(
                  text: 'Collect your '.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Daily Reward'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: ' Now!'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 75,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [continueButton, cancelButton],
              ),
            )
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(0.0),
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
}
