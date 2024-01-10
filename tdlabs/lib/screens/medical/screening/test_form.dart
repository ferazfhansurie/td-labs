// ignore_for_file: prefer_final_fields, must_be_immutable, avoid_unnecessary_containers, unnecessary_null_comparison, curly_braces_in_flow_control_structures, library_prefixes, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:tdlabs/models/screening/test.dart';
import 'package:tdlabs/models/time_session.dart';
import 'package:tdlabs/models/user/user-dependant.dart';
import 'package:tdlabs/screens/checkout/checkout.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:get/get.dart' as Get;

import '../others/poc_select.dart';

class TestFormScreen extends StatefulWidget {
  int? optTestId;
  String? optTestName;
  Poc? poc;
  double? price;
  bool? travel;
  TestFormScreen(
      {Key? key,
      this.optTestId,
      this.optTestName,
      this.poc,
      this.price,
      this.travel})
      : super(key: key);
  @override
  _TestFormScreenState createState() => _TestFormScreenState();
}

class _TestFormScreenState extends State<TestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  late Poc _poc;
  int? _optTestId;
  NumberFormat _formatter = NumberFormat(',##0.00');
  bool _isLoading = false;
  List<TimeSession> _list = [];
  int _pickerIndex = 0;
  int _pickerIndex2 = 0;
  int? _sessionId;
  String _sessionName = '';
  int testMode = 0;
  String? testModeName;
  DateTime? _selectedDate;
  String _selectedText = '';
  String dependName = "";
  List<UserDependant> _udList = [];
  bool depend = false;
  List<dynamic>? _dependantList;
  int dependant_id = 0;
  @override
  void initState() {
    _poc = Poc();
    if (widget.poc != null) {
      _poc = widget.poc!;
    }
    super.initState();
    _fetchTS();
    _fetchUD();
    testModeName = widget.optTestName;
  }


  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    _optTestId = widget.optTestId;
    double price = (_poc.price != null) ? double.parse(_poc.price!) : 0;
    if (widget.price != null) {
      price = widget.price!;
      _poc.price = widget.price.toString();
    }
    return CupertinoPageScaffold(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Background-01.png"),
                    fit: BoxFit.fill),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
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
                                  size: 35,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "E-Booking".tr,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const Spacer()
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _testFormDisplay(price),
                      _submitButton()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  _testFormDisplay(double price) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
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
        child: Column(
          children: [
            GestureDetector(
              child: Container(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Type of Appointment: '.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          testModeName!.tr,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
            GestureDetector(
              onTap: () {
                if (widget.travel == false) _selectPoc();
              },
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('Point of Care: '.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600)),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.storefront,
                                size: 20,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 120,
                                padding: const EdgeInsets.only(top: 2, left: 6),
                                child: Text(
                                  (_poc.name != null) ? _poc.name! : '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w300,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: CupertinoColors.white,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Column(
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      CupertinoIcons.location,
                                      size: 20,
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
                                    ),
                                  ),
                                  Text((_poc.address != null)
                                      ? _poc.address!
                                      : ''),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
            Container(
              color: CupertinoColors.white,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Price:'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600)),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            CupertinoIcons.money_dollar,
                            size: 20,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        ),
                        Text((price != 0.0)
                            ? MainConfig.CURRENCY + _formatter.format(price)
                            : "Free".tr),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
            GestureDetector(
              onTap: () {
                _showPickerDate(context);
              },
              child: Container(
                height: 65,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Date: '.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600)),
                        ),
                        if (_selectedText == "")
                          const Icon(
                            CupertinoIcons.exclamationmark_circle_fill,
                            size: 16,
                            color: CupertinoColors.systemRed,
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            CupertinoIcons.calendar,
                            size: 20,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: Text(_selectedText,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
            GestureDetector(
              onTap: _showPicker,
              child: Container(
                height: 65,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Session: '.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600)),
                        ),
                        if (_sessionName == "")
                          const Icon(
                            CupertinoIcons.exclamationmark_circle_fill,
                            size: 16,
                            color: CupertinoColors.systemRed,
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            CupertinoIcons.clock,
                            size: 20,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: Text(_sessionName.tr,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
            GestureDetector(
              onTap: _showPickerDependant,
              child: Container(
                height: 65,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Dependant(Optional): '.tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            CupertinoIcons.person,
                            size: 20,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: Text(dependName.tr,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        if (dependName != "")
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                depend = false;
                                dependName = "";
                              });
                            },
                            child: Container(
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                CupertinoIcons.clear,
                                size: 20,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _submitButton() {
    return Align(
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
              _submitForm(context);
            },
            child: Text('Submit'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.w300)),
          ),
        ),
      ),
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

  _showPicker() {
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
                        _sessionId = _list[_pickerIndex].id;
                        _sessionName = _list[_pickerIndex].name!;
                      });
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
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
                  for (var session in _list)
                    Text(
                      session.name!.tr,
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


  void _showPickerDate(BuildContext context) async {
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();
    DateTime addStart = start.add(const Duration(days: 0));
    DateTime addEnd = end.add(const Duration(days: 7));
    DateTime startDate =
        DateTime(addStart.year, addStart.month, addStart.day, 0, 0, 0);
    DateTime endDate =
        DateTime(addEnd.year, addEnd.month, addEnd.day, 23, 59, 59);
    final DateTime? picked = await showDatePicker(
      locale: Get.Get.locale,
      context: context,
      initialDate: (_selectedDate != null) ? _selectedDate! : startDate,
      firstDate: startDate,
      lastDate: endDate,
      builder: (BuildContext? context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: CupertinoColors.activeBlue,

            colorScheme:
                const ColorScheme.light(primary: CupertinoColors.activeBlue),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if ((picked != null) && (picked != _selectedDate)) {
      setState(() {
        _selectedDate = picked;
        _selectedText =
            DateFormat('dd/MM/yyyy').format(_selectedDate!.toLocal());
      });
    }
    _dateController.text = _selectedDate!.toLocal().toString().split(' ')[0];
  }

  Future<void> _selectPoc() async {
    var poc = await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => PocSelectScreen(
            ebook: true,
            testType: _optTestId,
            mode: testMode,
          ),
          settings: RouteSettings(arguments: _poc.id),
        ));
    if (poc != null) {
      setState(() {
        _poc = poc;
      });
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    Test test = Test();
    test.poc_id = (_poc != null) ? _poc.id : null;
    test.type = _optTestId;
    test.timeSession = _sessionId;
    test.price = (_poc != null) ? _poc.price : '0';
    test.mode = testMode;
    if (_dateController.text.isNotEmpty) {
      test.appointmentAt = DateTime.parse(_dateController.text);
    }
    List<String> errors = Test.validate(test);
    if ((_optTestId != null) && (errors.isEmpty)) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return CheckoutScreen(
          poc: _poc,
          type: _optTestId,
          timeSessionId: _sessionId,
          timeSessionName: _sessionName,
          originalPrice: (_poc != null) ? _poc.price : '0',
          mode: testMode,
          appointmentAt: DateTime.parse(_dateController.text),
          dependName: dependName,
          dependant_id: dependant_id,
          name: (dependName != "") ? dependName : "",
          testName: widget.optTestName,
        );
      }));
    } else
      errors.add('Server connection timeout.');
    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }

  // list of time session
  Future<List<TimeSession>?> _fetchTS() async {
    final webService = WebService(context);
    if (!_isLoading) {
      _isLoading = true;
      webService.setEndpoint('option/list/time');
      var response = await webService.send();
      if (response == null) return null;
      if (response.status) {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<TimeSession> states = parseList
            .map<TimeSession>((json) => TimeSession.fromJson(json))
            .toList();
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
