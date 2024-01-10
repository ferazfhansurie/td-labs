// ignore_for_file: prefer_const_constructors_in_immutables, non_constant_identifier_names, library_prefixes, must_be_immutable, unnecessary_null_comparison

import 'dart:convert';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/commerce/product.dart';
import 'package:tdlabs/models/commerce/product_history.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/screens/history/product_history_screen.dart';
import 'package:tdlabs/screens/wellness/qiaolz.dart';
import 'package:tdlabs/screens/wellness/wellness_commercial.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/screens/wellness/wellness_type.dart';
import '../../adapters/webview/inAppWebViewPayment.dart';
import '../../global.dart' as global;
import 'package:get/get.dart' as Get;

class CheckoutWellnessConfirmation extends StatefulWidget {
  CheckoutWellnessConfirmation(
      {Key? key,
      this.name,
      this.email,
      this.contact,
      this.fullAddress,
      this.message,
      this.orderList,
      this.items,
      this.address,
      required this.voucherId,
      this.voucherCode,
      this.voucherChild,
      this.finalPrice,
      this.shippingFees,
      this.orignalShipping,
      this.originalPrice,
      this.discountPrice,
      this.discountPrice2,
      this.use_credit,
      this.vendingMachine,
      this.method,
      this.delivery,
      this.vm_id,
      this.longitude,
      this.latitude,
      this.quotation,
      this.orderNameList,
      this.product,
      this.voucherList,
      this.shipping_discount_price})
      : super(key: key);

  final List<Map<String, dynamic>>? address;
  final String? contact;
  String? delivery;
  final String? discountPrice;
  final String? discountPrice2;
  final String? email;
  final String? finalPrice;
  final String? fullAddress;
  final String? items;
  String? latitude;
  String? longitude;
  final String? message;
  int? method;
  final String? name;
  final List<Map<String, dynamic>>? orderList;
    List<Map<String, dynamic>>? orderNameList;
  final String? originalPrice;
  final String? orignalShipping;
  Catalog? product;
  String? quotation;
  final String? shippingFees;
  String? shipping_discount_price;
  final int? use_credit;
  final VendingMachine? vendingMachine;
  int? vm_id;
  final String? voucherChild;
  final String? voucherCode;
  final int voucherId;
  List<dynamic>? voucherList;

  @override
  _CheckoutWellnessConfirmationState createState() =>
      _CheckoutWellnessConfirmationState();
}

class _CheckoutWellnessConfirmationState extends State<CheckoutWellnessConfirmation> {
  static final facebookAppEvents = FacebookAppEvents();

  bool bankTransferActive = true;
  bool creditStoreActive = false;
  String? hash;
  int? id;
  List<ProductHistory> list = [];
  bool onlinePaymentActive = false;
  int paymentMethod = 2;
  List<Map<String, dynamic>> paymentMethodList = [];
  Map<String, String> stateList = {
    'all': '',
    'my-01': 'Johor',
    'my-02': 'Kedah',
    'my-03': 'Kelantan',
    'my-04': 'Melaka',
    'my-05': 'Negeri Sembilan',
    'my-06': 'Pahang',
    'my-07': 'Pulau Pinang',
    'my-08': 'Perak',
    'my-09': 'Perlis',
    'my-10': 'Selangor',
    'my-11': 'Terengganu',
    'my-12': 'Sabah',
    'my-13': 'Sarawak',
    'my-14': 'Kuala Lumpur',
    'my-15': 'Labuan',
    'my-16': 'Putrajaya',
  };

  String? url;
  User? user;
  VendingMachine? vm;

  List<dynamic> _voucherList = [];

  @override
  void initState() {
    //implement initState
    super.initState();
    if (widget.vendingMachine != null) {
      vm = widget.vendingMachine;
    }
    getPaymentMethods(context);
  }

  Widget displayInformation(String title, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 20 / 100,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 104, 104, 104),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Text(
                  (info != null) ? info : '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void fetchUser() async {
    User? userdata = await User.fetchOne(context);
    user = userdata;
  }

