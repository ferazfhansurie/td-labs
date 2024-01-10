// ignore_for_file: library_prefixes, must_be_immutable, prefer_final_fields, non_constant_identifier_names, unused_field, prefer_typing_uninitialized_variables, unnecessary_null_comparison, avoid_unnecessary_containers, body_might_complete_normally_nullable, unused_local_variable, deprecated_member_use, duplicate_ignore

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/screening/opt_test.dart';
import 'package:tdlabs/screens/checkout/checkout.dart';
import 'package:tdlabs/screens/history/transfer_details.dart';
import 'package:tdlabs/screens/medical/screening/selftest_result_confirmation.dart';
import 'package:tdlabs/screens/user/profile_form.dart';
import 'package:tdlabs/screens/widget/scanner.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/widgets/form/test_kit_input.dart';
import 'package:tdlabs/widgets/form/test_kit_video_input.dart';
import '../../../global.dart' as global;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlabs/models/util/country_state.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:tdlabs/models/screening/self-test.dart';
import 'package:tdlabs/models/survey.dart';
import 'package:tdlabs/models/screening/test.dart';
import 'package:tdlabs/models/user/user-dependant.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/form/text_input.dart';
import 'package:url_launcher/url_launcher.dart';

import '../others/poc_select.dart';

class SelfTestForm extends StatefulWidget {
  SelfTest? selfTest;
  Test? test;
  int? test_id;
  int? optTestId;
  int validationType;
  int? method;
  String? qrCapture;
  String? videoUrl;
  String? tac;
  String? price;
  bool cont;
  SelfTestForm(
      {Key? key,
      this.selfTest,
      this.test_id,
      required this.optTestId,
      required this.validationType,
      this.qrCapture,
      this.videoUrl,
      this.method,
      this.tac,
      this.test,
      this.price,
      required this.cont})
      : super(key: key);

  @override
  _SelfTestFormState createState() => _SelfTestFormState();
}

