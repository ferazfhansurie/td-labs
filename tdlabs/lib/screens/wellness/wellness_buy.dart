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
import 'package:tdlabs/screens/wellness/wellness_commercial.dart';

class WellnessBuyScreen extends StatefulWidget {
  List<Map<String, dynamic>>? orderList;
  List<Map<String, dynamic>>? orderNameList;
  Catalog? product;
  List<dynamic>? voucherList;
  WellnessBuyScreen(
      {Key? key,
      this.orderList,
      this.orderNameList,
      this.product,
      this.voucherList})
      : super(key: key);

  @override
  State<WellnessBuyScreen> createState() => _WellnessBuyScreenState();
}

class _WellnessBuyScreenState extends State<WellnessBuyScreen> {
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
                          width: MediaQuery.of(context).size.width * 17 / 100,
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
                
             Padding(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 52, 169, 176),
                            Color.fromARGB(255, 49, 42, 130),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                 
                                      double price =
                                          double.parse(widget.product!.price!);
                                      double quantity = 1;
                                      if (mounted) {
                                        setState(() {
                                          widget.orderList![0]['price'] = price;
                                          widget.orderList![0]['total'] = price *
                                              quantity; // assign total to product called
                                          widget.orderList![0]['product_id'] =
                                              widget.product!.id;
                                          widget.orderList![0]['quantity'] = 1;
                                          widget.orderList![0]['cart_type'] = 0;
                                          widget.orderNameList![0]
                                                  ['product_name'] =
                                              widget.product!.name;
                                          widget.orderNameList![0]
                                                  ['product_url'] =
                                              widget.product!.image_url;
                                          widget.orderNameList![0]['quantity'] =
                                              1;
                                        });
                                      }
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return CheckoutWellnessScreen(
                                          vendingMachine: null,
                                          originalPrice: widget.product!.price,
                                          orderList: widget.orderList,
                                          orderNameList: widget.orderNameList!,
                                          method: 0,
                                          vm_id: 0,
                                       
          product: widget.product,
          voucherList: widget.voucherList,
                                        );
                                      }));
                                
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(
                                                      255, 236, 236, 236)
                                                  .withOpacity(0.4),
                                              spreadRadius: 2,
                                              blurRadius: 1,
                                              offset: const Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                          child: Icon(Icons.qr_code_rounded,
                                              size: 50),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: SizedBox(
                                          width: 90,
                                          child: Text(
                                             'Buy',
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: SizedBox(
                                child: Text(
                                   'Tap Icon to Buy Now'.tr,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontFamily: 'Montserrat',
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
               
              ],
            )));
  }
}
