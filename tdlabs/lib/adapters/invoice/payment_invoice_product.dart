// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_returning_null_for_void, unused_field

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:email_launcher/email_launcher.dart';
import 'package:tdlabs/adapters/webview/inAppWebViewPayment.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/screens/catalog/catalog_screen.dart';
import 'package:tdlabs/screens/catalog/vm_screen.dart';
import 'package:tdlabs/screens/history/product_history_screen.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/commerce/product_history.dart';
import '../../models/commerce/vending_machine.dart';
import '../../models/user/user.dart';
import '../../screens/info/helpdesk.dart';
import '../../utils/toast.dart';
import '../util/pdf_view.dart';

class PaymentInvoiceProduct extends StatefulWidget {
  ProductHistory? productHistory;
  User? user;
  bool? continuePayment;
  String? fullAddress;
  String? phoneNo;
  bool? isVm;
  int? index;
  bool? refresh;

  PaymentInvoiceProduct(
      {Key? key,
      this.productHistory,
      this.user,
      this.continuePayment = false,
      this.fullAddress,
      this.phoneNo,
      this.isVm,
      this.index,
      this.refresh})
      : super(key: key);

  @override
  _PaymentInvoiceProductState createState() => _PaymentInvoiceProductState();
}

class _PaymentInvoiceProductState extends State<PaymentInvoiceProduct> {
  final GlobalKey<SfPdfViewerState> sfPDFViewerKey = GlobalKey();
  List<ProductHistory> list = [];
  Email email = Email(
      to: ['customer@tdlabs.co'],
      cc: [''],
      bcc: [''],
      subject: 'Payment : "INSERT TRANSFER DETAILS"',
      body: '');
  String? url;
  String? vmName;
  String? vmArea;
  String? vmCode;
  String vmid = "";
  int page = 1;
  List<VendingMachine> vendingMachine = [];
  VendingMachine? vm;
  String? items;
  List<String>? getItems = [];
  String statusName = 'N/A';
  Color colorStatus = Colors.blueGrey;
  Color nameColor = Colors.black;
  bool isPop = false;
  bool isCancelable = false;
  late Timer _timer;
  late Timer _timer2;
  late Timer _timer3;
  double cancelTime = 0;
  @override
  void initState() {
    //implement initState
    super.initState();
    if (widget.productHistory!.vm_id != null) {
      vmid = widget.productHistory!.vm_id!.toString();
    }
    if (widget.productHistory!.statusLabel == "Assigning Driver" &&
        isCancelable == false) {
      DateTime createdAt = widget.productHistory!.createdAt!;
      Duration second = const Duration(minutes: 3);
      DateTime cancelableTime = createdAt.add(second);
      Future.delayed(const Duration(seconds: 1)).then(
        (value) async {
          if (DateTime.now().isAfter(cancelableTime)) {
            setState(() {
              isPop = true;
              isCancelable = true;
            });
            _showCancel(context);
          } else {
            setState(() {
              isCancelable = false;
            });
          }
          _refreshContent();
        },
      );
    } else {
      Future.delayed(const Duration(milliseconds: 30)).then(
        (value) async {
          _refreshContent();
        },
      );
    }
  }

