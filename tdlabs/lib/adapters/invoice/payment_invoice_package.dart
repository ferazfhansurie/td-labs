import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:email_launcher/email_launcher.dart';
import 'package:tdlabs/models/util/redeem.dart';
import 'package:tdlabs/screens/history/product_history_screen.dart';
import 'package:tdlabs/utils/web_service.dart';

import '../../models/commerce/product_history.dart';
import '../../models/commerce/vending_machine.dart';
import '../../models/user/user.dart';
import '../../utils/toast.dart';

// ignore: must_be_immutable
class PaymentInvoicePackage extends StatefulWidget {
  Redeem? redeem;
  User? user;
  bool? continuePayment;
  String? fullAddress;
  String? phoneNo;
  bool? isVm;
  int? index;

  PaymentInvoicePackage({
    Key? key,
    this.redeem,
    this.user,
    this.continuePayment = false,
    this.fullAddress,
    this.phoneNo,
    this.isVm,
    this.index,
  }) : super(key: key);

  @override
  _PaymentInvoicePackageState createState() => _PaymentInvoicePackageState();
}

class _PaymentInvoicePackageState extends State<PaymentInvoicePackage> {
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
  List<VendingMachine> vendingMachine = [];
  VendingMachine? vm;
  @override
  void initState() {
    //implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    String statusName = 'Redeemed';
    Color colorStatus = Colors.green;
    Color nameColor = Colors.white;
    String? date = widget.redeem!.redeemed_at.toString();
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
                        Text(
                          "Package Details".tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(
                          width: 75,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding:const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: status(statusName, colorStatus, nameColor)),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(
                                child: SizedBox(
                                    width: 75,
                                    child: Image.asset(
                                        'assets/images/TDlogo.png'))),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text('Redeem Date: '.tr,
                                        style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                            color: Color.fromARGB(255, 104, 104, 104),
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      date,
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
                      Container(
                        width: 130,
                        color: CupertinoTheme.of(context).primaryColor,
                        child: Text('DETAILS: '.tr,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 35 / 100,
                            child: Text(
                              'Package: '.tr,
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
                              widget.redeem!.package_name!,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 35 / 100,
                            child: Text(
                              'Amount Collected: '.tr,
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
                              widget.redeem!.reward_amount!,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 130,
                                  color:CupertinoTheme.of(context).primaryColor,
                                  child: Text('User Info:'.tr,
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *35 /100,
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width *35 /100,
                                            child: Text(
                                              'Email : '.tr,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(255, 104, 104, 104),
                                                  fontFamily: 'Montserrat',
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
                                    color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    String orderId = widget.redeem!.package_id.toString();
    List<String> errors = [];
    webService.setMethod('POST').setEndpoint('sales/orders/cancel/$orderId');
    var response = await webService.send();
    if (response == null) return ;
    if (response.status) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return OrderHistoryScreen();
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
}
