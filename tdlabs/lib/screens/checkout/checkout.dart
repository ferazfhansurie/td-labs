// ignore_for_file: library_prefixes, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as Get;
import 'package:intl/intl.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/screening/opt_test.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:tdlabs/models/screening/self-test.dart';
import 'package:tdlabs/models/screening/test.dart';
import 'package:tdlabs/screens/history/transfer_details.dart';
import 'package:tdlabs/screens/medical/screening/self_test_form.dart';
import 'package:tdlabs/screens/voucher/voucher_select.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import '../../adapters/webview/inAppWebViewPayment.dart';
import '../../global.dart' as global;

// ignore: must_be_immutable
class CheckoutScreen extends StatefulWidget {
  Poc? poc;
  int? id;
  int? type;
  int? brand_id;
  int? timeSessionId;
  String? timeSessionName;
  String? originalPrice;
  String? price;
  int? mode;
  DateTime? appointmentAt;
  String? image;
  String? qrCapture;
  String? name;
  String? email;
  String? address1;
  String? address2;
  String? postcode;
  String? city;
  String? state;
  String? country;
  String? type_answer;
  SelfTest? selfTest;
  int? validationType;
  int? dependant_id;
  String? dependName;
  String? testName;
  String? message;
  CheckoutScreen(
      {Key? key,
      this.id,
      this.poc,
      this.type,
      this.brand_id,
      this.timeSessionId,
      this.timeSessionName,
      this.originalPrice,
      this.price,
      this.mode,
      this.appointmentAt,
      this.image,
      this.qrCapture,
      this.name,
      this.email,
      this.address1,
      this.address2,
      this.postcode,
      this.city,
      this.state,
      this.country,
      this.selfTest,
      this.validationType,
      this.dependant_id,
      this.type_answer,
      this.dependName,
      this.testName,
      this.message})
      : super(key: key);
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? dateTime;
  List? poc;
  String? newPrice;
  String? discountPrice;
  int? discountMethod;
  String? voucherCode;
  int? voucherId;
  String? voucherChild;
  Map<dynamic, dynamic>? returnResult = {};
  int paymentMethod = 2;
  String? url;
  String? hash;
  int? id;
  bool bankTransferActive = true;
  bool onlinePaymentActive = false;
  bool creditStoreActive = false;
  int use_credit = 0;
  String point = "0";
  bool isSwitched = false;
  List<Map<String, dynamic>> paymentMethodList = [];
  final NumberFormat _formatter = NumberFormat(',##0.00');
  @override
  void initState() {
    //implement initState
    super.initState();
    if (widget.appointmentAt != null) {
      dateTime =
          DateFormat('dd/MM/yyyy').format(widget.appointmentAt!.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/Background-02.png"),
                  fit: BoxFit.fill),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(
          
                bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Check Out".tr,
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
                _summaryCard(),
                _redemptionCard(),
                _paymentCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 8 / 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Payment'.tr),
                Text(
                  (newPrice == null)
                      ? MainConfig.CURRENCY +_formatter.format(double.parse(widget.originalPrice!))
                      : MainConfig.CURRENCY + _formatter.format(double.parse(newPrice!)),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Visibility(
              visible: paymentMethod != 0,
              replacement: Container(
                color: CupertinoColors.inactiveGray,
                height: MediaQuery.of(context).size.height * 8 / 100,
                width: MediaQuery.of(context).size.width * 20 / 100,
                child: Center(
                  child: Text(
                    'Proceed'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white),
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  _submitForm(context);
                },
                child: Container(
                  color: CupertinoTheme.of(context).primaryColor,
                  height: MediaQuery.of(context).size.height * 8 / 100,
                  width: MediaQuery.of(context).size.width * 20 / 100,
                  child: Center(
                      child: Text(
                    'Proceed'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white),
                  )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void clearDiscount() {
    setState(() {
      newPrice = (widget.price == null) ? null : widget.price;
      discountPrice = null;
      discountMethod = null;
      voucherCode = null;
      voucherId = null;
      voucherChild = null;
    });
    Toast.show(context, 'success', 'Voucher Cleared!');
  }

  Widget _summaryCard() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Checkout Summary'.tr,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: CupertinoTheme.of(context).primaryColor),
                ),
                Visibility(
                  visible: (widget.type! > 10),
                  replacement: Container(),
                  child: Text(
                    'Self Test'.tr,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text('Point of Care:'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text(
                      (widget.poc != null) ? widget.poc!.name! : 'Null',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text('Type:'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text(
                        (widget.testName == null)
                            ? (widget.type != 6)
                                ? (widget.type != null &&
                                        widget.type != 21 &&
                                        widget.type != 10)
                                    ? OptTest.typeEnum[widget.type]!.tr
                                    : 'General Booking'.tr
                                : "Neutralizing Antibody"
                            : widget.testName!.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300)),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: (dateTime != null),
              replacement: Container(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text('Appointment Date :'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Text(
                        (dateTime != null) ? dateTime! : 'Null',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: (widget.timeSessionName != null),
              replacement: Container(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Session: '.tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        (widget.timeSessionName != null)
                            ? widget.timeSessionName!.tr
                            : 'Null',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.name != "" || widget.name != null)
              if (widget.dependName != "" && widget.dependName != null)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text('Dependant:'.tr,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600)),
                      ),
                      if (widget.dependName != "")
                        Expanded(
                          child: Text(
                            (widget.dependName != "" &&
                                    widget.dependName != null)
                                ? widget.dependName!
                                : '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            Visibility(
              visible: (widget.message != "" && widget.message != null),
              replacement: Container(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text('Message :'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Text(
                        (widget.message != "" && widget.message != null)
                            ? widget.message!
                            : '',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
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

  Widget _redemptionCard() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: CupertinoTheme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Discount'.tr,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
                Visibility(
                  visible: voucherCode != null,
                  replacement: Container(),
                  child: GestureDetector(
                    onTap: clearDiscount,
                    child: const Icon(
                      CupertinoIcons.clear_circled,
                      color: CupertinoColors.systemRed,
                      size: 25,
                    ),
                  ),
                )
              ],
            ),
            Container(
              //width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 10, right: 10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.white,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        fetchAfterDiscount();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Voucher'.tr,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Visibility(
                            visible: voucherCode == null,
                            replacement: Row(
                              children: [
                                Container(
                                  width: 200,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    (voucherCode != null) ? voucherCode! : '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      color: CupertinoColors.label,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  CupertinoIcons.checkmark,
                                  color: CupertinoColors.activeGreen,
                                  size: 20,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Select Voucher / Promo Code ...'.tr.tr,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                                const Icon(CupertinoIcons.chevron_right,
                                    size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Payment'.tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal'.tr,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.originalPrice != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 60),
                        child: Text(
                          MainConfig.CURRENCY +_formatter.format(double.parse(widget.originalPrice!)),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Visibility(
              visible: (discountPrice != null),
              replacement: Container(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Voucher/Promo'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 60),
                      child: Text(
                        (discountPrice != null)
                            ? '- RM' + discountPrice.toString()
                            : '',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Payment'.tr,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 60),
                      child: Text(
                        (newPrice == null)
                            ? MainConfig.CURRENCY + _formatter.format(double.parse(widget.originalPrice!))
                            : MainConfig.CURRENCY +_formatter.format(double.parse(newPrice!)),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchAfterDiscount() async {
    if (returnResult != null) {
      returnResult!.clear();
    }
    returnResult = await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return VoucherSelect(
        originalPrice: widget.originalPrice,
        poc: widget.poc,
        testType: widget.type,
        mode: widget.mode,
        use_credit: use_credit,
      );
    }));

    if (returnResult != null) {
      setState(() {
        newPrice = returnResult!['discount_price'];
        discountPrice = returnResult!['deduct_amount'];
        discountMethod = returnResult!['quantifier'];
        voucherCode = returnResult!['voucher_code'];
        voucherId = returnResult!['voucher_id'];
        voucherChild = returnResult!['voucher_child'];
      });
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    Test test = Test();
    SelfTest selfTest = SelfTest();
    if (widget.type! <= 10 || widget.type! > 20) {
      setState(() {
        test.poc_id = widget.poc!.id;
        test.type = widget.type;
        test.timeSession = widget.timeSessionId;
        test.price = (newPrice != null) ? newPrice : widget.originalPrice;
        test.mode = widget.mode;
        test.appointmentAt = widget.appointmentAt;
        test.voucher_id = voucherId;
        test.voucher_code = voucherCode;
        test.voucher_child = voucherChild;
        test.payment_method = paymentMethod;
        test.originalPrice = widget.originalPrice;
        test.use_credit = use_credit;
        test.dependant_id = widget.dependant_id;
        test.user_remark = widget.message;
      });
      List<String> errors = Test.validate(test);
      if ((widget.type != null) && (errors.isEmpty)) {
        final GlobalKey progressDialogKey = GlobalKey<State>();
        ProgressDialog.show(context, progressDialogKey);
        var response = await Test.create(context, test);
        ProgressDialog.hide(progressDialogKey);
        if (response != null) {
          if (response.status) {
            var array = jsonDecode(response.body.toString());
            var testId = array['id'];
            global.updateTestScreen = true;
            if (paymentMethod == 1) {
              Toast.show(context, 'default', 'Record created.');
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context, true);
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return TransferDetails(
                  testID: testId,
                  name: widget.testName,
                );
              }));
            } else {
              hash = array['hash'];
              id = array['order_id'];
              String status;
              if (mounted) {
                setState(() {
                  url = MainConfig.baseUrl +'/payment/gateway/execute?id=$id&hash=$hash&testId=$testId';
                });
              }
              status = await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return WebViewScreen(
                  url: url!,
                  title: 'Payment Gateway',
                );
              }));
              if (status == '0') {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context, true);
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                  return TransferDetails(
                    testID: testId,
                  );
                }));
                Toast.show(context, 'success', 'Booking Successful'.tr);
              } else if (status == '1') {
                Toast.show(context, 'default', 'Transaction Declined'.tr);
              } else {
                Toast.show(context, 'danger', 'Error'.tr);
              }
            }
          } else if (response.error.isNotEmpty) {
            errors.add(response.error.values.toList()[0]);
          }
        } else {
          errors.add('Server connection timeout.');
        }
      }
      if (errors.isNotEmpty) {
        Toast.show(context, 'danger', errors[0]);
      }
    } else {
      setState(() {
        selfTest.id = widget.selfTest!.id;
        selfTest.image = widget.image;
        selfTest.type = widget.type;
        selfTest.qrCode = widget.qrCapture;
        selfTest.brand_id = widget.brand_id;
        selfTest.price = widget.poc!.price;
        selfTest.verify = 1;
        selfTest.poc_id = widget.poc!.id;
        selfTest.originalPrice = widget.poc!.price;
        selfTest.name = widget.name;
        selfTest.email = widget.email;
        selfTest.address1 = widget.address1;
        selfTest.address2 = widget.address2;
        selfTest.postcode = widget.postcode;
        selfTest.city = widget.city;
        selfTest.state = widget.state;
        selfTest.country = widget.country;
        selfTest.question_id = widget.selfTest!.question_id;
        selfTest.answer_id = widget.selfTest!.answer_id;
        selfTest.answer_description = widget.selfTest!.answer_description;
        selfTest.longitude = widget.selfTest!.longitude;
        selfTest.latitude = widget.selfTest!.latitude;
        selfTest.specimen = widget.selfTest!.specimen;
        selfTest.payment_method = paymentMethod;
        selfTest.voucher_code = voucherCode;
        selfTest.voucher_child = voucherChild;
        selfTest.voucher_id = voucherId;
        selfTest.use_credit = use_credit;
        selfTest.dependant_id = widget.dependant_id;
        selfTest.video = widget.selfTest!.video;
      });
      if (widget.type != null && widget.type != 21) {
        final GlobalKey progressDialogKey = GlobalKey<State>();
        ProgressDialog.show(context, progressDialogKey);
        var response = await SelfTest.create(context, selfTest);
        ProgressDialog.hide(progressDialogKey);
        if (response!.status) {
          var array = jsonDecode(response.body.toString());
          var testId = array[0]["id"];
          hash = array[0]['hash'];
          id = array[0]['order_id'];
          String status;
          if (mounted) {
            setState(() {
              url = MainConfig.baseUrl +'/payment/gateway/execute?id=$id&hash=$hash&testId=$testId';
            });
          }
          status = await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return WebViewScreen(
              url: url!,
              title: 'Payment Gateway',
            );
          }));
          if (status == '0') {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context, true);
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return TransferDetails(
                testID: testId,
              );
            }));
            Toast.show(context, 'default', 'Payment Successful');
          } else if (status == '1') {
            Toast.show(context, 'default', 'Transaction Declined');
          } else {
            Toast.show(context, 'danger', 'Error');
          }
        } else {
          var error = response.error.values.toList()[0];
          Toast.show(context, "danger", error);
        }
      } else if (widget.type == 21 || test.is_e_report == 1) {
        final GlobalKey progressDialogKey = GlobalKey<State>();
        ProgressDialog.show(context, progressDialogKey);
        var response = await SelfTest.preCreateCode(context, selfTest);
        ProgressDialog.hide(progressDialogKey);
        if (response != null) {
          if (response.status) {
            var array = jsonDecode(response.body.toString());
            var testId = array[0]["id"];
            hash = array[0]['hash'];
            id = array[0]['order_id'];
            String status;
            if (mounted) {
              setState(() {
                url = MainConfig.baseUrl +'/payment/gateway/execute?id=$id&hash=$hash&testId=$testId';
              });
            }
            status = await Navigator.of(context)
                .push(CupertinoPageRoute(builder: (context) {
              return WebViewScreen(
                url: url!,
                title: 'Payment Gateway',
              );
            }));
            if (status == '0') {
              Navigator.pop(context);
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return SelfTestForm(
                  test_id: testId,
                  optTestId: selfTest.brand_id,
                  method: 0,
                  cont: false,
                  validationType: widget.validationType!,
                  price: widget.poc!.price,
                );
              }));
              Toast.show(context, 'default', 'Payment Successful');
            } else if (status == '1') {
              Toast.show(context, 'default', 'Transaction Declined');
            } else {
              Toast.show(context, 'danger', 'Error');
            }
          }
        }
      }
    }
  }
}