  Future<VendingMachine?> _fetchVM(BuildContext context,) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('vm/vending-machines/$vmid');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      Map<String, dynamic> result = jsonDecode(response.body.toString());
      VendingMachine vms = VendingMachine.fromJson(jsonDecode(response.body.toString()));
      if (mounted) {
        setState(() {
          vmName = result['name'];
          vmArea = result['area_name'];
          vmCode = result['code'];
          vm = vms;
        });
      }
    }
    return vm;
  }

  Future<List<ProductHistory>> fetchHistory2() async {
    List<String> errors = [];
    var response = await ProductHistory.fetchHistory2(context, widget.productHistory!.id!);
    if (response != null) {
      if (response.status) {
        ProductHistory productHistory = ProductHistory.fromJson(jsonDecode(response.body.toString()));
        setState(() {
          widget.productHistory = productHistory;
          widget.productHistory!.qr_code = productHistory.qr_code;
          getItems = [];
          items;
          if (widget.productHistory!.items!.isNotEmpty)
            // ignore: curly_braces_in_flow_control_structures
            for (int i = 0; i < widget.productHistory!.items!.length; i++) {
              setState(() {
                getItems!.add(widget.productHistory!.items![i]['name'] +' X ' + widget.productHistory!.items![i]['quantity'].toString());
                items = getItems!.join("\n");
              });
            }
        });
      }
    } else if (response!.error.isNotEmpty) {
      errors.add(response.error.values.toList()[0]);
    } else {
      errors.add('Server connection timeout.');
    }
    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
    return list;
  }

  String setUrl(int id, String hash) {
    String url;
    if (!MainConfig.modeLive) {
      url = 'https://dev.tdlabs.co/payment/gateway/execute?id=$id&hash=$hash';
    } else {
      url = 'https://cloud.tdlabs.co/payment/gateway/execute?id=$id&hash=$hash';
    }
    return url;
  }

  Future<void> _refreshContent() async {
    url = setUrl(widget.productHistory!.id!, widget.productHistory!.hash!);
    vmid = widget.productHistory!.vm_id.toString();
    _fetchVM(context);
    if (widget.isVm == true || widget.productHistory!.vm_id != null) {
      await fetchHistory2();
    }
    getItems = [];
    items;
    if (widget.productHistory!.items!.isNotEmpty)
      // ignore: curly_braces_in_flow_control_structures
      for (int i = 0; i < widget.productHistory!.items!.length; i++) {
        setState(() {
          getItems!.add(widget.productHistory!.items![i]['name'] + ' X ' + widget.productHistory!.items![i]['quantity'].toString());
          items = getItems!.join("\n");
        });
      }
    switch (widget.productHistory!.statusLabel) {
      case 'Assigning Driver':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = const Color.fromARGB(255, 255, 128, 0);
          nameColor = Colors.white;
        });
        _timer2 = Timer.periodic(const Duration(minutes: 3), (timer) {
          if (widget.productHistory!.delivery_company == "Lalamove" &&
              isPop == false) {
            isPop = true;
            if (mounted) _showCancel(context);
          }
        });
        break;
      case 'On Going':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.blueAccent;
          nameColor = Colors.white;
          isPop = true;
        });
        break;
      case 'Pending':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.orange;
          nameColor = Colors.white;
        });
        break;
      case 'Submitted':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.blueGrey;
          nameColor = Colors.white;
        });
        break;
      case 'Paid':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.blueAccent;
          nameColor = Colors.white;
        });
        break;
      case 'Processed':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.blue;
          nameColor = Colors.white;
        });
        break;
      case 'Shipped':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.lightGreen;
          nameColor = Colors.white;
        });
        break;
      case 'Completed':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.green;
          nameColor = Colors.white;
        });
        break;
      case 'Cancelled':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.red;
          nameColor = Colors.white;
        });
        if (widget.productHistory!.delivery_company == "Lalamove") {
          _timer3 = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (isPop == false) {
              if (mounted) {
                setState(() {
                  isPop = true;
                });
                helpPopUp(context);
              }
            }
          });
        }

        break;
      case 'Void':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.black;
          nameColor = Colors.white;
        });
        break;
      default:
    }
  }

  _showCancel(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    // set up the AlertDialog
    Container alert = Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 350,
                width: 300,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 250,
                        child: Text(
                          "Its taking more time than usual to find you a driver",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 99,
                        child: Image.network(
                            'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExNzUyODY4NjBhZmJmMjIyNjE4ZDgyOTBiYzQ3OTNkNTY1YjRlOGU5ZiZjdD1z/kddcu6jjEJIocIWTcx/giphy.gif'),
                      ),
                      const SizedBox(
                        width: 300,
                        child: Text(
                          "Would you like to cancel your order?",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 36,
                              child: CupertinoButton(
                                key: const Key("address_submit"),
                                color: Colors.red,
                                disabledColor: CupertinoColors.inactiveGray,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  delete(context);
                                },
                                child: Text('Cancel'.tr,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 100,
                              height: 36,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  isPop = false;
                                  Navigator.pop(context);
                                  _refreshContent();
                                },
                                child: Text('Back'.tr,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
              const shouldPop = true;
              isPop = false;
              Navigator.pop(context);

              return shouldPop;
            },
            child: alert);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Background-01.png"),
                fit: BoxFit.fill),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(
           top:30,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(
                          width: 30,
                        ),
                        Text(
                          "Details".tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300),
                        ),
                        const Spacer(),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: () async {
                                if (widget.productHistory!.vm_id == 0) {
                                  Navigator.popUntil( context, (route) => route.isFirst);
                                  Navigator.of(context).push(
                                      CupertinoPageRoute(builder: (context) {
                                    return CatalogScreen();
                                  }));
                                } else {
                                  await _fetchVM(context);
                                  Navigator.popUntil( context, (route) => route.isFirst);
                                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                    return VmScreen(vm: vm);
                                  }));
                                }
                              },
                              child: Column(
                                children: [
                                  const Icon(
                                    CupertinoIcons.cart_fill_badge_plus,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Buy more".tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            )),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                  return const HelpdeskScreen();
                                }));
                              },
                              child: Column(
                                children: [
                                  const Icon(
                                    CupertinoIcons.question_circle_fill,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Help".tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _refreshContent,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: status(statusName, colorStatus, nameColor)),
                                  if (statusName == "Assigning Driver")
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 20,
                                        width: 20,
                                        child: const CircularProgressIndicator(
                                          color: Color.fromARGB(255, 255, 128, 0),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: [
                                    Center(
                                        child: SizedBox(
                                            width: 75,
                                            child: Image.asset('assets/images/TDlogo.png'))),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Reference No: '.tr,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    color: Color.fromARGB(255, 104, 104, 104),
                                                    fontWeight:FontWeight.bold)),
                                            Text(
                                              widget
                                                  .productHistory!.referenceNo!,
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                color: Color.fromARGB(255, 104, 104, 104),
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Date: '.tr,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    color: Color.fromARGB(255, 104, 104, 104),
                                                    fontWeight:FontWeight.bold)),
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(widget.productHistory!.createdAt!),
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                color: Color.fromARGB(255, 104, 104, 104),
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              (widget.productHistory!.vm_id != 0 &&
                                      statusName == "Paid" &&
                                      widget.productHistory!.qr_code != null &&
                                      widget.productHistory!.delivery_company !="Lalamove")
                                  ? Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width *75 /100,
                                            height: MediaQuery.of(context).size.height *35 /100,
                                            padding: const EdgeInsets.all(25),
                                            alignment: Alignment.center,
                                            child: RepaintBoundary(
                                              child: QrImageView(
                                                version: QrVersions.auto,
                                                data: widget.productHistory!.qr_code!,
                                                gapless: false,
                                                backgroundColor: Colors.white,
                                                foregroundColor:CupertinoTheme.of(context).primaryColor,
                                                // padding:const EdgeInsets.only(left: 100, right: 100, top: 50),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Collect Location:  '.tr,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      color: Color.fromARGB(255, 104, 104, 104),
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  '$vmName\n$vmArea '.tr,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      color: CupertinoTheme.of(context).primaryColor,
                                                      fontWeight:FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (widget.productHistory!.qr_expiry_date != null)
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              child: Column(
                                                mainAxisAlignment:MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Collect Before: '.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:'Montserrat',
                                                        fontSize: 15,
                                                        color: Color.fromARGB(255, 104, 104, 104),
                                                        fontWeight:FontWeight.bold),
                                                  ),
                                                  Text(
                                                    widget.productHistory!.qr_expiry_date!.tr,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily:'Montserrat',
                                                        fontSize: 15,
                                                        color: CupertinoTheme.of(context).primaryColor,
                                                        fontWeight:FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          _helpButton(),
                                          const Divider(
                                            height: 10,
                                            thickness: 2,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Container(
                                width: 130,
                                color: CupertinoTheme.of(context).primaryColor,
                                child: Text('DETAILS: '.tr,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              if (widget.productHistory!.items != null && items != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 35 /100,
                                      child: Text(
                                        'Item(s) Ordered: '.tr,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                            color: Color.fromARGB(255, 104, 104, 104),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        (widget.productHistory!.items != [])
                                            ? items!
                                            : '',
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Color.fromARGB(255, 104, 104, 104),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 10),
                              (widget.fullAddress != 'null null,null,null,')
                                  ? Row(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 35 /100,
                                          child: Text(
                                            'Shipping Address: '.tr,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                                color: Color.fromARGB(255, 104, 104, 104),
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.fullAddress!,
                                            style: const TextStyle(
                                              color: Color.fromARGB(255, 104, 104, 104),
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              const Divider(
                                height: 10,
                                thickness: 2,
                                color: Colors.black,
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(bottom: 5),
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 130,
                                          color: CupertinoTheme.of(context).primaryColor,
                                          child: Text('BILLING TO:'.tr,
                                              style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Row(
                                          crossAxisAlignment:CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * 35 /100,
                                              child: Text('Name : '.tr,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(255, 104, 104, 104),
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold)),
                                            ),
                                            Expanded(
                                              child: Text(
                                                (widget.user!.name != '')
                                                    ? widget.user!.name!
                                                    : 'N/A',
                                                style: const TextStyle(
                                                  color: Color.fromARGB( 255, 104, 104, 104),
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:CrossAxisAlignment.start,
                                          mainAxisAlignment:MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width *35 /100,
                                              child: Text(
                                                'Phone No. : '.tr,
                                                style: const TextStyle(
                                                    color: Color.fromARGB(255, 104, 104, 104),
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight:FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                (widget.phoneNo != null)
                                                    ? widget.phoneNo!
                                                    : 'N/A',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 104, 104, 104),
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        (widget.user!.email != '')
                                            ? Row(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                mainAxisAlignment:MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:MediaQuery.of(context).size.width *35 /100,
                                                    child: Text(
                                                      'Email : '.tr,
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(255,104,104,104),
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      (widget.user!.email != '')
                                                          ? widget.user!.email!
                                                          : 'N/A',
                                                      style: const TextStyle(
                                                        color: Color.fromARGB(255, 104, 104, 104),
                                                        fontFamily:'Montserrat',
                                                        fontSize: 14,
                                                        fontWeight:FontWeight.w300,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                        const Divider(
                                            height: 10,
                                            thickness: 2,
                                            color: Colors.black),
                                        if (widget.productHistory!.tracking_link !=null)
                                          SizedBox(
                                            height: 115,
                                            child: Column(
                                              mainAxisAlignment:MainAxisAlignment.start,
                                              crossAxisAlignment:CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 130,
                                                  color:CupertinoTheme.of(context).primaryColor,
                                                  child: Text('DELIVERY: '.tr,
                                                      style: const TextStyle(
                                                          fontFamily:'Montserrat',
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold)),
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width *35 /100,
                                                      child: Text(
                                                        'Method: '.tr,
                                                        textAlign:TextAlign.start,
                                                        style: const TextStyle(
                                                            fontFamily:'Montserrat',
                                                            fontSize: 14,
                                                            color:Color.fromARGB(255,104,104,104),
                                                            fontWeight:FontWeight.bold),
                                                      ),
                                                    ),
                                                    Text(
                                                      (widget.productHistory!.delivery_company !=null)
                                                          ? widget.productHistory!.delivery_company!
                                                          : '',
                                                      style: const TextStyle(
                                                        fontFamily:'Montserrat',
                                                        color: Color.fromARGB(255, 104, 104, 104),
                                                        fontSize: 14,
                                                        fontWeight:FontWeight.w300,
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
                                                        'Tracking No.: '.tr,
                                                        textAlign:TextAlign.start,
                                                        style: const TextStyle(
                                                            fontFamily:'Montserrat',
                                                            fontSize: 14,
                                                            color: Color.fromARGB(255,104,104,104),
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                          CupertinoPageRoute(builder:(context) {
                                                          return WebViewScreen(
                                                            url: widget.productHistory!.tracking_link!,
                                                            title:'Lalamove Tracking',
                                                          );
                                                        }));
                                                      },
                                                      child: Text(
                                                        (widget.productHistory!.tracking_number !=
                                                                null)
                                                            ? widget.productHistory!.tracking_number!
                                                            : '',
                                                        style: const TextStyle(
                                                          fontFamily:'Montserrat',
                                                          color: Color.fromARGB(255,15,127,219),
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w300,
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
                                                        'Important Note: '.tr,
                                                        textAlign:TextAlign.start,
                                                        style: const TextStyle(
                                                            fontFamily:'Montserrat',
                                                            fontSize: 14,
                                                            color: Color.fromARGB(255,104,104,104),
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width *59 / 100,
                                                      child: const Text(
                                                        'Inform the driver to open the link in their remark to get QR',
                                                        maxLines: 3,
                                                        style: TextStyle(
                                                          fontFamily:'Montserrat',
                                                          color: Color.fromARGB(255, 104, 104, 104),
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w300,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                    height: 10,
                                                    thickness: 2,
                                                    color: Colors.black),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  (widget.productHistory!.statusLabel =='Paid' ||
                                          widget.productHistory!.statusLabel =='Shipped' ||
                                          widget.productHistory!.statusLabel =='Completed')
                                      ? Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 130,
                                                  color:CupertinoTheme.of(context).primaryColor,
                                                  child: Text('RECEIPT :'.tr,
                                                      style: const TextStyle(
                                                          fontFamily: 'Montserrat',
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold)),
                                                ),
                                                Visibility(
                                                  visible: (widget.productHistory!.receiptUrl !=''),
                                                  replacement: const Center(
                                                    child: Text('No PDF Available'),),
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context).push(
                                                              CupertinoPageRoute(builder:(context) {
                                                            return PDFView(
                                                              pdfUrl: widget.productHistory!.receiptUrl!,
                                                              receiptId: widget.productHistory!.id.toString(),
                                                              isTest: false,
                                                            );
                                                          }));
                                                        },
                                                        child: Text('View'.tr,
                                                            style: TextStyle(
                                                              fontFamily:'Montserrat',
                                                              fontWeight: FontWeight.w300,
                                                              fontSize: 14,
                                                              color: CupertinoTheme.of(context).primaryColor,
                                                            )),
                                                      ),
                                                      const SizedBox(width: 25),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            (widget.productHistory!.qr_code ==null)
                                                ? Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    height: MediaQuery.of(context).size.height *60 /100,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(width: 1)),
                                                    child: SfPdfViewer.network(
                                                      widget.productHistory!.receiptUrl!,
                                                      key: sfPDFViewerKey,
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        )
                                      : Container(),
                                  (widget.continuePayment! &&
                                          widget.productHistory!.statusLabel =='Submitted' &&
                                          widget.productHistory!.paymentMethod ==2)
                                      ? Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              padding: const EdgeInsets.only(bottom: 10),
                                              color: Colors.white,
                                              child: Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 130,
                                                    color: CupertinoTheme.of(context).primaryColor,
                                                    child: Text(
                                                        'PAYMENT DETAILS: '.tr,
                                                        style: const TextStyle(
                                                            fontFamily:'Montserrat',
                                                            color: Colors.white,
                                                            fontWeight:FontWeight.bold)),
                                                  ),
                                                  if (widget.productHistory!.discount !="0.00")
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment:MainAxisAlignment.end,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width * 35 /100,
                                                          child: Text(
                                                            'Discount : '.tr,
                                                            style: const TextStyle(
                                                                fontFamily:'Montserrat',
                                                                fontSize: 14,
                                                                color: Color.fromARGB(255,104,104,104),
                                                                fontWeight:FontWeight.bold),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            'RM ' + widget.productHistory!.discount!,
                                                            style:const TextStyle(
                                                              color: Color.fromARGB( 255,104,104,104),
                                                              fontFamily:'Montserrat',
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w300,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  if (widget.productHistory!.shippingFee! !="0.00")
                                                    Row(
                                                      crossAxisAlignment:CrossAxisAlignment.end,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width *35 /100,
                                                          child: Text(
                                                            'Shipping fee : '.tr,
                                                            style: const TextStyle(
                                                                fontFamily:'Montserrat',
                                                                color: Color.fromARGB(255,104,104,104),
                                                                fontSize: 14,
                                                                fontWeight:FontWeight.bold),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            'RM ' + widget.productHistory!.shippingFee!,
                                                            style:const TextStyle(
                                                              color: Color.fromARGB(255,104,104,104),
                                                              fontFamily:'Montserrat',
                                                              fontSize: 14,
                                                              fontWeight:FontWeight.w300,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment:MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width *35 /100,
                                                        child: Text(
                                                          'Total : '.tr,
                                                          style: const TextStyle(
                                                            fontFamily:'Montserrat',
                                                            color: Color.fromARGB(255,104,104,104),
                                                            fontSize: 14,
                                                            fontWeight:FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          'RM ' +widget.productHistory!.total!,
                                                          style: const TextStyle(
                                                              fontFamily:'Montserrat',
                                                              color: Color.fromARGB(255,104,104,104),
                                                              fontSize: 14,
                                                              fontWeight:FontWeight.w300),
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
                                                color: Colors.black),
                                            CupertinoButton(
                                              onPressed: () async {
                                                String status;
                                                status = await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                                  return WebViewScreen(
                                                    url: url!,
                                                    title: 'Payment Gateway',
                                                  );
                                                }));
                                                if (status == '0') {
                                                  Navigator.pop(context);
                                                  Toast.show(context, 'default','Payment Successful');
                                                } else if (status == '1') {
                                                  Toast.show(context, 'default','Transaction Declined');
                                                } else {
                                                  Toast.show(context, 'danger', 'Error');
                                                }
                                              },
                                              child: Text(
                                                'Continue Payment To Proceed'.tr,
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.blue,
                                                  decoration:TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                            CupertinoButton(
                                              onPressed: () {
                                                cancelPopUp(context);
                                              },
                                              child: Text(
                                                'Cancel'.tr,
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.blue,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  (widget.productHistory!.statusLabel =='Submitted' &&
                                          widget.productHistory!.paymentMethod ==1)
                                      ? Container(
                                          width:MediaQuery.of(context).size.width,
                                          padding:const EdgeInsets.only(bottom: 10),
                                          color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 130,
                                                color:CupertinoTheme.of(context).primaryColor,
                                                child: const Text(
                                                  'TRANSFER TO:',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                mainAxisAlignment:MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:MediaQuery.of(context).size.width *35 /100,
                                                    child: const Text(
                                                      'Transfer Details : ',
                                                      style: TextStyle(
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight:FontWeight.w300),
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.productHistory!.referenceNo!,
                                                    style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w300,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width *35 /100,
                                                    child: const Text(
                                                      'Account Holder : ',
                                                      style: TextStyle(
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w300),
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    child: Text(
                                                      'Teda GH Technology Sdn Bhd (1417436-H)',
                                                      style: TextStyle(
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight:FontWeight.w500),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                mainAxisAlignment:MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:MediaQuery.of(context).size.width *35 /100,
                                                    child: const Text(
                                                      'Account No : ',
                                                      style: TextStyle(
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight:FontWeight.w300),
                                                    ),
                                                  ),
                                                  const Text(
                                                    '00300608339 (HLB)',
                                                    style: TextStyle(
                                                        fontFamily:'Montserrat',
                                                        fontSize: 14,
                                                        fontWeight:FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                mainAxisAlignment:MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:MediaQuery.of(context).size.width *35 /100,
                                                    child: const Text(
                                                      'Transfer Amount : ',
                                                      style: TextStyle(
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight:FontWeight.w300),
                                                    ),
                                                  ),
                                                  Text(
                                                    (widget.productHistory!.total !=null)
                                                        ? 'RM ' +widget.productHistory!.total!
                                                        : '',
                                                    style: const TextStyle(
                                                        fontFamily:'Montserrat',
                                                        fontSize: 14,
                                                        fontWeight:FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  (widget.productHistory!.statusLabel =='Submitted' &&
                                          widget.productHistory!.paymentMethod ==1)
                                      ? Container(
                                          padding: const EdgeInsets.only(left: 5, right: 5),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            padding: const EdgeInsets.only(left: 10,right: 10, bottom: 10),
                                            color: CupertinoTheme.of(context).primaryColor,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment:MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:const EdgeInsets.all(4),
                                                  color:CupertinoTheme.of(context).primaryColor,
                                                  child: const Text(
                                                    'INSTRUCTIONS :',
                                                    style: TextStyle(
                                                        fontFamily:'Montserrat',
                                                        fontWeight:FontWeight.w500,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                Row(
                                                  crossAxisAlignment:CrossAxisAlignment.start,
                                                  mainAxisAlignment:MainAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      '1. ',
                                                      style: TextStyle(
                                                        fontFamily:'Montserrat',
                                                        fontSize: 14,
                                                        fontWeight:FontWeight.w300,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'Check the "DETAILS" section to make sure all the details are correct. ',
                                                        style: TextStyle(
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight:FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment:MainAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      '2. ',
                                                      style: TextStyle(
                                                        fontFamily:'Montserrat',
                                                        fontSize: 14,
                                                        fontWeight:FontWeight.w300,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'Pay using bank transfer method to the account number listed in "TRANSFER TO" section with exact transfer details as shown.',
                                                        style: TextStyle(
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight:FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      '3. ',
                                                      style: TextStyle(
                                                        fontFamily:'Montserrat',
                                                        fontSize: 14,
                                                        fontWeight:FontWeight.w300,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'After the payment is successful, please send the payment proof by: ',
                                                        style: TextStyle(
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight:FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
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
                                                          fontFamily:'Montserrat',
                                                          fontSize: 14,
                                                          fontWeight:FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _launchEmail();
                                                      },
                                                      child: const Icon(
                                                          CupertinoIcons.mail,
                                                          size: 50,
                                                          color: CupertinoColors.white),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ],
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
      ),
    );
  }

  Widget status(String statusName, Color cardColor, Color nameColor) {
    return Container(
      padding: const EdgeInsets.only(left: 5),
      alignment: Alignment.center,
      child: Card(
        color: cardColor,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
          child: Text(
            statusName.tr,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
              color: nameColor,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _helpButton() {
    return SizedBox(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return const HelpdeskScreen();
          }));
        },
        child: Text('Need help?'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: CupertinoTheme.of(context).primaryColor,
                fontWeight: FontWeight.w300)),
      ),
    );
  }

  helpPopUp(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    // ignore: deprecated_member_use
    // set up the AlertDialog
    Container alert = Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 250,
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(
                                "Your cancelled order has been refunded as",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "TD Points and a Free Shipping Voucher. ",
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color:CupertinoTheme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "To use these credits on your next purchase, please proceed to checkout, and apply the points and voucher to your order",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 104, 104, 104),
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 36,
                              child: CupertinoButton(
                                key: const Key("address_submit"),
                                color: CupertinoTheme.of(context).primaryColor,
                                disabledColor: CupertinoColors.inactiveGray,
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  await _fetchVM(context);
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                    return VmScreen(vm: vm);
                                  }));
                                },
                                child: Text('Buy Again'.tr,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white)),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              height: 36,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Back'.tr,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  cancelPopUp(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    // ignore: deprecated_member_use
    // set up the AlertDialog
    Container alert = Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 305,
                width: 324,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.productHistory!.delivery_company == "Lalamove")
                        SizedBox(
                          height: 120,
                          child: Image.network(
                              'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExNzUyODY4NjBhZmJmMjIyNjE4ZDgyOTBiYzQ3OTNkNTY1YjRlOGU5ZiZjdD1z/kddcu6jjEJIocIWTcx/giphy.gif'),
                        ),
                      const SizedBox(
                        width: 300,
                        child: Text(
                          "Would you like to cancel your order?",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 36,
                              child: CupertinoButton(
                                key: const Key("address_submit"),
                                color: Colors.red,
                                disabledColor: CupertinoColors.inactiveGray,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  delete(context);
                                },
                                child: Text('Cancel'.tr,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white)),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              height: 36,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  isPop = false;
                                  setState(() {
                                    isCancelable = true;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text('Back'.tr,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
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
    String order_id = widget.productHistory!.id.toString();
    List<String> errors = [];
    webService.setMethod('POST').setEndpoint('sales/orders/cancel/$order_id');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return OrderHistoryScreen();
      }));
      isPop = false;
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

  void _launchEmail() async {
    await EmailLauncher.launch(email);
  }

  void _launchWhatsapp() async {
    var url =
        'https://wa.me/60146717681?text=Hello, this is my payment proof for (INSERT PAYMENT DETAILS)';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
