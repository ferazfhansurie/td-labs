// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../adapters/invoice/payment_invoice.dart';
class TransferDetails extends StatefulWidget {
  int? testID;
   String? name;
  TransferDetails({Key? key, this.testID,this.name}) : super(key: key);
  @override
  _TransferDetailsState createState() => _TransferDetailsState();
}
class _TransferDetailsState extends State<TransferDetails> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/Background-02.png"),
                  fit: BoxFit.fill),
            ),
            child: ListView(
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 8 / 100,
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3),
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
                        Text(
                          "Transfer Details".tr,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                            key: const Key("done"),
                            onTap: () {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            child: Text("Done".tr,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w300,
                                    color: Color.fromARGB(255, 255, 255, 255)))),
                      ],
                    ),
                  ),
                ),
                PaymentInvoice(
                  testID: widget.testID,
                )
              ],
            )),
      ),
    ));
  }
}
