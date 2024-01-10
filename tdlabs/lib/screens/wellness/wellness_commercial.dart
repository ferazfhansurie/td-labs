// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/commerce/product_history.dart';
import 'package:tdlabs/screens/wellness/checkout_wellness.dart';
import 'package:tdlabs/screens/wellness/qiaolz.dart';
import 'package:tdlabs/screens/wellness/wellness_type.dart';

class WellnessCommersialScreen extends StatefulWidget {
  List<Map<String, dynamic>>? orderList;
  List<Map<String, dynamic>>? orderNameList;
  Catalog? product;
  List<dynamic>? voucherList;
  WellnessCommersialScreen(
      {Key? key,
      this.orderList,
      this.orderNameList,
      this.product,
      this.voucherList})
      : super(key: key);

  @override
  State<WellnessCommersialScreen> createState() => _WellnessCommersialScreenState();
}

class _WellnessCommersialScreenState extends State<WellnessCommersialScreen> {
  List<ProductHistory> list = [];

  List<int> orderQuantityList = [];
  bool bought = false;
  @override
  void initState() {
    super.initState();
   
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: const Color.fromARGB(255, 242, 242, 244),
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(
          
            ),
            child: Column(
              children: [
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
                  child: Padding(
                     padding: EdgeInsets.only(
              top: 30,
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
                          width: MediaQuery.of(context).size.width * 16 / 100,
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 75,
                          child: Text(
                            "Teda Wellness Pro".tr,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  )),
                        SizedBox(height: 15,),
                         Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                     
                                   Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return WellnessTypeScreen(
          orderList: widget.orderList,
          orderNameList: widget.orderNameList,
          product: widget.product,
          voucherList: widget.voucherList,
        );
      }));
                   
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(36)),
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 52, 169, 176),
                                  Color.fromARGB(255, 52, 169, 176),
                                  Color.fromARGB(255, 52, 169, 176),

                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Image.asset('assets/images/icon-01.png'),
                            ),
                          ),
                        ),
                      ),
                  ),
                     Center(
                       child: Container(
                        width: 175,
                        alignment: Alignment.center,
                         child: Text(
                              "Traditional Chinese Medicine".tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                       ),
                     ),
                ],
              ),
              SizedBox(height: 30,),
              
                Column(
                  children: [
                    GestureDetector(
                      onTap: (){
                                          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return WellnessTypeScreen(
          orderList: widget.orderList,
          orderNameList: widget.orderNameList,
          product: widget.product,
          voucherList: widget.voucherList,
        );
      }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(36)),
                              gradient: LinearGradient(
                                colors: [
                                   Color.fromARGB(255, 52, 169, 176),
                                  Color.fromARGB(255, 52, 169, 176),
                                  Color.fromARGB(255, 52, 169, 176),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child:  Image.asset('assets/images/icon-02.png')
                            ),
                          ),
                        ),
                      ),
                    ),
                      Text(
                          "E-Doctor".tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                  ],
                ),
              
              ],
            )));
  }
}