  bool checkContinuePayment(ProductHistory productHistory) {
    if (productHistory.statusLabel == 'Submitted' &&
        productHistory.paymentMethod == 2) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> fetchAddress(ProductHistory productHistory) {
    Map<String, dynamic> address = {};
    if (productHistory.orderAddress != null) {
      address.addAll({'address_1': productHistory.orderAddress!.address_1});
      address.addAll({'address_2': productHistory.orderAddress!.address_2});
      address.addAll({'postcode': productHistory.orderAddress!.postcode});
      address.addAll({'city': productHistory.orderAddress!.city});
      address.addAll({'state': productHistory.orderAddress!.stateCode});
    }

    return address;
  }

  String fetchFullAddress(Map<String, dynamic> address) {
    String stateName = (stateList[address['state']] != null)
        ? stateList[address['state']]!
        : "";
    if (address.isNotEmpty) {
      return address['address_1'] +
          ' ' +
          address['address_2'] +
          ',' +
          address['postcode'] +
          ',' +
          address['city'] +
          ',' +
          stateName;
    }

    return '';
  }

  Future<List<Map<String, dynamic>>?> getPaymentMethods(
      BuildContext context) async {
    WebService webService = WebService(context);
    webService.setMethod('GET').setEndpoint('payment/methods');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      if (mounted) {
        setState(() {
          paymentMethodList =
              jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
          bankTransferActive = checkPaymentList(1);
          onlinePaymentActive = checkPaymentList(2);
          creditStoreActive = checkPaymentList(3);
        });
      }
    }
    return paymentMethodList;
  }

  bool checkPaymentList(int id) {
    for (var map in paymentMethodList) {
      // ignore: curly_braces_in_flow_control_structures
      if (map.containsKey('id')) if (map['id'] == id) {
        return true;
      }
    }
    return false;
  }

