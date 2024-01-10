// ignore_for_file: must_be_immutable, body_might_complete_normally_nullable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import '../../models/screening/opt_test.dart';
import '../../models/screening/test.dart';
import '../../utils/web_service.dart';
class PaymentInvoice extends StatefulWidget {
  int? testId;
  PaymentInvoice({
    Key? key,
    this.testId,
  }) : super(key: key);
  @override
  _PaymentInvoiceState createState() => _PaymentInvoiceState();
}
class _PaymentInvoiceState extends State<PaymentInvoice> {
  Test? _test;
  int? _testId;
  String _type = '';
  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    _testId = widget.testId;
    if (_isLoading == true) {
      _getContent();
      return CupertinoPageScaffold(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            color: Colors.white,
            child: Text('Loading'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: Colors.black87)),
          ),
        ),
      );
    } else {
      return CupertinoPageScaffold(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.only(top: 5),
          padding: EdgeInsets.only(
             
              bottom: MediaQuery.of(context).padding.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _invoiceInfo(),
                _paymentInfo(),
                _userInfo(),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _invoiceInfo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_fill,
                  color: CupertinoTheme.of(context).primaryColor,
                  size: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'TDLabs',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    'Date: '.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                  Text(
                    _test!.createdAtText!,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Reference No: '.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                  Text(
                    _test!.refNo!,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentInfo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130,
            color: CupertinoTheme.of(context).primaryColor,
            child: Text(
              'PAYMENT DETAILS: '.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.w300),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 35 / 100,
                child: Text(
                  'Point of care : '.tr,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Text(
                _test!.poc!.name!,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
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
                  'Type : '.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Text(
                _type,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
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
                  'Address : '.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Expanded(
                child: Text(
                  _test!.poc!.address!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
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
                  'Appointment Date : '.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(_test!.appointmentAt!).toString(),
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
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
                  'Session : '.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Text(
                _test!.session_name!,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
          const Divider(
            height: 10,
            thickness: 2,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _userInfo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130,
            color: CupertinoTheme.of(context).primaryColor,
            child: Text(
              'BILLING TO:'.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat', 
                  fontWeight: FontWeight.w300),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 35 / 100,
                child: Text(
                  'Name : '.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Text(
                _test!.user!.name!,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 35 / 100,
                child: const Text(
                  'Phone No. : ',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Text(
                _test!.user!.phoneNo!,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
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
                  'Email : '.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Text(
                _test!.user!.email!,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
          const Divider(
            height: 10,
            thickness: 2,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  Future<Test?> _getContent() async {
    final webService = WebService(context);
    // get single test model
    var response = await webService.setEndpoint('screening/tests/' + _testId.toString()).setExpand('poc,user').send();
    if (response == null) return null;
    if (response.status) {
      var modelArray = jsonDecode(response.body.toString());
      _test = Test.fromJson(modelArray);
      if (OptTest.typeEnum.containsKey(_test!.type)) {
        _type = OptTest.typeEnum[_test!.type]!;
      }
      setState(() {
        _isLoading = false;
      });
      return _test;
    }
  }
}
