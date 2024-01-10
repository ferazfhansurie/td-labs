// ignore_for_file: library_prefixes, must_be_immutable, use_key_in_widget_constructors, unused_local_variable, avoid_unnecessary_containers, non_constant_identifier_names, deprecated_member_use, duplicate_ignore

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tdlabs/screens/history/history_screen.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../config/main.dart';
import 'package:email_launcher/email_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:get/get.dart' as Get;
import 'package:permission_handler/permission_handler.dart';
import '../../models/screening/opt_test.dart';
import '../../models/screening/test.dart';
import '../../screens/widget/web_view.dart';
import '../../utils/toast.dart';
import '../../utils/web_service.dart';
import '../util/pdf_view.dart';
import '../webview/inAppWebViewForm.dart';


class PaymentInvoice extends StatefulWidget {
  int? testID;
  String? name;
  PaymentInvoice({this.testID, this.name});
  @override
  _PaymentInvoiceState createState() => _PaymentInvoiceState();
}

class _PaymentInvoiceState extends State<PaymentInvoice> {
  final GlobalKey<SfPdfViewerState> sfPDFViewerKey = GlobalKey();

  Test? _test;
  String _type = '';
  String? _testPdf;
  String? _imageUrl;
  int? _testId;
  String testLocation = '';
  bool _isLoading = true;
  Image? logo;
  Email email = Email(
    to: ['customer@tdlabs.co'],
    cc: [''],
    bcc: [''],
    subject: 'Payment : "INSERT TRANSFER DETAILS"',
    body: '',
  );

  List<String> modeList = ['Walk-In', 'Drive-Thru'];
  bool showGMaps = true;
  String? latitudeCaptured;
  String? longitudeCaptured;
  Color _statusColor = Colors.red;
  String url = '';

