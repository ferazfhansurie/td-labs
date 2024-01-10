// ignore_for_file: library_prefixes, must_be_immutable, non_constant_identifier_names, unused_field, prefer_typing_uninitialized_variables, unused_element, body_might_complete_normally_nullable, unnecessary_null_comparison, unnecessary_statements

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/util/country_state.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:tdlabs/models/screening/self-test.dart';
import 'package:tdlabs/models/survey.dart';
import 'package:tdlabs/models/screening/test.dart';
import 'package:tdlabs/models/time_session.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/screens/checkout/checkout.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/form/text_input.dart';
import '../../../utils/toast.dart';
import '../others/poc_select.dart';


class OtherFormScreen extends StatefulWidget {
  int? optTestId;
  int? validationType;
  bool? payed;
  OtherFormScreen({Key? key, this.optTestId, this.payed, this.validationType}): super(key: key);
  @override
  _OtherFormScreenState createState() => _OtherFormScreenState();
}
class _OtherFormScreenState extends State<OtherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final postcodeController = TextEditingController();
  final cityController = TextEditingController();
  final imageController = TextEditingController();
  final surveyController = TextEditingController();
  late Poc _poc;
  SharedPreferences? prefs;
  int? test_id;
  int? _optTestId;
  final NumberFormat _formatter = NumberFormat(',##0.00');
  bool _isLoading = false;
  final List<TimeSession> _list = [];
  final List<Poc> _listPoc = [];
  int _pickerIndex = 0;
  int? _sessionId;
  final String _sessionName = '';
  int testMode = 0;
  final List<String> _listMode = ['Walk-In', 'Drive-Thru'];
  List<CountryState>? _csList = [];
  String? testModeName;
  DateTime? _selectedDate;
  final String _selectedText = '';
  bool _isLoadingCS = false;
  String _stateCode = '';
  int? stateIndex;
  String? stateName;
  int? validationType;
  bool payed = false;
  int kitObtainedNumber = 0;
  List<Survey>? kitObtainedList = [];
  String kitObtained = '';
  int? answer_id;
  int? question_id;
  String latitude = '';
  String longitude = '';
  final List<Map<String, dynamic>> _specimenTypeList = [
    {'id': 2, 'name': 'Saliva'},
    {'id': 4, 'name': 'Nasal'}
  ];
  String specimenTypeName = '';
  int specimenTypeIndex = 0;
  int? specimenTypeCode;
  int ref_No = 1;
  var answers;
  var question;
  Test? _test;
  @override
  void initState() {
    validationType = widget.validationType;
    _poc = Poc();
    super.initState();
    _getTest();
    _fetchTS();
    _populateForm();
    testModeName = _listMode[testMode];
    payed = widget.payed!;
    validationType = widget.validationType!;
  }



  @override
  void dispose() {
    _dateController.dispose();
    nameController.dispose();
    emailController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    postcodeController.dispose();
    cityController.dispose();
    //_imageController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _optTestId = widget.optTestId;
    double price = (_poc.price != null) ? double.parse(_poc.price!) : 0;
    return CupertinoPageScaffold(
      child: SingleChildScrollView(
        child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/Background-02.png"),
                  fit: BoxFit.fill),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height + 50,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top,),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 120.0),
                        child: (validationType == 0)
                            ? const Text(
                                "Self-Test",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            : const Text(
                                "SIMKA",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 50 / 100,
                      //color: ThemeColors.blueGreen,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image:AssetImage("assets/images/Background-02.png"),
                            fit: BoxFit.fill),
                      ),
                      child:SingleChildScrollView(child: _otherBrandsForm(price)),
                    ),
                  ],
                ),
              ],
            )),
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
                  fontFamily: 'Montserrat', color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otherBrandsForm(double price) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
            type: 'phoneNo'.tr,
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
          _divider('Point Of Care'.tr),
          Visibility(
            visible: (_poc.price != null),
            replacement: GestureDetector(
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
            ),
            child: Column(
              children: [
                GestureDetector(
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              children: [
                                Icon(Icons.storefront,
                                    size: 20,
                                    color: CupertinoTheme.of(context).primaryColor),
                                Container(
                                  width:MediaQuery.of(context).size.width - 120,
                                  padding:const EdgeInsets.only(top: 2, left: 6),
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
                                                color:CupertinoTheme.of(context).primaryColor)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Column(
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        padding:const EdgeInsets.only(right: 6),
                                        child: Icon(CupertinoIcons.location,
                                            size: 20,
                                            color: CupertinoTheme.of(context).primaryColor),
                                      ),
                                      Text(
                                          (_poc.address != null)
                                              ? _poc.address!
                                              : '',
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Column(
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        padding:const EdgeInsets.only(right: 6),
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                height: 36,
                child: CupertinoButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  disabledColor: CupertinoColors.inactiveGray,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (_poc.name == null) {
                      Toast.show(context, "danger", "Select POC");
                    } else if (emailController.text == null) {
                      Toast.show(context, "danger", "Enter email");
                    } else {
                      _preSubmitForm(context);
                    }
                  },
                  child: Text('Submit'.tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat', color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPoc() async {
    var poc = await Navigator.push(context,
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
                      Navigator.of(context).pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 5.0,),
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
                    FixedExtentScrollController(initialItem: _pickerIndex),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    _pickerIndex = value;
                  });
                },
                itemExtent: 32.0,
                children: [
                  for (var state in _csList!) Text(state.name),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Survey>?> _fetchAnswers(int refNo, var answers, var question) async {
    var fetchQuestionAnswer;
    fetchQuestionAnswer = await SelfTest.fetchAnswers(context, refNo);
    if (mounted) {
      setState(() {
        answers = fetchQuestionAnswer['answer_options'];
        question = fetchQuestionAnswer['question'];
      });
    }
    List<Survey> surveyAnswers =answers.map<Survey>((json) => Survey.fromJson(json)).toList();
    if (mounted) {
      setState(() {
        int index;
        kitObtainedList!.addAll(surveyAnswers);
        surveyController.text = 'Teda Wellness';
        index =kitObtainedList!.indexWhere((e) => e.answer!.contains('Corporate'));
        question_id = kitObtainedList![index].question_id;
        answer_id = kitObtainedList![index].answer_id;
        kitObtained = kitObtainedList![index].answer!;
      });
    }
  }
  Future<List<CountryState>?> _fetchCS() async {
    final webService = WebService(context);
    if (!_isLoadingCS) {
      _isLoadingCS = true;
      webService.setEndpoint('option/list/address-state');
      var response = await webService.send();
      if (response == null) return null;
      if (response.status) {
        final parseList2 =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<CountryState> states = parseList2.map<CountryState>((json) => CountryState.fromJson(json)).toList();
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

  Future<void> _populateForm() async {
    prefs = await SharedPreferences.getInstance();
    User? user = await User.fetchOne(context);
    if (user != null) {
      _csList = await _fetchCS();
      if (mounted) {
        setState(() {
          nameController.text = ((user.name != null) ? user.name : '')!;
          emailController.text = ((user.email != null) ? user.email : '')!;
          _stateCode = user.state!;
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
          // splitStreet(street);
          postcodeController.text = user.postcode!;
          cityController.text = user.city!;
        });
      }
    }
  }

  Future<Test?> _getTest() async {
    final webService = WebService(context);
    // get single test model
    var response = await webService.setEndpoint('screening/tests/' + test_id.toString()).setExpand('poc,user').send();
    if (response == null) return null;
    if (response.status) {
      var modelArray = jsonDecode(response.body.toString());
      _test = Test.fromJson(modelArray);
    }

    return _test;
  }

  Future<void> _preSubmitForm(BuildContext context) async {
    SelfTest selfTest = SelfTest();
    selfTest.id = (test_id != null) ? test_id : null;
    selfTest.poc_id = (_poc != null) ? _poc.id : null;
    selfTest.brand_id = _optTestId;
    selfTest.price = (mounted != null) ? _poc.price : '0';
    selfTest.payment_method = 1;
    selfTest.originalPrice = (_poc != null) ? _poc.price : '0';
    selfTest.voucher_id;
    selfTest.voucher_child;
    selfTest.voucher_code;
    selfTest.use_credit = 0;
    Navigator.pop(context);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return CheckoutScreen(
        poc: _poc,
        type: 21,
        mode: 2,
        brand_id: _optTestId,
        price: (_poc != null) ? _poc.price : '0',
        originalPrice: (_poc != null) ? _poc.price : '0',
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
      );
    }));
  }

  Future<List<TimeSession>?> _fetchTS() async {
    final webService = WebService(context);
    if (!_isLoading) {
      _isLoading = true;
      webService.setEndpoint('option/list/time');
      var response = await webService.send();
      if (response == null) return null;
      if (response.status) {
        final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<TimeSession> states = parseList.map<TimeSession>((json) => TimeSession.fromJson(json)).toList();
        setState(() {
          _list.addAll(states);
        });
      }
    }
    _isLoading = false;
    return _list;
  }
}

class ListItem {
  int value;
  String name;
  ListItem(this.value, this.name);
}