  Widget _checkoutInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Payment'.tr,
          style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              color: CupertinoTheme.of(context).primaryColor,
              fontWeight: FontWeight.w300),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          fontSize: 15,
                          color: Color.fromARGB(255, 104, 104, 104),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 60),
                        child: Text(
                          'RM ${widget.originalPrice!}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.orignalShipping != null &&
                  widget.orignalShipping != "0.0")
                Visibility(
                  visible: (widget.orignalShipping != null ||
                      widget.orignalShipping != "0.0"),
                  replacement: Container(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shipping fees'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Color.fromARGB(255, 104, 104, 104),
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 60),
                            child: Text(
                              (widget.orignalShipping != "0.0")
                                  ? '+ RM ${widget.orignalShipping!}'
                                  : '',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Visibility(
                visible: (widget.discountPrice != "0"),
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
                            fontSize: 15,
                            color: Color.fromARGB(255, 104, 104, 104),
                            fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 60),
                          child: Text(
                            (widget.discountPrice != null)
                                ? '- RM${widget.discountPrice}'
                                : '',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: (widget.use_credit != 0),
                replacement: Container(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Points'.tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            color: Color.fromARGB(255, 104, 104, 104),
                            fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 60),
                          child: Text(
                            (widget.use_credit != 0)
                                ? '- RM ${widget.discountPrice2}'
                                : '',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                fontWeight: FontWeight.w300),
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
                    fontSize: 15,
                    color: Color.fromARGB(255, 104, 104, 104),
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 60),
                  child: Text(
                    'RM ${widget.finalPrice!}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: CupertinoTheme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _information() {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Checkout Summary'.tr,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                    color: CupertinoTheme.of(context).primaryColor),
              ),
            ),
            displayInformation('Name'.tr, widget.name!),
            displayInformation('Contact'.tr, widget.contact!),
            displayInformation('Item'.tr, widget.items!),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Payment'.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  color: Color.fromARGB(255, 104, 104, 104),
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'RM ${widget.finalPrice!}',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  color: CupertinoTheme.of(context).primaryColor),
            ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Visibility(
          visible: paymentMethod != 0 && widget.finalPrice != null,
          replacement: Container(
            color: CupertinoColors.inactiveGray,
            height: MediaQuery.of(context).size.height * 8 / 100,
            width: MediaQuery.of(context).size.width * 20 / 100,
            child: Center(
              child: Text(
                'Confirm'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: CupertinoColors.white),
              ),
            ),
          ),
          child: GestureDetector(
            key: const Key("confirm"),
            onTap: () {
              _submitForm(context);
            },
            child: Container(
              color: CupertinoTheme.of(context).primaryColor,
              height: MediaQuery.of(context).size.height * 8 / 100,
              width: MediaQuery.of(context).size.width * 20 / 100,
              child: Center(
                  child: Text(
                'Confirm'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: CupertinoColors.white),
              )),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    widget.orderList!.removeWhere((element) => element['product_id'] == '');
    Product product = Product();
    ProductHistory productHistory = ProductHistory();
    if (productHistory.orderAddress != null) {}
    setState(() {
      if (vm == null && widget.method == 0 && widget.delivery != "Lalamove") {
        product.name = widget.name;
        product.email = widget.email;
        product.phone_no = widget.contact;
        product.items = widget.orderList;
        product.voucher_id = widget.voucherId;
        product.voucher_child = (widget.voucherChild != null)
            ? int.parse(widget.voucherChild!)
            : null;
        product.payment_method = paymentMethod;
        product.shippingFees =
            (widget.shippingFees != null) ? widget.shippingFees : null;
        product.original_shipping_price =
            (widget.orignalShipping != null) ? widget.orignalShipping : "0";
        product.original_shipping_price =
            (widget.orignalShipping != null) ? widget.orignalShipping : "0";
        product.payment_method_id = paymentMethod;
        product.use_credit = widget.use_credit;
        product.pickup_type = 2;
        product.delivery_provider = 0;
        product.vm_id = 0;
        product.price = widget.finalPrice;
        product.latitude = null;
        product.longitude = null;
        product.quotation_id = null;
      } else if (widget.method == 1 && widget.delivery != "Lalamove") {
        product.name = widget.name;
        product.email = widget.email;
        product.phone_no = widget.contact;
        product.order_remark = widget.message;
        product.items = widget.orderList;
        product.voucher_id = widget.voucherId;
        product.voucher_child = (widget.voucherChild != null)
            ? int.parse(widget.voucherChild!)
            : null;
        product.payment_method = paymentMethod;
        product.shippingFees = "0";
        product.payment_method_id = paymentMethod;
        product.use_credit = widget.use_credit;
        product.pickup_type = 2;
        product.delivery_provider = 0;
        product.vm_id = widget.vm_id;
        product.price = widget.finalPrice;
        product.address_1 = null;
        product.address_2 = null;
        product.postcode = null;
        product.city = null;
        product.state_code = null;
      } else if (vm == null &&
          widget.method == 0 &&
          widget.delivery == "Lalamove") {
        product.name = widget.name;
        product.email = widget.email;
        product.phone_no = widget.contact;
        product.address_1 = widget.address![0]['address1'];
        product.address_2 = widget.address![0]['address2'];
        product.postcode = widget.address![0]['postcode'];
        product.city = widget.address![0]['city'];
        product.state_code = widget.address![0]['state_code'];
        product.order_remark = widget.message;
        product.items = widget.orderList;
        product.voucher_id = widget.voucherId;
        product.voucher_child = (widget.voucherChild != null)
            ? int.parse(widget.voucherChild!)
            : null;
        product.payment_method = paymentMethod;
        product.shippingFees =
            (widget.shippingFees != null) ? widget.shippingFees : null;
        product.payment_method_id = paymentMethod;
        product.use_credit = widget.use_credit;
        product.pickup_type = 2;
        product.delivery_provider = 1;
        product.vm_id = 0;
        product.price = widget.finalPrice;
        product.latitude = widget.latitude;
        product.longitude = widget.longitude;
        product.quotation_id = widget.quotation;
      } else {
        product.name = widget.name;
        product.email = widget.email;
        product.phone_no = widget.contact;
        product.order_remark = widget.message;
        product.items = widget.orderList;
        product.voucher_id = widget.voucherId;
        product.voucher_child = (widget.voucherChild != null)
            ? int.parse(widget.voucherChild!)
            : null;
        product.address_1 = widget.address![0]['address1'];
        product.address_2 = widget.address![0]['address2'];
        product.postcode = widget.address![0]['postcode'];
        product.city = widget.address![0]['city'];
        product.state_code = widget.address![0]['state_code'];
        product.payment_method = paymentMethod;
        product.shippingFees =
            (widget.orignalShipping != null) ? widget.orignalShipping : "0";
        product.original_shipping_price =
            (widget.orignalShipping != null) ? widget.orignalShipping : "0";
        product.shipping_discount =
            (widget.discountPrice != null) ? widget.discountPrice : "0";
        product.payment_method_id = paymentMethod;
        product.use_credit = widget.use_credit;
        product.pickup_type = 2;
        product.delivery_provider = 1;
        product.vm_id = widget.vm_id;
        product.price = widget.finalPrice;
        product.latitude = widget.latitude;
        product.longitude = widget.longitude;
        product.quotation_id = widget.quotation;
      }
    });

    if (id == null && hash == null) {
      List<String> errors = Product.validate(product);
      final GlobalKey progressDialogKey = GlobalKey<State>();
      ProgressDialog.show(context, progressDialogKey);
      var response = await Product.create(context, product);
      print(response!.body);
      ProgressDialog.hide(progressDialogKey);
      if (response != null) {
        if (response.status) {
          var array = jsonDecode(response.body.toString());
          if (paymentMethod == 1) {
            facebookAppEvents.logPurchase(
              amount: double.parse(product.price!),
              currency: "MYR",
              parameters: {
                'product_name': product.name,
              },
            );
            global.updateTestScreen = true;
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return OrderHistoryScreen();
            }));
            Toast.show(context, 'default', 'Order created');
          } else {
            hash = array['hash'];
            id = array['id'];
            var response = await ProductHistory.fetchHistory2(context, id!);
            if (response != null) {
              if (response.status) {
                setState(() {
                  ProductHistory productHistory2 = ProductHistory.fromJson(
                      jsonDecode(response.body.toString()));
                  list.add(productHistory2);
                  fetchUser();
                });
              }
            }
            String status;
            if (mounted) {
              setState(() {
                productHistory.id = id;
                productHistory.hash = hash!;
                if (!MainConfig.modeLive) {
                  url =
                      'https://dev.tdlabs.co/payment/gateway/execute?id=$id&hash=$hash';
                } else {
                  url =
                      'https://cloud.tdlabs.co/payment/gateway/execute?id=$id&hash=$hash';
                }
              });
            }
            status = await Navigator.of(context)
                .push(CupertinoPageRoute(builder: (context) {
              return WebViewScreen(
                url: url!,
                title: 'Payment Gateway'.tr,
              );
            }));
            if (status == '0') {
              fetchUser();
            
               _fetchProducts(context);
              Toast.show(context, 'default', 'Payment Successful');
            } else if (status == '1' && widget.finalPrice == "0.00") {
              fetchUser();
             
              _fetchProducts(context);
            } else if (status == '1') {
              Toast.show(context, 'default', 'Transaction Declined');
            } else {
              Toast.show(context, 'danger', 'Error');
            }
          }
        } else {
         Toast.show(context, 'danger', response.error.values.toList()[0]);
         
        }
      } else if (response.error.isNotEmpty) {
        errors.add(response.error.values.toList()[0]);
      } else {
        errors.add('Server connection timeout.');
      }
      if (errors.isNotEmpty) {
        Toast.show(context, 'danger', errors[0]);
      }
    } else {
      String status = await Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) {
        return WebViewScreen(
          url: url!,
          title: 'Payment Gateway'.tr,
        );
      }));
      if (status == '0') {
       
        _fetchProducts(context);
        Toast.show(context, 'default', 'Payment Successful');
      } else if (status == '1' && widget.finalPrice == "0.00") {
      
      } else if (status == '1') {
        Toast.show(context, 'default', 'Transaction Declined');
      } else {
        Toast.show(context, 'danger', 'Error');
      }
    }
  }

   Future<void> _fetchProducts(BuildContext context) async {
    final webService = WebService(context);
    webService.setEndpoint('catalog/catalog-products');
    Map<String, String> filter = {};
    filter.addAll({'type': '5'});

    var response = await webService.setFilter(filter).send();
    print(response!.body);
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Catalog> products =
          parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          List<Map<String, dynamic>> orderList = [];
          List<Map<String, dynamic>> orderNameList = [];
          orderList.add({
            'product_id': products[0].id,
            'quantity': 1,
            'price': products[0].price,
            'total': 1,
            'cart_type': 0
          });
          orderNameList.add({
            'product_name': products[0].name,
            'product_url': products[0].image_url,
            'quantity': 1,
          });
     
          _fetchVoucher(orderList, orderNameList, products);
        });
      }
    }
  }

  Future<void> _fetchVoucher(List<Map<String, dynamic>> orderList,
      List<Map<String, dynamic>> orderNameList, List<Catalog> products) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('catalog/voucher-codes');
    var response = await webService.send();
    print(response!.body);
    if (response.status) {
      _voucherList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      Navigator.of(context).push(
                                            CupertinoPageRoute(
                                                builder: (context) {
                                          return BluetoothDiscoveryScreen(
                                            voucher_id: _voucherList[0]['id'].toString(),
                                            type: 0,       orderList: widget.orderList,
          orderNameList: widget.orderNameList,
          product: widget.product,
          voucherList: widget.voucherList,
                                          );
                                        }));
    } else {
    Navigator.of(context).push(
                                            CupertinoPageRoute(
                                                builder: (context) {
                                          return BluetoothDiscoveryScreen(
                                            voucher_id: _voucherList[0]['id'].toString(),
                                            type: 0,
                                          );
                                        }));
                                   
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: CupertinoPageScaffold(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
               
              ),
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Background-02.png"),
                    fit: BoxFit.fill),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
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
                                "Check Out Confirmation".tr,
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
                      _information(),
                      Card(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: _checkoutInfo(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 8 / 100,
          child: _bottomNavbar(),
        ));
  }
}