  @override
  void initState() {
    super.initState();
    if (MainConfig.modeLive) {
      _getPermission();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    logo = Image.asset('assets/images/TDlogo.png');
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showGMaps = true;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(logo!.image, context);
  }

  @override
  void dispose() {
    //implement dispose
    super.dispose();
  }

  _getPermission() {
    Permission.locationWhenInUse.request();
  }

  void _getLocation() {
    setState(() {
      latitudeCaptured = _test!.latitude;
      longitudeCaptured = _test!.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    _testId = widget.testID;
    Widget _resultWidget;
    Widget _selfTest;

    _selfTest = Container(
      padding: const EdgeInsets.only(left: 5),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
        child: Text(
          'Self-Test'.tr,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );

    if (_isLoading == true) {
      _getContent();
      return CupertinoPageScaffold(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Text('Loading'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: Colors.black87)),
          ),
        ),
      );
    } else {
      if (_test!.resultName == 'Pending') {
        _statusColor = Colors.red.shade700;
        _resultWidget = Container(
          padding: const EdgeInsets.only(left: 5),
          alignment: Alignment.center,
          child: Card(
            color: Colors.red.shade700,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Text(
                _test!.resultName!,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      } else if (_test!.resultName == 'Completed') {
        _statusColor = Colors.green.shade700;
        _resultWidget = Container(
          padding: const EdgeInsets.only(left: 5),
          alignment: Alignment.center,
          child: Card(
            color: _statusColor,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
              child: Text(
                (_test!.other_remark != null)
                    ? _test!.resultName!
                    : 'Verifying'.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      } else if (_test!.resultName == 'Appointment Set') {
        _statusColor = Colors.amber.shade700;
        _resultWidget = Container(
          padding: const EdgeInsets.only(left: 5),
          alignment: Alignment.center,
          child: Card(
            color: _statusColor,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
              child: Text(
                (_test!.other_remark != null)
                    ? _test!.resultName!
                    : 'Verifying'.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      } else if (_test!.resultName == 'Negative') {
        _statusColor = Colors.green.shade700;
        _resultWidget = Container(
          padding: const EdgeInsets.only(left: 5),
          alignment: Alignment.center,
          child: Card(
            color: CupertinoColors.activeGreen,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
              child: Text(
                _test!.resultName!.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      } else if (_test!.resultName == 'Positive') {
        _statusColor = Colors.red.shade700;
        _resultWidget = Container(
          padding: const EdgeInsets.only(left: 5),
          alignment: Alignment.center,
          child: Card(
            color: CupertinoColors.destructiveRed,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
              child: Text(
                _test!.resultName!.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      } else if (_test!.resultName == '') {
        _resultWidget = Container(
          padding: const EdgeInsets.only(left: 5),
          alignment: Alignment.center,
          child: Card(
            color: Colors.blueGrey.shade700,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
              child: Text(
                'Invalid'.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      } else {
        _resultWidget = Container();
      }
      return CupertinoPageScaffold(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Background-01.png"),
                fit: BoxFit.fill),
          ),
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_test!.type! > 10)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: _resultWidget),
                  ),
                if (_test!.type! <= 10)
                  Container(
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 250,
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              'Thank you for booking with TD-Labs'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        CircularPercentIndicator(
                            radius: 40.0,
                            lineWidth: 25.0,
                            percent: 1,
                            animation: true,
                            animationDuration: 1200,
                            center: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: (_test!.resultName == 'Pending')
                                      ? const Icon(Icons.payment,
                                          color: Colors.red, size: 50)
                                      : (_test!.resultName == 'Appointment Set')
                                          ? const Icon(Icons.pending_actions,
                                              color: Colors.amber, size: 50)
                                          : const Icon(Icons.check,
                                              color: Colors.green, size: 50)),
                            ),
                            progressColor: _statusColor),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: _resultWidget),
                        ),
                        if (_test!.resultName == 'Appointment Set' &&
                            _test!.type == 7 ||
                            _test!.type == 8)
                          Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    'Kindly Fill in this Form to Complete the Process'.tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      color: Colors.amber,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                      return WebViewFormScreen(
                                        title: _type,
                                        url: (_test!.type == 7)
                                            ? "https://docs.google.com/forms/d/e/1FAIpQLSf3S9NAIoP0tRiyRumlQbUYPCVqJZwIxYVIKPPFMuniFnvBpQ/viewform"
                                            : "https://docs.google.com/forms/d/e/1FAIpQLSeXPkua1R5osXlqXd9XxfQWQaauWIWrm0bjdZBkQk1T6zaX7g/viewform",
                                      );
                                    }));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Card(
                                          child: Icon(Icons.app_registration,
                                              color: Colors.amber, size: 40)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Visibility(
                                      visible: (_test!.type! > 10),
                                      replacement: Container(),
                                      child: Text(
                                        'SELF TEST'.tr,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      'Reference No: '.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _test!.refNo!,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat', fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Visibility(
                                    visible: (_test!.poc != null),
                                    replacement: Container(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                                      child: Row(
                                        crossAxisAlignment:CrossAxisAlignment.start,
                                        mainAxisAlignment:MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              (_test!.type! <= 10)
                                                  ? 'Point of care : '.tr
                                                  : 'Validation : '.tr,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _test!.poc!.name!.tr,
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10),
                                    child: Row(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      mainAxisAlignment:MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          child: Text(
                                            (_test!.type! < 10)
                                                ? 'Type : '.tr
                                                : 'Test Method:'.tr,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            (_type != '')
                                                ? _type.tr
                                                : "General Appointment".tr,
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  (_test!.type! > 10 &&
                                          _test!.resultName != 'Pending')
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            mainAxisAlignment:MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'SUBMIT RESULT'.tr,
                                                  style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                mainAxisAlignment:MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 120,
                                                    child: Text(
                                                      'PERKESO : '.tr,
                                                      style: const TextStyle(
                                                        fontFamily:'Montserrat',
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _launchURL('https://socsoscreeningprogram.com.my');
                                                      },
                                                      child: Text(
                                                        'Submit to PERKESO'.tr,
                                                        style: TextStyle(
                                                            fontFamily:'Montserrat',
                                                            fontSize: 14,
                                                            decoration:TextDecoration.underline,
                                                            color: CupertinoTheme.of(context).primaryColor),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  Visibility(
                                    visible: (_test!.appointmentAt != null),
                                    replacement: Container(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                                      child: Row(
                                        crossAxisAlignment:CrossAxisAlignment.end,
                                        mainAxisAlignment:MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              'Date : '.tr,
                                              style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            (_test!.appointmentAt != null)
                                                ? DateFormat('dd/MM/yyyy').format(_test!.appointmentAt!).toString()
                                                : '',
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  Visibility(
                                    visible: (_test!.type! <= 10),
                                    replacement: Container(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                                      child: Row(
                                        crossAxisAlignment:CrossAxisAlignment.start,
                                        mainAxisAlignment:MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              'Session : '.tr,
                                              style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            (_test!.session_name != null)
                                                ? _test!.session_name.toString()
                                                : '',
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  if (_test!.dependant_name != null &&
                                      _test!.dependant_name != "")
                                    Visibility(
                                      visible: (_test!.type! <= 10 &&
                                          _test!.dependant_name != null &&
                                          _test!.dependant_name != ""),
                                      replacement: Container(),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 10),
                                        child: Row(
                                          crossAxisAlignment:CrossAxisAlignment.start,
                                          mainAxisAlignment:MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              child: Text(
                                                'Dependant : '.tr,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight:FontWeight.bold),
                                              ),
                                            ),
                                            Text(
                                              _test!.dependant_name!,
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Visibility(
                                    visible: (_test!.type! < 10),
                                    replacement: Container(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 10),
                                      child: Row(
                                        crossAxisAlignment:CrossAxisAlignment.start,
                                        mainAxisAlignment:MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              'Appointment By : '.tr,
                                              style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            (_test!.type! < 10)
                                                ? modeList[_test!.mode!]
                                                : 'Null',
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  Visibility(
                                    visible: (_test!.poc != null),
                                    replacement: Container(),
                                    child: SizedBox(
                                      height: 105,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'MY TEST LOCATION'.tr,
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              (_test!.type! > 10 &&
                                                _test!.resultName =='Appointment Set')
                                                  ? Container()
                                                  : Container(
                                                      child: Text(
                                                        (_test!.type! < 10)
                                                            ? 'Address : '.tr
                                                            : ''.tr,
                                                        style: const TextStyle(
                                                            fontFamily:'Montserrat',
                                                            fontSize: 14,
                                                            fontWeight:FontWeight.bold),
                                                      ),
                                                    ),
                                              (_test!.type! > 10)
                                                  ? (_test!.resultName =='Appointment Set')
                                                      ? Container()
                                                      : Expanded(
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              _launchURL('https://www.google.com/maps/search/?api=1&query=$latitudeCaptured,$longitudeCaptured');
                                                            },
                                                            child: Text(
                                                              'Your test location'.tr,
                                                              style: const TextStyle(
                                                                  fontFamily:'Montserrat',
                                                                  fontSize: 14,
                                                                  decoration:TextDecoration.underline,
                                                                  color: Colors.white),
                                                            ),
                                                          ),
                                                        )
                                                  : Expanded(
                                                      child: Padding(
                                                        padding:const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Column(
                                                          mainAxisAlignment:MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(
                                                              width: 120,
                                                              child: Text(
                                                                'Location : '.tr,
                                                                style: const TextStyle(
                                                                    fontFamily:'Montserrat',
                                                                    fontSize:14,
                                                                    fontWeight:FontWeight.bold),
                                                              ),
                                                            ),
                                                            SelectableText(
                                                              _test!.poc!.address!,
                                                              maxLines: 4,
                                                              style:const TextStyle(
                                                                fontFamily:'Montserrat',
                                                                color:Colors.blue,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
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
                          ]),
                    ),
                  ),
                ),
                Visibility(
                  visible: (_test!.resultName == 'Pending'),
                  replacement: Visibility(
                    visible: (_test!.resultName == 'Negative' ||
                        _test!.resultName == 'Positive' ||
                        _test!.resultName == '' ||
                        _test!.resultName == 'Completed'),
                    replacement: (showGMaps)
                        ? Row(
                            children: [
                              if (_test!.type! > 10)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                  child: Container(
                                    width: 130,
                                    color:CupertinoTheme.of(context).primaryColor,
                                    child: Text(
                                      'MY TEST LOCATION:'.tr,
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              if (_test!.type! > 10)
                                GestureDetector(
                                  onTap: () {
                                    _launchURL('https://www.google.com/maps/search/?api=1&query=$latitudeCaptured,$longitudeCaptured');
                                  },
                                  child: Text(
                                    'Your test location'.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        color: Colors.white),
                                  ),
                                ),
                            ],
                          )
                        : Container(
                            height: 250,
                            color: Colors.white,
                            child: const Center(
                                child: CircularProgressIndicator())),
                    child: Visibility(
                      visible: (_test!.type! < 10),
                      replacement: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 130,
                                      color: CupertinoTheme.of(context).primaryColor,
                                      child: Text(
                                        'RESULT DETAILS :'.tr,
                                        style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Visibility(
                                      visible: (_test!.result != null),
                                      replacement: Center(
                                        child: Container(
                                          child: const Text('No PDF Available'),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              //Todo: View PDF in another page, can zoom in zoom out.
                                              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                                return PDFView(
                                                  pdfUrl: _testPdf!,
                                                  testId: _test!.id.toString(),
                                                );
                                              }));
                                            },
                                            child: Text(
                                              'View'.tr,
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                color: CupertinoTheme.of(context).primaryColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height *60 /100,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                  ),
                                  child: SfPdfViewer.network(
                                    _testPdf!,
                                    key: sfPDFViewerKey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (_imageUrl != null && _test!.type! > 10)
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding:const EdgeInsets.only(right: 10, left: 10),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 130,
                                    color:CupertinoTheme.of(context).primaryColor,
                                    child: Text(
                                      'TEST IMAGE :'.tr,
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Card(
                                      elevation: 5,
                                      child: SizedBox(
                                        width:MediaQuery.of(context).size.width,
                                        child: FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: _imageUrl!,
                                          //fit: BoxFit.fill,
                                          height: MediaQuery.of(context).size.height *50 /100,
                                          width: MediaQuery.of(context).size.width *10 /100,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only( right: 10, left: 10, bottom: 10),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 130,
                                  color:CupertinoTheme.of(context).primaryColor,
                                  child: Text(
                                    'RESULT DETAILS :'.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Visibility(
                                  visible: (_test!.result != null),
                                  replacement: Center(
                                    child: Container(
                                      child: Text('No PDF Available'.tr),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          //Todo: View PDF in another page, can zoom in zoom out.
                                          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                            return PDFView(
                                              pdfUrl: _testPdf!,
                                              testId: _test!.id.toString(),
                                            );
                                          }));
                                        },
                                        child: Text(
                                          'View'.tr,
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                            color: CupertinoTheme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              width:MediaQuery.of(context).size.width,
                              height:MediaQuery.of(context).size.height * 60 / 100,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1),
                              ),
                              child: SfPdfViewer.network(
                                _testPdf!,
                                key: sfPDFViewerKey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: (_test!.payment_method == 1)
                      ? Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 130,
                                    color:CupertinoTheme.of(context).primaryColor,
                                    child: Text(
                                      'BILLING TO:'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width *35 /100,
                                        child: Text(
                                          'Name : '.tr,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          _test!.user!.name!,
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:MediaQuery.of(context).size.width *35 /100,
                                        child: Text(
                                          'Phone No. : '.tr,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          _test!.user!.phoneNo!,
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  (_test!.user!.email != '')
                                      ? Row(
                                          crossAxisAlignment:CrossAxisAlignment.start,
                                          mainAxisAlignment:MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * 35 /100,
                                              child: Text(
                                                'Email : '.tr,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight:FontWeight.w600),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                _test!.user!.email!,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight:FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  const Divider(
                                    height: 10,
                                    thickness: 2,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 130,
                                    color:CupertinoTheme.of(context).primaryColor,
                                    child: Text(
                                      'TRANSFER TO:'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width *35 /100,
                                        child: Text(
                                          'Transfer Details : '.tr,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        _test!.refNo!,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:MediaQuery.of(context).size.width *35 /100,
                                        child: Text(
                                          'Account Holder : '.tr,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Text(
                                          'Teda GH Technology Sdn Bhd (1417436-H)',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:MediaQuery.of(context).size.width *35 / 100,
                                        child: Text(
                                          'Account No : '.tr,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const Text(
                                        '00300608339 (HLB)',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:MediaQuery.of(context).size.width *35 / 100,
                                        child: Text(
                                          'Transfer Amount : '.tr,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        'RM ' + _test!.price!,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                color: CupertinoTheme.of(context).primaryColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      color: CupertinoTheme.of(context).primaryColor,
                                      child: Text(
                                        'INSTRUCTIONS :'.tr,
                                        style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      mainAxisAlignment:MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '1. ',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Check the "DETAILS" section to make sure all the details are correct. '
                                                .tr,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '2. ',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Pay using bank transfer method to the account number listed in "TRANSFER TO" section with exact transfer details as shown.'.tr,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      mainAxisAlignment:MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '3. ',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'After the payment is successful, please send the payment proof by: '.tr,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      crossAxisAlignment:CrossAxisAlignment.center,
                                      mainAxisAlignment:MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _launchWhatsapp();
                                          },
                                          child: const Icon(
                                            CupertinoIcons.phone_circle,
                                            size: 50,
                                            color: CupertinoColors.white,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                          child: const Text(
                                            'or ',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _launchEmail();
                                          },
                                          child: const Icon(
                                            CupertinoIcons.mail,
                                            size: 50,
                                            color: CupertinoColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.only( bottom: 10, left: 10, right: 10),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.only(bottom: 10),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'PAYMENT DETAILS'.tr,
                                        style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width *35 /100,
                                          child: Text(
                                            'Total Payment : '.tr,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'RM ' + _test!.price!,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 10,
                                thickness: 2,
                                color: Colors.black,
                              ),
                              CupertinoButton(
                                onPressed: () async {
                                  String status;
                                  status = await Navigator.of(context).push(
                                      CupertinoPageRoute(builder: (context) {
                                    return WebViewScreen(
                                      url: url,
                                      title: 'Payment Gateway',
                                    );
                                  }));
                                  if (status == '0') {
                                    Navigator.pop(context);
                                    Toast.show(context, 'default','Payment Successful'.tr);
                                  } else if (status == '1') {
                                    Toast.show(context, 'default','Transaction Declined'.tr);
                                  } else {
                                    Toast.show(context, 'danger', 'Error'.tr);
                                  }
                                },
                                child: Text(
                                  'Continue Payment To Proceed'.tr,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w300,
                                      color: CupertinoTheme.of(context).primaryColor,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              if (_test!.is_paid == 0)
                                CupertinoButton(
                                  onPressed: () async {
                                    var response =await Test.cancel(context, _test!.id!);
                                    if (response != null) {
                                      if (response.status) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Cancel Appointment'.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.red,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _launchEmail() async {
    await EmailLauncher.launch(email);
  }

  void _launchWhatsapp() async {
    const url =
        'https://wa.me/60146717681?text=Hello, this is my payment proof for (INSERT PAYMENT DETAILS)';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  String setUrl(int id, String hash, int testId) {
    String url = MainConfig.baseUrl +'/payment/gateway/execute?id=$id&hash=$hash&testId=$testId';
    return url;
  }

  void assignUrl() {
    setState(() {
      _testPdf = (_test!.type! <= 10)
          ? MainConfig.appUrl + '/screening/file/test/' + _test!.id.toString()
          : MainConfig.appUrl +'/screening/file/self-test/' +_test!.id.toString();
      _imageUrl = MainConfig.appUrl +'/screening/image/self-test/' +_test!.id.toString();
    });
  }

  cancelPopUp(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text('Cancel'.tr),
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text('Confirm'.tr),
      onPressed: () {
        if (mounted) {
          setState(() {
            //submit
            delete(context);
          });
        }
        Navigator.of(context).pop();
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
              'Confirm cancel order'.tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: CupertinoTheme.of(context).primaryColor,
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

  Future<void> delete(BuildContext context) async {
    final webService = WebService(context);
    String order_id = _testId.toString();
    List<String> errors = [];
    webService.setMethod('POST').setEndpoint('screening/tests/cancel/$_testId');
    var response = await webService.send();
    if (response == null) return;
    if (response.status) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return HistoryScreen();
      }));
      Toast.show(context, 'default', 'Order Cancelled');
    } else if (response.error.isNotEmpty) {
      errors.add(response.error.values.toList()[0]);
    } else {
      errors.add('Server connection timeout.');
    }
    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  }

  Future<Test?> _getContent() async {
    final webService = WebService(context);
    // get single test model
    var response = await webService.setEndpoint('screening/tests/' + _testId.toString()).setExpand('poc,user').send();
    if (response == null) return null;
    if (response.status) {
      var modelArray = jsonDecode(response.body.toString());
      _test = Test.fromJson(modelArray);
      _getLocation();
      if (OptTest.typeEnum.containsKey(_test!.type)) {
        _type = OptTest.typeEnum[_test!.type!]!;
      }
      String id = _test!.order_id.toString();
      String? hash = (_test!.hash != null) ? _test!.hash!.toString() : null;
      url = MainConfig.baseUrl +'/payment/gateway/execute?id=$id&hash=$hash&testId=$_testId';
      assignUrl();
      setState(() {
        if (_test!.test_address != null) {
          testLocation = _test!.test_address!['address_1'] +
              ' ' +
              _test!.test_address!['address_2'] +
              ',' +
              _test!.test_address!['postcode'] +
              ',' +
              _test!.test_address!['city'];
        }
        _isLoading = false;
      });
    }
    return _test;
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