class _SelfTestFormState extends State<SelfTestForm> {
  late Poc _poc;
  Test? _test;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final postcodeController = TextEditingController();
  final cityController = TextEditingController();
  final surveyController = TextEditingController();
  final surveyController2 = TextEditingController();
  final imageController = TextEditingController();
  final videoController = TextEditingController();
  final videoLocationController = TextEditingController();
  List<Poc> _list = [];
  File? galleryFile;
  late String image;
  int _optTestId = 0;
  bool _qrValid = false;
  bool depend = false;
  String tac = "";
  String types = "";
  Map<String, dynamic> _qrCapture = {};
  String? results;
  bool isLoading = true;
  int? test_id;
  int c = 0;
  int g = 1;
  int m = 2;
  int state = 0;
  int dependant_id = 0;
  List<dynamic>? _dependantList;
  String? stateName;
  int? stateIndex;
  bool _isLoadingCS = false;
  List<CountryState>? _csList = [];
  List<dynamic>? type = [];
  int _pickerIndex = 0;
  int _pickerIndex2 = 0;
  String _stateCode = '';
  int country = 0;
  List<String> _listCountry = ['Malaysia'];
  List<String> _listCountryCode = ['my'];
  String? countryName;
  String? countryCode;
  final List<Map<String, dynamic>> _specimenTypeList = [
    {'id': 2, 'name': 'Saliva'},
    {'id': 4, 'name': 'Nasal'}
  ];
  String specimenTypeName = '';
  String typeName = '';
  int typeID = 0;
  int specimenTypeIndex = 0;
  int typeIndex = 0;
  int? specimenTypeCode;
  int kitObtainedNumber = 0;
  List<Survey>? kitObtainedList = [];
  String kitObtained = '';
  String brand = '';
  int brandNumber = 0;
  List<int> kit_result = [];
  int ref_No = 1;
  List<Survey>? brandList = [];
  var answers;
  var question;
  var answers2;
  var question2;
  int? answer_id;
  int? question_id;
  int? answer_id2;
  int? question_id2;
  NumberFormat _formatter = NumberFormat(',##0.00');
  bool showPlayer = false;
  String latitude = '';
  String longitude = '';
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  SharedPreferences? prefs;
  bool showAISkip = false;
  int getAISkip = 0;
  final keyShowAISkip = 'show-ai-skip';
  bool AISkip = true;
  String imageSample = '';
  int validationType = 0; //0 - general validation, 1 = SIMKA
  bool showForm = false;
  String? videoLocation;
  String? videoPath;
  Timer? timer;
  int startTimer = 900;
  bool showTimer = false;
  String timerDuration = '00 m 00';
  String? preVideo;
  bool cont = false;
  String? videoUrl2;
  Uri? videoUri2;
  List<UserDependant> _udList = [];
  ScrollController _scrollController = ScrollController();
  String dependName = "";
  @override
  void initState() {
    super.initState();
    test_id = widget.test_id;
    validationType = widget.validationType;
    Permission.locationWhenInUse.request();
    if (isLoading = true && widget.method == 0) {
      _getTest();
      _fetchType();
      cont = widget.cont;
    }
    _fetchUD();
    _fetchAnswers(ref_No, answers, question);
    if (widget.method == 0) {
      _fetchAnswers2(ref_No, answers2, question2);
    }
    _populateForm();
    _poc = Poc();
    cont = widget.cont;
    if (cont == true) {
      resume();
    } else {
      if (mounted) {
        setState(() {
          validationType = widget.validationType;
          _optTestId = widget.optTestId!;
        });
      }
    }
    _getLocation();
    _defaultAnswer();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showPlayer = true;
      });
    });
  }

  Future<Test?> _getTest() async {
    final webService = WebService(context);
    // get single test model
    var response = await webService
        .setEndpoint('screening/tests/' + test_id.toString())
        .setExpand('poc,user')
        .send();
    if (response == null) return null;
    if (response.status) {
      var modelArray = jsonDecode(response.body.toString());
      _test = Test.fromJson(modelArray);
      if (OptTest.typeEnum.containsKey(_test!.type)) {}
      if (widget.method == 0) {
        setState(() {
          tac = _test!.tac_code!;
        });
      }
    } else {
      setState(() {
        types = _test!.type!.toString();
      });
    }
    isLoading = false;
    return _test;
  }

  Future<List<UserDependant>?> _fetchUD() async {
    _fetchDependant(context);
    final webService = WebService(context);
    var response =
        await webService.setEndpoint('identity/user-dependants').send();
    if (response == null) return null;
    if (response.status) {
      final parseList2 =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<UserDependant> ud = parseList2
          .map<UserDependant>((json) => UserDependant.fromJson(json))
          .toList();
      if (mounted) {
        setState(() {
          _udList.addAll(ud);
        });
      }
    }
    return _udList;
  }

  Future<List<dynamic>?> _fetchDependant(BuildContext context) async {
    final webService = WebService(context);
    var response =
        await webService.setEndpoint('identity/user-dependants').send();
    if (response == null) return null;
    if (response.status) {
      _dependantList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
    }
    return _dependantList;
  }

  void resume() {
    if (widget.validationType == 1 && widget.method == 1) {
      setState(() {
        validationType = widget.validationType;
        test_id = widget.test_id;
        _qrValid = true;
        _optTestId = widget.optTestId!;
        _qrCapture['qrcode'] = widget.qrCapture;
        _qrCapture['type'] = widget.test!.type;
        updateQRValid(_qrCapture['qrcode']);
        preVideo = widget.videoUrl;
        videoController.text = preVideo.toString();
        videoLocationController.text = preVideo.toString();
        validationType = widget.validationType;
      });
    } else {
      setState(() {
        test_id = widget.test_id;
        _optTestId = widget.optTestId!;
        tac = widget.tac!;
        _qrValid = true;
        preVideo = widget.videoUrl;
        videoController.text = preVideo.toString();
        videoLocationController.text = preVideo.toString();
        validationType = widget.validationType;
      });
    }
    _fetchPocs();
  }

  void startTimerCountdown() {
    showTimer = true;
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (timer) {
      if (startTimer == 720) {
        showSkippable(context, timer);
      }
      if (startTimer == 540) {
        showSkippable(context, timer);
      }
      if (startTimer == 0) {
        if (mounted) {
          setState(() {
            timer.cancel();
            showForm = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            startTimer--;
            timerDuration = formatDuration(startTimer);
          });
        }
      }
    });
  }

  showSkippable(BuildContext context, Timer timer) {
    Widget cancelButton = CupertinoButton(
      child: Text('No'.tr),
      onPressed: () {
        setState(() {});
        Navigator.of(context).pop();
      },
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text('Yes'.tr),
      onPressed: () {
        if (mounted) {
          setState(() {
            Navigator.of(context).pop();
            timer.cancel();
            showForm = true;
            _qrValid = true;
            preVideo = videoController.text;
            global.updateTestScreen = true;
            _fetchPocs();
            showAlertDialogInfo(context, _optTestId);
          });
        }
        Navigator.of(context).pop(); // closing showCupertinoModalPopup
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
              'Has the result shown?'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 104, 104, 104),
              ),
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

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;
    final minutesString = '$minutes'.padLeft(2, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    String format = '$minutesString m $secondsString s';
    return format;
  }

  @override
  // ignore: missing_return

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    postcodeController.dispose();
    cityController.dispose();
    //_imageController.dispose();
    imageController.dispose();
    videoController.dispose();
    surveyController.dispose();
    surveyController2.dispose();
    prefs!.setInt(keyShowAISkip, 0);
    super.dispose();
  }

  _defaultAnswer() {
    if (mounted) {
      setState(() {
        specimenTypeIndex = 1;
        specimenTypeCode = _specimenTypeList[specimenTypeIndex]['id'];
        specimenTypeName = _specimenTypeList[specimenTypeIndex]['name'];
      });
    }
  }

  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });
    }
    assignVideoUrl();
    if (cont == false) {
      if (validationType == 1) {
        if (mounted) {
          checkProfile(context);
        }
      }
    }
  }

  void updateQRValid(String qrCapture) {
    _qrCapture['qrcode'] = qrCapture;
    _qrValid = true;
    widget.method = 1;
    if (validationType == 0) {
      _fetchPocs();
    }
    setState(() {});
  }

  void goToScanner() async {
    _qrCapture =
        await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return ScannerScreen(
        optTestId: _optTestId,
      );
    }));
    updateQRValid(_qrCapture['qrcode']);
  }

  Future<void> checkProfile(BuildContext context) async {
    User? user = await User.fetchOne(context);
    if (user != null) {
      if (mounted) {
        List<String> check = [];
        check = User.checkProceedSimka(user);
        if (check.isNotEmpty) {
          showAlertDialogProfileComplete(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_optTestId == 6) {
      imageSample = "assets/images/raycus-test-kit-example.jpeg";
    } else {
      imageSample = "assets/images/self-test-kit-sample.png";
    }

    double price =
        (_poc.price != null) ? double.parse(_poc.price.toString()) : 0;

    return CupertinoPageScaffold(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-02.png"),
              fit: BoxFit.fill),
        ),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
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
                          (showForm == false && validationType == 0)
                              ? Container(
                                  padding: const EdgeInsets.only(right: 35),
                                  child: Text(
                                    "Self Test Scan".tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                )
                              : (validationType == 0)
                                  ? Container(
                                      padding: const EdgeInsets.only(right: 35),
                                      child: Text(
                                        "Self Test Result".tr,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.only(right: 35),
                                      child: const Text(
                                        "SIMKA",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                          const Spacer()
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (_qrValid == true),
                      replacement: (widget.method != 0)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Center(
                                        child: Text(
                                          'QR Scan'.tr,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    
                                    GestureDetector(
                                      onTap: () {
                                        goToScanner();
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              45 /
                                              100,
                                          height: 150,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            CupertinoIcons.qrcode_viewfinder,
                                            size: 100,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(height: 25),
                                        Center(
                                            child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Text(
                                            'Scan a valid QR code to get Validation Report'
                                                .tr,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 20),
                                          ),
                                        )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    (_optTestId == 4)
                                        ? GestureDetector(
                                            onTap: () {
                                              _launchURL(videoUrl2!);
                                            },
                                            child: Text(
                                              'Click Here To Watch Instruction Video'
                                                  .tr,
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w300,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    const SizedBox(height: 60),
                                  ],
                                ),
                              ],
                            )
                          : (validationType == 1)
                              ? _simkaTac()
                              : _generalTac(),
                      child: Visibility(
                        visible: (showForm == true || preVideo != null),
                        replacement: (validationType == 0)
                            ? _generalScan()
                            : _simkaVideoQR(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (widget.method == 1)
                                ? _generalScanDisplay()
                                : _generalTacDisplay(),
                            Column(
                              children: [
                                _imageDisplay(),
                                _imageInput(),
                                const SizedBox(height: 10),
                                (preVideo == null)
                                    ? Container()
                                    : _videoDisplay(),
                                Column(
                                  children: [
                                    (validationType == 1)
                                        ? _divider('Point Of Care Selection'.tr)
                                        : _divider('Validation Method'.tr),
                                    Visibility(
                                        replacement: _pocSelect(),
                                        child: _pocDisplay(price)),
                                    _selfTestForm(),
                                    _submitButton(),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))),
      ),
    );
  }

  Widget _divider(String name) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            alignment: Alignment.bottomLeft,
            child: Text(
              name,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  _simkaTac() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'TAC Number'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 20),
              ),
            )),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 45 / 100,
                height: 150,
                alignment: Alignment.center,
                child: Text(
                  (tac != null) ? tac : "",
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 35,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
            Center(
                child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                'Please Take the Test and \nWrite TAC Number on Test-Kit'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 20),
              ),
            )),
            const SizedBox(
              height: 10,
            ),
            _divider('Start Recording Self-Test Video'.tr),
            Container(
                child: TestKitVideoInput(
              label: '',
              controller: videoController,
              locationController: videoLocationController,
              readOnly: showTimer,
            )),
            const Divider(
              height: 50,
            ),
            (!showTimer)
                ? CupertinoButton(
                    color: CupertinoTheme.of(context).primaryColor,
                    child: Text('Continue'.tr),
                    onPressed: () {
                      if (videoController.text != '') {
                        showAlertDialogVideo(context);
                      } else {
                        Toast.show(context, 'default',
                            'Please upload your self-test kit video');
                      }
                    })
                : Column(
                    children: [
                      Text(
                        'Please wait for '.tr + timerDuration,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We will proceed automatically'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Reminder'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '1. Please place the camera 1 meter away then start recording Self-Test Video'
                        .tr,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '2. Please do not close the APP or press Back button (Continue after 15 mins)'
                        .tr,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            (_optTestId == 4)
                ? GestureDetector(
                    onTap: () {
                      _launchURL(videoUrl2!);
                    },
                    child: Text(
                      'Click Here To Watch Instruction Video'.tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          decoration: TextDecoration.underline,
                          color: Colors.black),
                    ),
                  )
                : Container(),
            const SizedBox(height: 60),
          ],
        ),
      ],
    );
  }

  _simkaVideoQR() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Text(
                  'QR Scan'.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 20),
                ),
              ),
            ),
            Card(
              color: const Color.fromARGB(255, 0, 57, 104),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 45 / 100,
                height: 150,
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.qrcode_viewfinder,
                  size: 100,
                  color: CupertinoColors.white,
                ),
              ),
            ),
            _divider('Start Recording Self-Test Video'.tr),
            Container(
                child: TestKitVideoInput(
              label: '',
              controller: videoController,
              locationController: videoLocationController,
              readOnly: showTimer,
            )),
            const Divider(
              height: 50,
            ),
            (!showTimer)
                ? CupertinoButton(
                    color: CupertinoTheme.of(context).primaryColor,
                    child: Text('Continue'.tr),
                    onPressed: () {
                      if (videoController.text != '') {
                        showAlertDialogVideo(context);
                      } else {
                        Toast.show(context, 'default',
                            'Please upload your self-test kit video');
                      }
                    })
                : Column(
                    children: [
                      Text(
                        'Please wait for '.tr + timerDuration,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We will proceed automatically'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Reminder'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '1. Please place the camera 1 meter away then start recording Self-Test Video'
                        .tr,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '2. Please do not close the APP or press Back button (Continue after 15 mins)'
                        .tr,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  _generalScan() {
    return (widget.method == 1)
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: Text(
                    'QR Scan'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 20),
                  ),
                ),
              ),
              Card(
                color: const Color.fromARGB(255, 0, 57, 104),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 45 / 100,
                  height: 150,
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.qrcode_viewfinder,
                    size: 100,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  'Please Take the Test '.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 20),
                ),
              )),
              CupertinoButton(
                  child: Text('Continue'.tr),
                  color: const Color.fromARGB(255, 0, 57, 104),
                  onPressed: () {
                    setState(() {
                      showForm = true;
                      _qrValid = true;
                      global.updateTestScreen = true;
                      _fetchPocs();
                      showAlertDialogInfo(context, _optTestId);
                    });
                  }),
              const SizedBox(
                height: 10,
              ),
              (_optTestId == 4)
                  ? GestureDetector(
                      onTap: () {
                        _launchURL(videoUrl2!);
                      },
                      child: Text(
                        'Click Here To Watch Instruction Video'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.underline,
                            color: Colors.black),
                      ),
                    )
                  : Container(),
              const SizedBox(height: 60),
            ],
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  'TAC Number'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 20),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 45 / 100,
                  height: 150,
                  alignment: Alignment.center,
                  child: Text(
                    (tac != null) ? tac : "",
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 35,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  'Please take self-test and write TAC number on kit '.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 20),
                ),
              )),
              CupertinoButton(
                  child: Text('Continue'.tr),
                  color: const Color.fromARGB(255, 0, 57, 104),
                  onPressed: () {
                    setState(() {
                      showForm = true;
                      _qrValid = true;
                      global.updateTestScreen = true;
                      _fetchPocs();
                      showAlertDialogInfo(context, _optTestId);
                    });
                  }),
              const SizedBox(
                height: 10,
              ),
              (_optTestId == 4)
                  ? GestureDetector(
                      onTap: () {
                        _launchURL(videoUrl2!);
                      },
                      child: Text(
                        'Click Here To Watch Instruction Video'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.underline,
                            color: Colors.black),
                      ),
                    )
                  : Container(),
              const SizedBox(height: 60),
            ],
          );
  }

  _generalScanDisplay() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Text(
                  'QR Scan'.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 20),
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.checkmark,
              color: Colors.white,
            )
          ],
        ),
        Card(
          color: const Color.fromARGB(255, 0, 57, 104),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 45 / 100,
            height: 150,
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.qrcode_viewfinder,
              size: 100,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ],
    );
  }

  _generalTac() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'TAC Number'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 20),
              ),
            )),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 45 / 100,
                height: 150,
                alignment: Alignment.center,
                child: Text(
                  (tac != null) ? tac : "",
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 35,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
            Center(
                child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                'Please Take the Test and \nWrite TAC Number on Test-Kit'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 20),
              ),
            )),
            CupertinoButton(
                child: Text('Continue'.tr),
                color: const Color.fromARGB(255, 0, 57, 104),
                onPressed: () {
                  setState(() {
                    showForm = true;
                    _qrValid = true;
                    global.updateTestScreen = true;
                    _fetchPocs();
                    showAlertDialogInfo(context, _optTestId);
                  });
                }),
            const SizedBox(
              height: 10,
            ),
            (_optTestId == 4)
                ? GestureDetector(
                    onTap: () {
                      _launchURL(videoUrl2!);
                    },
                    child: Text(
                      'Click Here To Watch Instruction Video'.tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          decoration: TextDecoration.underline,
                          color: Colors.black),
                    ),
                  )
                : Container(),
            const SizedBox(height: 60),
          ],
        ),
      ],
    );
  }

  _generalTacDisplay() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'TAC Number'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 20),
              ),
            )),
          ],
        ),
        Card(
          color: const Color.fromARGB(255, 0, 57, 104),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 45 / 100,
            height: 150,
            alignment: Alignment.center,
            child: Text(
              (tac != null) ? tac : "",
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 35,
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  _videoDisplay() {
    return Column(
      children: [
        _divider('Self-Test Video'.tr),
        Container(
          color: CupertinoColors.white,
          child: Card(
            color: CupertinoTheme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  _launchURL(preVideo!);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    children: const [
                      Icon(
                        CupertinoIcons.camera_viewfinder,
                        size: 40,
                        color: CupertinoColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _imageInput() {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width * 45 / 100,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: (imageController != null)
              ? Colors.white
              : const Color.fromARGB(255, 0, 57, 104),
          border: Border.all(color: Colors.white),
        ),
        child: TestKitInput(
          label: '',
          controller: imageController,
          optTestId: _optTestId,
        ),
      ),
    );
  }

  _imageDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _divider((validationType != 1)
            ? 'Upload Result Image'.tr
            : 'Upload Result'.tr),
      ],
    );
  }

  _pocSelect() {
    return GestureDetector(
      onTap: () {
        _selectPoc();
      },
      child: Card(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          alignment: Alignment.center,
          child: const Icon(
            CupertinoIcons.building_2_fill,
            size: 40,
          ),
        ),
      ),
    );
  }

  _pocDisplay(double price) {
    return GestureDetector(
      onTap: () {
        _selectPoc();
      },
      child: Card(
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.storefront,
                        size: 20,
                        color: CupertinoTheme.of(context).primaryColor),
                    Container(
                      width: MediaQuery.of(context).size.width - 120,
                      padding: const EdgeInsets.only(top: 2, left: 6),
                      child: Text(
                        (_poc.name != null) ? _poc.name! : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _selectPoc(),
                          child: Container(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Change'.tr,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12,
                                    color: CupertinoTheme.of(context)
                                        .primaryColor)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: CupertinoColors.white,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(CupertinoIcons.location,
                                size: 20,
                                color: CupertinoTheme.of(context).primaryColor),
                          ),
                          Text((_poc.address != null) ? _poc.address! : '',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: CupertinoColors.white,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(CupertinoIcons.money_dollar,
                                size: 20,
                                color: CupertinoTheme.of(context).primaryColor),
                          ),
                          Text(
                            MainConfig.CURRENCY + _formatter.format(price),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _selfTestForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          (widget.method != 1)
              ? Column(
                  children: [
                    _divider('Self-Test Kit Brand'.tr),
                    GestureDetector(
                      onTap: () {
                        _showPickerBrand();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: const BoxDecoration(
                          color: CupertinoColors.white,
                          border: Border(
                            bottom:
                                BorderSide(color: CupertinoColors.systemGrey5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Answer'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Visibility(
                                  visible: (brand == ''),
                                  replacement: Container(
                                    width: 10,
                                  ),
                                  child: Row(
                                    children: const [
                                      SizedBox(width: 2),
                                      Icon(
                                        CupertinoIcons
                                            .exclamationmark_circle_fill,
                                        size: 6,
                                        color: CupertinoColors.systemRed,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 40),
                                child: Text(brand,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                              child: Icon(CupertinoIcons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _divider('Self-Test Kit Type'.tr),
                    GestureDetector(
                      onTap: () {
                        _showTypePicker();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: const BoxDecoration(
                          color: CupertinoColors.white,
                          border: Border(
                            bottom:
                                BorderSide(color: CupertinoColors.systemGrey5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Answer'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Visibility(
                                  visible: (typeName == ''),
                                  replacement: Container(
                                    width: 10,
                                  ),
                                  child: Row(
                                    children: const [
                                      SizedBox(width: 2),
                                      Icon(
                                        CupertinoIcons
                                            .exclamationmark_circle_fill,
                                        size: 6,
                                        color: CupertinoColors.systemRed,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 40),
                                child: Text(typeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                              child: Icon(CupertinoIcons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          (_optTestId == 4)
              ? Column(
                  children: [
                    _divider('Specimen Type'.tr),
                    GestureDetector(
                      onTap: () {
                        _showSpecimenTypePicker();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: const BoxDecoration(
                          color: CupertinoColors.white,
                          border: Border(
                            bottom:
                                BorderSide(color: CupertinoColors.systemGrey5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Answer'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Visibility(
                                  visible: (specimenTypeName == ''),
                                  replacement: Container(
                                    width: 10,
                                  ),
                                  child: Row(
                                    children: const [
                                      SizedBox(width: 2),
                                      Icon(
                                        CupertinoIcons
                                            .exclamationmark_circle_fill,
                                        size: 6,
                                        color: CupertinoColors.systemRed,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 40),
                                child: Text(specimenTypeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                              child: Icon(CupertinoIcons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          _divider('Self-Test Kit Obtained From'.tr),
          GestureDetector(
            onTap: () {
              _showPickerTestKitObtained();
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Answer'.tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: (kitObtained == null),
                        replacement: Container(
                          width: 10,
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 2),
                            Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              size: 6,
                              color: CupertinoColors.systemRed,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text(
                          (surveyController.text != '')
                              ? kitObtained + ' - ' + surveyController.text
                              : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                    child: Icon(CupertinoIcons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          _divider('Current Details'.tr),
          TextInput(
            label: 'Name'.tr,
            prefixWidth: 80,
            controller: nameController,
            maxLength: 255,
            required: true,
          ),
          TextInput(
            label: 'Email'.tr,
            prefixWidth: 80,
            controller: emailController,
            maxLength: 255,
            required: true,
          ),
          Visibility(
            visible: _udList != null,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                //_showPickerState();
                if (dependName == "") {
                  _showPickerDependant();
                } else {
                  setState(() {
                    dependName = "";
                    dependant_id = 0;
                  });
                }
              },
              child: Column(
                children: [
                  _divider('Dependant(Optional)'.tr),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border(
                        bottom: BorderSide(color: CupertinoColors.systemGrey5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Dependant'.tr,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 40),
                            child: Text((dependName != "") ? dependName : '',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        (dependName == "")
                            ? const SizedBox(
                                width: 12,
                                child: Icon(CupertinoIcons.chevron_right),
                              )
                            : const SizedBox(
                                width: 12,
                                child: Icon(CupertinoIcons.xmark),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _divider('Current Location'.tr),
          TextInput(
            label: 'Street 1'.tr,
            controller: address1Controller,
            prefixWidth: 80,
            maxLength: 255,
            required: true,
          ),
          TextInput(
            label: 'Street 2'.tr,
            controller: address2Controller,
            prefixWidth: 80,
            maxLength: 255,
            required: false,
          ),
          TextInput(
            label: 'Postcode'.tr,
            controller: postcodeController,
            prefixWidth: 80,
            maxLength: 255,
            type: 'phoneNo',
            required: true,
          ),
          TextInput(
            label: 'City'.tr,
            controller: cityController,
            prefixWidth: 80,
            maxLength: 255,
            required: true,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _showStatePicker();
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'State'.tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: (stateName == null),
                        replacement: Container(
                          width: 10,
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 2),
                            Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              size: 6,
                              color: CupertinoColors.systemRed,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text((stateName != null) ? stateName! : '',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                    child: Icon(CupertinoIcons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  showAlertDialogInfo(BuildContext context, int optTest_id) {
    // set up the buttons
    // ignore: deprecated_member_use,
    Widget cancelButton = CupertinoButton(
      onPressed: () {},
      child: Container(),
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text('Continue'.tr),
      onPressed: () {
        Navigator.pop(context);
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
                    'Please take the picture with good lighting condition,background should not be white, and place the test-kit within the box provided.\n'
                        .tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Montserrat',
                      color: Color.fromARGB(255, 104, 104, 104),
                    ),
                  ),
                  Text(
                    'Click the image on the right to submit'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Montserrat',
                      color: Color.fromARGB(255, 104, 104, 104),
                    ),
                  ),
                  Divider(
                    height: 20,
                    thickness: 2,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                  Container(
                    child: Image.asset(
                      (optTest_id == 6)
                          ? "assets/images/raycus-test-kit-example.jpeg"
                          : "assets/images/self-test-kit-sample.png",
                      height: MediaQuery.of(context).size.height * 40 / 100,
                    ),
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
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _submitButton() {
    return Container(
      padding: const EdgeInsets.all(25),
      child: SizedBox(
        width: double.infinity,
        height: 36,
        child: CupertinoButton(
          color: CupertinoTheme.of(context).primaryColor,
          disabledColor: CupertinoColors.inactiveGray,
          padding: EdgeInsets.zero,
          onPressed: () {
            if (galleryFile != null) {
              convertImage();
            }
            _submitForm(context);
          },
          child: Text('Confirm'.tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  void convertImage() {
    final bytes = galleryFile!.readAsBytesSync();
    image = base64Encode(bytes);
  }

  _showPickerTestKitObtained() {
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
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    child: Text(
                      'Confirm'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 104, 104, 104),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        kitObtained = kitObtainedList![kitObtainedNumber]
                            .answer
                            .toString();
                        question_id =
                            kitObtainedList![kitObtainedNumber].question_id;
                        answer_id =
                            kitObtainedList![kitObtainedNumber].answer_id;
                        surveyController.text = '';
                      });
                      Navigator.of(context).pop();
                      _showPickerTestKitObtainedInput(); // closing showCupertinoModalPopup
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
                scrollController:
                    FixedExtentScrollController(initialItem: kitObtainedNumber),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    kitObtainedNumber = value;
                  });
                },
                itemExtent: 32.0,
                children: [
                  for (var id
                      in kitObtainedList!.where((id) => id.is_deleted == 0))
                    Text(
                      id.answer.toString(),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
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

  _showPickerTestKitObtainedInput() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Text(
                        'Cancel'.tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          kitObtained = '';
                          question_id = null;
                          answer_id = null;
                        });
                        Navigator.of(context)
                            .pop(); // closing showCupertinoModalPopup
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                    ),
                    CupertinoButton(
                      child: Text('Confirm'.tr),
                      onPressed: () {
                        if (surveyController.text != '') {
                          Navigator.of(context).pop();
                        } else {
                          Toast.show(context, 'danger',
                              'Please input ' + kitObtained + ' name');
                        } // closing showCupertinoModalPopup
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 50 / 100,
                alignment: Alignment.topCenter,
                child: TextInput(
                  label: 'Answer',
                  placeHolder: 'Please input '.tr + kitObtained + ' name'.tr,
                  prefixWidth: 80,
                  controller: surveyController,
                  maxLength: 255,
                  required: true,
                  autoFocus: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _showPickerBrand() {
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
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () {
                      setState(() {
                        brand = brandList![brandNumber].answer.toString();
                        question_id2 = brandList![brandNumber].question_id;
                        answer_id2 = brandList![brandNumber].answer_id;
                        surveyController2.text = '';
                      });
                      Navigator.of(context).pop();
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: brandNumber),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    brandNumber = value;
                  });
                },
                itemExtent: 32.0,
                children: [
                  for (var id in brandList!.where((id) => id.is_deleted == 0))
                    Text(
                      id.answer.toString(),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
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

  showAlertDialogSkipAI(BuildContext context) {
    Widget cancelButton = CupertinoButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text('Cancel'.tr),
    );
    Widget continueButton = CupertinoButton(
      child: Text('Skip AI verification'.tr),
      onPressed: () {
        if (mounted) {
          setState(() {
            AISkip = true;
          });
        }
        _submitForm(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(
        'Info'.tr,
        style: const TextStyle(
            fontFamily: 'Montserrat', fontWeight: FontWeight.w300),
      ),
      content: Text(
        'It seems our AI system having hard time detecting your self-test kit result, skip AI for manual verification?'
            .tr,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontFamily: 'Montserrat',
          color: Color.fromARGB(255, 104, 104, 104),
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showSpecimenTypePicker() {
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
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () {
                      setState(() {
                        specimenTypeCode =
                            _specimenTypeList[specimenTypeIndex]['id'];
                        specimenTypeName =
                            _specimenTypeList[specimenTypeIndex]['name'];
                      });
                      Navigator.of(context).pop();
                      return; // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: specimenTypeIndex),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    specimenTypeIndex = value;
                  });
                },
                itemExtent: 32.0,
                children: [
                  for (var state in _specimenTypeList)
                    Text(
                      state['name'],
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
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

  _showTypePicker() {
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
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () {
                      setState(() {
                        typeID = type![typeIndex]['id'];
                        typeName = type![typeIndex]['name'];
                      });
                      Navigator.of(context).pop();
                      return; // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: typeIndex),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    typeIndex = value;
                  });
                },
                itemExtent: 32.0,
                children: [
                  for (var types in type!)
                    Text(
                      types['name'],
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
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

  _showStatePicker() {
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
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () {
                      setState(() {
                        _stateCode = _csList![_pickerIndex].code;
                        stateName = _csList![_pickerIndex].name;
                        stateIndex = _csList![_pickerIndex].index;
                      });
                      Navigator.of(context).pop();
                      return; // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
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
                children: [
                  for (var state in _csList!)
                    Text(
                      state.name,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
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

  _showPickerDependant() {
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
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () {
                      setState(() {
                        dependName = _udList[_pickerIndex2].name!;
                        dependant_id = _dependantList![_pickerIndex2]['id'];
                        depend = true;
                      });
                      Navigator.of(context).pop();
                      return; // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: _pickerIndex2),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _pickerIndex2 = value;
                    });
                  }
                },
                itemExtent: 32.0,
                children: [
                  for (var dependant in _udList)
                    Text(
                      dependant.name.toString(),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
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

  Future<void> _selectPoc() async {
    if (widget.method != 0 && widget.validationType == 1) {
      var poc = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PocSelectScreen(
              testType:(_qrCapture['type'] is int) ? _qrCapture['type'] : int.parse(_qrCapture['type']),
              mode: 2,
              validationType: validationType,
            ),
            settings: RouteSettings(arguments: _poc.id),
          ));
      if (poc != null) {
        if (mounted) {
          setState(() {
            _poc = poc;
          });
        }
      }
    } else if (widget.method != 0 && widget.validationType == 0) {
      var poc = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PocSelectScreen(
              testType: int.parse(_qrCapture['type']),
              mode: 2,
              validationType: validationType,
            ),
            settings: RouteSettings(arguments: _poc.id),
          ));
      if (poc != null) {
        if (mounted) {
          setState(() {
            _poc = poc;
          });
        }
      }
    } else {
      var poc = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PocSelectScreen(
              testType: 21,
              mode: 2,
              validationType: validationType,
            ),
            settings: RouteSettings(arguments: _poc.id),
          ));
      if (poc != null) {
        if (mounted) {
          setState(() {
            _poc = poc;
          });
        }
      }
    }
  }

  showLoading(BuildContext context) {
    // set up the AlertDialog
    Widget load = Container(
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 1.5,
              ),
              Text(
                "Please wait".tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ));
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return load;
      },
    );
  }

  showAlertDialogVideo(BuildContext context) {
    Widget cancelButton = CupertinoButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text('Cancel'.tr),
    );
    Widget continueButton = CupertinoButton(
      onPressed: () {
        if (mounted) {
          setState(() {
            _preSubmit(context);
          });
        }
      },
      child: Text('Continue'.tr),
    );
    // set up the AlertDialog
    Widget alert = Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              'Alert'.tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            content: Text(
              'Continue with the current recorded self-test video?'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 104, 104, 104),
              ),
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

  _showAISKip() {
    if (getAISkip > 1) {
      showAlertDialogSkipAI(context);
    }
  }

  showAlertDialogProfileComplete(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      onPressed: () {},
      child: Container(),
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text('Continue'.tr),
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
        'Please verify your IC/Passport to continue'.tr,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontFamily: 'Montserrat',
          color: Color.fromARGB(255, 104, 104, 104),
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

  void assignVideoUrl() {
    switch (_optTestId) {
      case 4:
        videoUrl2 = 'https://www.youtube.com/watch?v=B3JM6qgHZxA';
        videoUri2 = Uri.parse('https://www.youtube.com/watch?v=B3JM6qgHZxA');
        break;
      case 6:
        videoUrl2 = 'http://www.raycusbio.com/tt';
        break;
      default:
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<List<Poc>?> _fetchPocs() async {
    final webService = WebService(context);
    int _page = 0;
    int _pageCount = 1;
    if (_page < _pageCount) {
      _page++;
      webService.setEndpoint('screening/pocs').setPage(_page);
      Map<String, String> filter = {};
      if (widget.method == 1 && widget.validationType == 0) {
        filter.addAll({'test_type': _qrCapture['type'].toString()});
        filter.addAll({'mode': 2.toString()});
      } else if (widget.method == 1 && widget.validationType == 1) {
        filter.addAll({'test_type': _qrCapture['type'].toString()});
        filter.addAll({'mode': 2.toString()});
      } else {
        if (widget.validationType == 1) {
          filter.addAll({'is_general_report': 0.toString()});
          filter.addAll({'is_e_report': 0.toString()});
          filter.addAll({'test_type': 21.toString()});
          filter.addAll({'mode': 2.toString()});
        } else if (widget.validationType == 0) {
          filter.addAll({'test_type': 21.toString()});
          filter.addAll({'mode': 2.toString()});
        }
      }
      var response = await webService.setFilter(filter).send();
      if (response == null) return null;
      if (response.status) {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<Poc> pocs =
            parseList.map<Poc>((json) => Poc.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            if (widget.validationType == 0) {
              _list.addAll(
                  pocs.where((e) => e.name!.contains('General Validation')));
            } else {
              _list.addAll(pocs);
            }

            if (_list.isNotEmpty) {
              _poc = _list[0];
            }
          });
        }
      }
    }
    return _list;
  }

  Future<List<CountryState>?> _fetchCS() async {
    final webService = WebService(context);
    if (!_isLoadingCS) {
      _isLoadingCS = true;
      webService.setEndpoint('option/list/address-state');
      var response = await webService.send();
      if (response == null) return null;
      if (response.status) {
        final parseList2 =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<CountryState> states = parseList2
            .map<CountryState>((json) => CountryState.fromJson(json))
            .toList();
        if (mounted) {
          setState(() {
            _csList!.addAll(states);
          });
        }
      }
    }
    _isLoadingCS = false;
    return _csList;
  }

  Future<List?> _fetchType() async {
    final webService = WebService(context);
    webService.setEndpoint('option/self-test/type');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList3 =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      type = parseList3;
    }
    return type;
  }

  // ignore: missing_return
  Future<List<Survey>?> _fetchAnswers(
      int refNo, var answers, var question) async {
    var fetchQuestionAnswer;
    fetchQuestionAnswer = await SelfTest.fetchAnswers(context, refNo);
    if (mounted) {
      setState(() {
        answers = fetchQuestionAnswer['answer_options'];
        question = fetchQuestionAnswer['question'];
      });
    }
    List<Survey> surveyAnswers =
        answers.map<Survey>((json) => Survey.fromJson(json)).toList();
    if (mounted) {
      setState(() {
        int index;
        kitObtainedList!.addAll(surveyAnswers);
        surveyController.text = 'Teda Wellness';
        index =
            kitObtainedList!.indexWhere((e) => e.answer!.contains('Corporate'));
        question_id = kitObtainedList![index].question_id;
        answer_id = kitObtainedList![index].answer_id;
        kitObtained = kitObtainedList![index].answer!;
      });
    }
  }

  Future<void> _populateForm() async {
    prefs = await SharedPreferences.getInstance();
    User? user = await User.fetchOne(context);
    if (user != null) {
      _csList = await _fetchCS();
      if (mounted) {
        setState(() {
          nameController.text = ((user.name != null) ? user.name : '')!;
          emailController.text = ((user.email != null) ? user.email : '')!;
          _stateCode = (user.state != null) ? user.state! : '';
          for (var variable in _csList!) {
            if (variable.code == _stateCode) {
              stateIndex = variable.index;
              stateName = variable.name;
              break;
            }
          }
          _pickerIndex = ((stateIndex != null) ? stateIndex : 0)!;
          address1Controller.text = user.address1!;
          address2Controller.text = user.address2!;
          postcodeController.text = user.postcode!;
          cityController.text = user.city!;
        });
      }
    }
  }

  Future<List<Survey>?> _fetchAnswers2(
      int refNo, var answers2, var question2) async {
    var fetchQuestionAnswer2;
    fetchQuestionAnswer2 = await SelfTest.fetchAnswers(context, 2);
    if (mounted) {
      setState(() {
        answers2 = fetchQuestionAnswer2['answer_options'];
        question2 = fetchQuestionAnswer2['question'];
      });
    }
    List<Survey> surveyAnswers2 =
        answers2.map<Survey>((json) => Survey.fromJson(json)).toList();
    if (mounted) {
      setState(() {
        int index = 0;
        brandList!.addAll(surveyAnswers2);
        question_id2 = brandList![index].question_id;
        answer_id2 = brandList![index].answer_id;
      });
    }
  }

  Future<void> _preSubmit(BuildContext context) async {
    SelfTest selfTest = SelfTest();
    Test test = Test();
    Response? response;
    final GlobalKey progressDialogKey = GlobalKey<State>();
    if (mounted) {
      setState(() {
        selfTest.id = test_id;
        selfTest.brand_id = _optTestId;
        selfTest.qrCode =
            (_qrCapture['qrcode'] != null) ? _qrCapture['qrcode'] : null;
        selfTest.video = videoController.text;
      });
    }
    List<String> errors = SelfTest.preValidate(selfTest, validationType);
    if ((_optTestId != null) && (errors.isEmpty)) {
      ProgressDialog.show(context, progressDialogKey);
      response = await SelfTest.preCreate(context, selfTest);
      ProgressDialog.hide(progressDialogKey);
      if (response!.status) {
        var array = jsonDecode(response.body.toString());
        var testId = array[0]["id"];
        global.updateTestScreen = true;
        if (cont == false) {
          if (mounted) {
            setState(() {
              test_id = testId;
            });
          }
        }
        Toast.show(context, 'default', 'Record created.');
        Navigator.of(context).pop();
        startTimerCountdown();
      }
    }
    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    SelfTest selfTest = SelfTest();
    if (mounted) {
      setState(() {
        selfTest.id = widget.test_id;
        selfTest.poc_id = (_poc != null) ? _poc.id : null;
        selfTest.id = (validationType != 0) ? test_id : null;
        selfTest.brand_id = _optTestId;
        selfTest.price = _poc.price;
        selfTest.qrCode = _qrCapture['qrcode'];
        selfTest.image = imageController.text;
        selfTest.name = nameController.text;
        selfTest.email = emailController.text;
        selfTest.address1 = address1Controller.text;
        selfTest.address2 = address2Controller.text;
        selfTest.postcode = postcodeController.text;
        selfTest.city = cityController.text;
        selfTest.state = _stateCode;
        selfTest.country = 'my';
        selfTest.question_id = question_id;
        selfTest.answer_id = answer_id;
        selfTest.question_id2 = question_id2;
        selfTest.answer_id2 = answer_id2;
        selfTest.latitude = latitude;
        selfTest.longitude = longitude;
        selfTest.answer_description = surveyController.text;
        selfTest.specimen = specimenTypeCode;
        selfTest.use_credit = 0;
        selfTest.dependant_id = dependant_id;
        selfTest.tac_code = tac;
        selfTest.video = videoController.text;
      });
    }
    if (validationType == 1 && widget.method == 1) {
      List<String> errors = SelfTest.validate(selfTest, validationType);
      if ((_optTestId != null) && (errors.isEmpty)) {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return CheckoutScreen(
            id: test_id!,
            poc: _poc,
            type: (_qrCapture['type'].runtimeType == int)
                ? _qrCapture['type']
                : int.tryParse(_qrCapture['type'].toString()),
            brand_id: _optTestId,
            originalPrice: (_poc != null) ? _poc.price : '0',
            image: imageController.text,
            qrCapture: _qrCapture['qrcode'],
            name: nameController.text,
            email: emailController.text,
            address1: address1Controller.text,
            address2: address2Controller.text,
            postcode: postcodeController.text,
            city: cityController.text,
            state: _stateCode,
            country: 'my',
            selfTest: selfTest,
            validationType: validationType,
            dependant_id: dependant_id,
          );
        }));
      }
      if (errors.isNotEmpty) {
        Toast.show(context, 'danger', errors[0]);
      }
    } else if (widget.method == 1 && validationType == 0) {
      if (mounted) {
        setState(() {
          selfTest.image = imageController.text;
          selfTest.qrCode = _qrCapture['qrcode'];
          selfTest.brand_id = _optTestId;
          selfTest.specimen = specimenTypeCode;
          selfTest.price = '0';
          selfTest.verify = 1;
          selfTest.poc_id = (_poc != null) ? _poc.id : null;
          selfTest.originalPrice = (_poc != null) ? _poc.price : '0';
          selfTest.name = nameController.text;
          selfTest.email = emailController.text;
          selfTest.address1 = address1Controller.text;
          selfTest.address2 = address2Controller.text;
          selfTest.postcode = postcodeController.text;
          selfTest.city = cityController.text;
          selfTest.state = _stateCode;
          selfTest.country = 'my';
          selfTest.question_id = question_id;
          selfTest.answer_id = answer_id;
          selfTest.answer_description = surveyController.text;
          selfTest.AI_skip = AISkip;
          selfTest.specimen = specimenTypeCode;
          selfTest.use_credit = 0;
          selfTest.dependant_id = dependant_id;
        });
      }
      List<String> errors = SelfTest.validate(selfTest, validationType);
      if ((_optTestId != null) && (errors.isEmpty)) {
        final GlobalKey progressDialogKey = GlobalKey<State>();
        Response? response;
        if (AISkip == true) {
          ProgressDialog.show(context, progressDialogKey);
          response = await SelfTest.create(context, selfTest);
          ProgressDialog.hide(progressDialogKey);
        } else {
          ProgressDialog.show(context, progressDialogKey);
          response = await SelfTest.create(context, selfTest);
          ProgressDialog.hide(progressDialogKey);
        }
        if (response!.status) {
          var array = jsonDecode(response.body.toString());
          var testId = array[0]["id"];
          var ai_result = array[0]['ai_result'];
          prefs!.setInt(keyShowAISkip, 0);
          global.updateTestScreen = true;
          if (!AISkip) {
            Toast.show(context, 'default', 'Result verified');
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return SelfTestResultConfirmation(
                selfTest: selfTest,
                ai_result: ai_result,
                test_id: testId,
                fromHistory: false,
              );
            }));
          } else {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context, true);
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return TransferDetails(
                testID: testId,
              );
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
        if (!errors[0].contains('QR')) {
          if (prefs!.getInt(keyShowAISkip) != null) {
            getAISkip = prefs!.getInt(keyShowAISkip)!;
          }
          prefs!.setInt(keyShowAISkip, getAISkip + 1);
          _showAISKip();
        }
      }
    } else if (widget.method == 0 && validationType == 0) {
      setState(() {
        selfTest.id = test_id;
        selfTest.qrCode = null;
        selfTest.type = 21;
        selfTest.image = imageController.text;
        selfTest.brand_id = _optTestId;
        selfTest.specimen = specimenTypeCode;
        selfTest.verify = 1;
        selfTest.poc_id = (_poc != null) ? _poc.id : null;
        selfTest.price = _poc.price;
        selfTest.originalPrice = _poc.price;
        selfTest.name = nameController.text;
        selfTest.email = emailController.text;
        selfTest.address1 = address1Controller.text;
        selfTest.address2 = address2Controller.text;
        selfTest.postcode = postcodeController.text;
        selfTest.city = cityController.text;
        selfTest.state = _stateCode;
        selfTest.country = 'my';
        selfTest.question_id = question_id;
        selfTest.answer_id = answer_id;
        selfTest.answer_description = surveyController.text;
        selfTest.question_id2 = question_id2;
        selfTest.answer_id2 = answer_id2;
        selfTest.specimen = specimenTypeCode;
        selfTest.use_credit = 0;
        selfTest.dependant_id = dependant_id;
        selfTest.video = preVideo;
      });
      List<String> errors = SelfTest.validate(selfTest, validationType);
      if ((_optTestId != null) && (errors.isEmpty)) {
        final GlobalKey progressDialogKey = GlobalKey<State>();
        Response? response;
        ProgressDialog.show(context, progressDialogKey);
        response = await SelfTest.create(context, selfTest);
        ProgressDialog.hide(progressDialogKey);
        if (response!.status) {
          var array = jsonDecode(response.body.toString());
          var testId = array[0]["id"];
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return TransferDetails(
              testID: testId,
            );
          }));
        } else if (response.error.isNotEmpty) {
          errors.add(response.error.values.toList()[0]);
        } else {
          errors.add('Server connection timeout.');
        }
      }
      if (errors.isNotEmpty) {
        Toast.show(context, 'danger', errors[0]);
      }
    } else if (widget.method == 0 && validationType == 1) {
      setState(() {
        selfTest.id = test_id;
        selfTest.image = imageController.text;
        selfTest.type = 21;
        selfTest.qrCode = null;
        selfTest.brand_id = _optTestId;
        selfTest.price = _poc.price;
        selfTest.verify = 1;
        selfTest.type = typeID;
        selfTest.poc_id = _poc.id;
        selfTest.originalPrice = _poc.price;
        selfTest.name = nameController.text;
        selfTest.email = emailController.text;
        selfTest.address1 = address1Controller.text;
        selfTest.address2 = address2Controller.text;
        selfTest.postcode = postcodeController.text;
        selfTest.city = cityController.text;
        selfTest.state = _stateCode;
        selfTest.country = 'my';
        selfTest.question_id = question_id;
        selfTest.answer_id = answer_id;
        selfTest.answer_description = surveyController.text;
        selfTest.question_id2 = question_id2;
        selfTest.answer_id2 = answer_id2;
        selfTest.specimen = specimenTypeCode;
        selfTest.use_credit = 0;
        selfTest.dependant_id = dependant_id;
      });
      List<String> errors = SelfTest.validate(selfTest, validationType);
      if ((_optTestId != null) && (errors.isEmpty)) {
        final GlobalKey progressDialogKey = GlobalKey<State>();
        Response? response;
        ProgressDialog.show(context, progressDialogKey);
        response = await SelfTest.create(context, selfTest);
        ProgressDialog.hide(progressDialogKey);
        if (response!.status) {
          var array = jsonDecode(response.body.toString());
          var testId = array[0]["id"];
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return TransferDetails(
              testID: testId,
            );
          }));
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
}
