// ignore_for_file: library_prefixes, non_constant_identifier_names, unnecessary_null_comparison, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlabs/models/commerce/cart.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:get/get.dart' as Get;
import 'package:tdlabs/screens/user/address_form.dart';
import 'package:tdlabs/screens/voucher/voucher_select_product.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/form/text_input.dart';
import 'package:transparent_image/transparent_image.dart';
import 'checkout_product_confirmation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

// ignore: must_be_immutable
class CheckoutProductScreen extends StatefulWidget {
  String? originalPrice;
  List<Map<String, dynamic>>? cart;
  List<Map<String, dynamic>>? orderList;
  List<Map<String, dynamic>>? orderNameList;
  int? method;
  VendingMachine? vendingMachine;
  List<Map<String, dynamic>>? address;
  String? fulladdress;
  String? stateName;
  int? vm_id;
  Catalog? stockList;
  int? index;
  int? from;
  bool? free;
  CheckoutProductScreen(
      {Key? key,
      this.cart,
      this.originalPrice,
      this.orderList,
      this.orderNameList,
      this.fulladdress,
      this.stateName,
      this.address,
      this.vm_id,
      this.vendingMachine,
      this.stockList,
      this.index,
      this.method,
      this.from,
      this.free})
      : super(key: key);
  @override
  _CheckoutProductScreenState createState() => _CheckoutProductScreenState();
}

class _CheckoutProductScreenState extends State<CheckoutProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactNumController = TextEditingController();
  final messageController = TextEditingController();
  List<Map<String, dynamic>> unavailableNameList = [];
  String? email;
  String items = "";
  int use_credit = 0;
  String json = '';
  int state = 0;
  double credit = 0;
  String available_credit = "0";
  String? credit_discount;
  Map<String, dynamic>? _shippingList;
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
  String? stateName;
  int? stateIndex;
  String fullAddress = '';
  String moveAddress = '';
  String delivery = '';
  List<Map<String, dynamic>> address = [];
  List<Map<String, dynamic>> shippingFeesList = [];
  List<dynamic> shippingType = [];
  int pickerIndexshipping = 0;
  String shippingFees = "0.0";
  String point = "0";
  String points_used = "0";
  String? finalPrice;
  String? address1;
  String? address2;
  String? postcode;
  String? city;
  String? stateCode;
  String? voucherCode;
  int? voucherId;
  String? voucherChild;
  String? newPrice;
  String discountPrice = "0";
  String discountPrice2 = "0";
  int? discountMethod;
  Map<dynamic, dynamic>? returnResult = {};
  bool isSwitched = false;
  List<VendingMachine> vending = [];
  VendingMachine? vm;
  List<Catalog> stock = [];
  List<Catalog> newList = [];
  List<Map<String, dynamic>>? newNameList = [];
  List<Map<String, dynamic>>? newOrderList = [];
  String unavailableItem = "";
  List<int> unIndex = [];
  int index = 0;
  int unavailable = 0;
  String latitude = "";
  String longitude = "";
  String quotation_id = "";
  int type = 0;
  String location = "";
  int itemLength = 0;
  String orignalShipping = "0.0";
  String? shipping_discount_price;
  final GlobalKey progressDialogKey = GlobalKey<State>();
  late FocusNode _focusNode;
  @override
  void initState() {
    // implement initState
    super.initState();
    vm = widget.vendingMachine;
    _focusNode = FocusNode();

    fetchDelivery();
    _populateForm();
    if (items.isEmpty) {
      assignItems();
      itemLength = widget.orderNameList!.length;
    }
    if (widget.free == true) {
      fetchFreeDiscount();
    }
  }

  void _pop() {
    widget.orderNameList!.clear();
    widget.orderList!.clear();
    if (widget.from == 3) {
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: WillPopScope(
          onWillPop: () async {
            const shouldPop = true;
            _pop();
            return shouldPop;
          },
          child: GestureDetector(
            onTap: () {
              if (_focusNode.hasFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Background-02.png"),
                    fit: BoxFit.fill),
              ),
              padding: EdgeInsets.only(
                top: 30,
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
                                onTap: () async {
                                  _pop();
                                },
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 35,
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
                      _checkoutDetails(),
                      Card(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _itemsListCard(),
                              _shippingDetailsCard(),
                              _redemptionCard(),
                            ],
                          ),
                        ),
                      ),
                      _paymentDetailsCard()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 8 / 100,
          child: _bottomNavbar()),
    );
  }

  Widget _checkoutDetails() {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Details'.tr,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                  color: CupertinoTheme.of(context).primaryColor),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextInput(
                    label: 'Name'.tr,
                    prefixWidth: 80,
                    controller: nameController,
                    maxLength: 255,
                    required: true,
                  ),
                  TextInput(
                    label: 'Contact'.tr,
                    controller: contactNumController,
                    prefixWidth: 80,
                    maxLength: 12,
                    type: 'phoneNo',
                    required: true,
                    focusNode: _focusNode,
                  ),
                  (widget.vendingMachine == null && widget.method == 0 ||
                          delivery == "Lalamove")
                      ? GestureDetector(
                          key: const Key("address"),
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            await _fetchAddress();
                            if (voucherCode != null) {
                              clearDiscount();
                            }
                            if (isSwitched == true) {
                              setState(() {
                                use_credit = 0;
                                isSwitched = false;
                              });

                              clearDiscountPoint();
                            }
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: const BoxDecoration(
                              color: CupertinoColors.white,
                              border: Border(
                                bottom: BorderSide(
                                    color: CupertinoColors.systemGrey5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Address'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 104, 104, 104),
                                      ),
                                    ),
                                    Visibility(
                                      visible: (fullAddress == ''),
                                      replacement: Container(
                                        width: 10,
                                      ),
                                      child: Row(
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.only(left: 25),
                                            child: Text(
                                              "Please fill in address",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 207, 207, 207),
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                          SizedBox(width: 2),
                                          Icon(
                                            CupertinoIcons
                                                .exclamationmark_circle_fill,
                                            size: 6,
                                            color: CupertinoColors.systemRed,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Text(
                                      (fullAddress != '') ? fullAddress : '',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  TextInput(
                    label: 'Message'.tr,
                    controller: messageController,
                    prefixWidth: 80,
                    maxLength: 255,
                    required: false,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            Text(
                              'Delivery'.tr,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 104, 104, 104),
                              ),
                            ),
                          ],
                        ),
                        if (shippingType.isNotEmpty)
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                                reverse: true,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.of(context).padding.bottom),
                                physics: const AlwaysScrollableScrollPhysics(),
                                //lalamove
                                itemCount: (widget.vm_id == 0)
                                    ? 1
                                    : (shippingType.length == 2)
                                        ? 2
                                        : 1,
                                itemBuilder: (context, index) {
                                  String shippingtype =
                                      shippingType[index]['name'];
                                  return GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        if (shippingType[index]['value'] == 0 ||
                                            shippingType[index]['value'] == 1) {
                                          delivery =
                                              shippingType[index]['name'];
                                          shippingFees = "0.0";
                                          finalPrice = widget.originalPrice;
                                          fullAddress = "";
                                          type = 0;
                                          orignalShipping = '0.0';
                                        } else {
                                          delivery =
                                              shippingType[index]['name'];
                                          fullAddress = "";
                                          shippingFees = "";
                                          type = 1;
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Column(
                                        children: [
                                          (shippingType[index]['value'] == 0 ||
                                                  shippingType[index]
                                                          ['value'] ==
                                                      1)
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Card(
                                                    color: (delivery ==
                                                                "Normal Delivery" ||
                                                            delivery ==
                                                                "Self Pickup")
                                                        ? CupertinoTheme.of(
                                                                context)
                                                            .primaryColor
                                                        : Colors.white,
                                                    elevation: 5,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Icon(
                                                        (widget.method == 0)
                                                            ? Icons
                                                                .local_shipping_outlined
                                                            : Icons
                                                                .shopping_bag_outlined,
                                                        color: (delivery ==
                                                                    "Normal Delivery" ||
                                                                delivery ==
                                                                    "Self Pickup")
                                                            ? Colors.white
                                                            : CupertinoTheme.of(
                                                                    context)
                                                                .primaryColor,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Card(
                                                    color:
                                                        (delivery == "Lalamove")
                                                            ? CupertinoTheme.of(
                                                                    context)
                                                                .primaryColor
                                                            : Colors.white,
                                                    elevation: 5,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Image.asset(
                                                        "assets/images/lalamove_logo.png",
                                                        height: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          Text(
                                            shippingtype.tr,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'Montserrat',
                                              color: Color.fromARGB(
                                                  255, 104, 104, 104),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          (shippingType[index]['value'] == 0 ||
                                                  shippingType[index]
                                                          ['value'] ==
                                                      1)
                                              ? Text(
                                                  ("Standard".tr),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontFamily: 'Montserrat',
                                                    color: (delivery !=
                                                            "Lalamove")
                                                        ? CupertinoTheme.of(
                                                                context)
                                                            .primaryColor
                                                        : const Color.fromARGB(
                                                            255, 104, 104, 104),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : Text(
                                                  ("Same Day".tr),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontFamily: 'Montserrat',
                                                    color: (delivery ==
                                                            "Lalamove")
                                                        ? CupertinoTheme.of(
                                                                context)
                                                            .primaryColor
                                                        : const Color.fromARGB(
                                                            255, 104, 104, 104),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemsListCard() {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5),
        ),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              'Items'.tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 104, 104, 104),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: (widget.cart != null)
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: widget.cart!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (itemLength > 1) {
                            setState(() {
                              itemLength = itemLength - 1;
                            });
                          }
                        },
                        child: SizedBox(
                          height: 65,
                          width: 300,
                          child: Card(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  (widget.cart![index]['image_url'] != null)
                                      ? SizedBox(
                                          width: 75,
                                          height: 60,
                                          child: FadeInImage.memoryNetwork(
                                              placeholder: kTransparentImage,
                                              image: widget.cart![index]
                                                      ['image_url']
                                                  .toString(),
                                              fit: BoxFit.cover),
                                        )
                                      : const SizedBox(
                                          width: 75,
                                          height: 75,
                                          child: Icon(CupertinoIcons.cart),
                                        ),
                                  Container(
                                      alignment: Alignment.topLeft,
                                      width: 175,
                                      padding: const EdgeInsets.all(5),
                                      child: Column(
                                        children: [
                                          Text(
                                            widget.cart![index]['name'],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Montserrat',
                                              color: Color.fromARGB(
                                                  255, 104, 104, 104),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "RM " +
                                                widget.cart![index]['price']
                                                    .toString(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'Montserrat',
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )),
                                  Container(
                                    height: 66,
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "x" +
                                          widget.cart![index]['quantity']
                                              .toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  if (widget.cart!.length > 1)
                                    GestureDetector(
                                      onTap: () {
                                        if (widget.cart!.length > 1) {
                                          List<Map<String, dynamic>> tempList =
                                              [];
                                          tempList.add(widget.cart![index]);
                                          _removeItem(tempList, index);
                                        }
                                      },
                                      child: Card(
                                        color: Colors.red,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: itemLength,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (itemLength > 1) {
                            setState(() {
                              itemLength = itemLength - 1;
                              widget.orderNameList!.removeAt(index);
                            });
                          }
                        },
                        child: SizedBox(
                          height: 65,
                          width: 300,
                          child: Card(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  (widget.orderNameList![index]
                                              ['product_url'] !=
                                          null)
                                      ? SizedBox(
                                          width: 75,
                                          height: 60,
                                          child: FadeInImage.memoryNetwork(
                                              placeholder: kTransparentImage,
                                              image: widget
                                                  .orderNameList![index]
                                                      ['product_url']
                                                  .toString(),
                                              fit: BoxFit.cover),
                                        )
                                      : const SizedBox(
                                          width: 75,
                                          height: 75,
                                          child: Icon(CupertinoIcons.cart),
                                        ),
                                  Container(
                                      alignment: Alignment.topLeft,
                                      width: 175,
                                      padding: const EdgeInsets.all(5),
                                      child: Column(
                                        children: [
                                          Text(
                                            widget.orderNameList![index]
                                                ['product_name'],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Montserrat',
                                              color: Color.fromARGB(
                                                  255, 104, 104, 104),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "RM " +
                                                widget.orderList![index]
                                                        ['price']
                                                    .toString(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'Montserrat',
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )),
                                  Container(
                                    height: 66,
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "x" +
                                          widget.orderNameList![index]
                                                  ['quantity']
                                              .toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  if (itemLength > 1)
                                    GestureDetector(
                                      onTap: () {
                                        if (itemLength > 1) {
                                          setState(() {
                                            itemLength = itemLength - 1;
                                            List<Map<String, dynamic>>
                                                tempList = [];
                                            tempList
                                                .add(widget.orderList![index]);
                                            _removeItem(tempList, index);
                                          });
                                        }
                                      },
                                      child: Card(
                                        color: Colors.red,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }

  Future<void> _removeItem(List<Map<String, dynamic>> items, int index2) async {
    ProgressDialog.show(context, progressDialogKey);
    var response = await CatalogCart.removeItem(
      context,
      items,
    );
    ProgressDialog.hide(progressDialogKey);
    if (response != null) {
      if (response.status) {
        setState(() {
          widget.originalPrice = (double.parse(widget.originalPrice!) -
                  (double.parse(widget.cart![index2]['price']) *
                      double.parse(
                          widget.cart![index2]['quantity'].toString())))
              .toStringAsFixed(2);
          widget.orderNameList!.removeAt(index2);
          widget.orderList!.removeAt(index2);
          widget.cart!.removeAt(index2);
          _submitPoint(context);
        });
        Toast.show(context, "success", "Item removed");
      }
    }
  }

  Widget _shippingDetailsCard() {
    return Visibility(
      visible: (stateName != null),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {},
        child: Container(
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
              Text(
                'Shipping'.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color.fromARGB(255, 104, 104, 104),
                  fontWeight: FontWeight.bold,
                ),
              ),
              (shippingFees != null)
                  ? Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 35),
                        child: Text(
                          (shippingFees != null) ? 'RM ' + shippingFees : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 5 / 100,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _redemptionCard() {
    return Card(
        child: Container(
      width: MediaQuery.of(context).size.width * 90 / 100,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Redemption'.tr,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              Visibility(
                visible: voucherCode != null,
                replacement: Container(),
                child: GestureDetector(
                  onTap: () {
                    clearDiscount();
                  },
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
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
                            color: Color.fromARGB(255, 104, 104, 104),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Visibility(
                          visible: voucherCode == null,
                          replacement: Row(
                            children: [
                              Container(
                                width: 150,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  (voucherCode != null) ? voucherCode! : '',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: CupertinoColors.label),
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
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: CupertinoColors.inactiveGray),
                              ),
                              const Icon(
                                CupertinoIcons.chevron_right,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                Container(
                  height: 60,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: const BoxDecoration(
                          color: CupertinoColors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Points'.tr,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: Color.fromARGB(255, 104, 104, 104),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: (isSwitched)
                                      ? Text(
                                          points_used.toString() +
                                              " PTS -RM [ " +
                                              discountPrice2.toString() +
                                              " ]",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              color: CupertinoColors.label),
                                        )
                                      : Text(
                                          available_credit.toString() +
                                              " RM [ " +
                                              discountPrice2.toString() +
                                              " ]",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              color:
                                                  CupertinoColors.inactiveGray),
                                        ),
                                ),
                                Transform.scale(
                                  scale: 0.7,
                                  child: Switch(
                                    value: isSwitched,
                                    onChanged: (value) {
                                      setState(() {
                                        if (credit > 100) {
                                          isSwitched = value;
                                          if (isSwitched) {
                                            use_credit = 1;
                                            _submitPoint(context);
                                          } else {
                                            use_credit = 0;
                                            clearDiscountPoint();
                                          }
                                        }
                                      });
                                    },
                                    activeTrackColor: Colors.green,
                                    activeColor: Colors.green,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _paymentDetailsCard() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Price'.tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                color: CupertinoTheme.of(context).primaryColor,
                fontWeight: FontWeight.w300,
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
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 60),
                      child: Text(
                        'RM ' + widget.originalPrice!,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: (shippingFees != "0.0"),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 60),
                        child: Text(
                          (orignalShipping != "0.0")
                              ? '+ RM ' + orignalShipping
                              : '',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: (discountPrice != "0"),
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
                        color: Color.fromARGB(255, 104, 104, 104),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 60),
                        child: Text(
                          (discountPrice != "0")
                              ? '- RM' + discountPrice.toString()
                              : '',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: (discountPrice2 != "0"),
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
                        color: Color.fromARGB(255, 104, 104, 104),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 60),
                        child: Text(
                          (discountPrice2 != "0")
                              ? '- RM' + discountPrice2.toString()
                              : '',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: 15),
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
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 60),
                      child: Text(
                        (finalPrice == null)
                            ? 'RM ' + widget.originalPrice!
                            : 'RM ' + finalPrice!,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
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
                color: Color.fromARGB(255, 104, 104, 104),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              (finalPrice == null)
                  ? 'RM ' + widget.originalPrice!
                  : 'RM ' + finalPrice!,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        if (type == 0)
          GestureDetector(
            onTap: () {},
            child: Visibility(
              visible: (nameController.text != '' &&
                      contactNumController.text != '' &&
                      fullAddress != "" &&
                      finalPrice != null ||
                  widget.method == 1), //paymentMethod != 0,
              replacement: Container(
                color: CupertinoColors.inactiveGray,
                height: MediaQuery.of(context).size.height * 8 / 100,
                width: MediaQuery.of(context).size.width * 20 / 100,
                child: Center(
                  child: Text(
                    'Next'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        color: CupertinoColors.white),
                  ),
                ),
              ),
              child: GestureDetector(
                key: const Key("confirm_checkout"),
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (context) {
                    return CheckoutProductConfirmation(
                      name: nameController.text,
                      email: email!,
                      contact: contactNumController.text,
                      fullAddress:
                          (vm == null || widget.method == 0) ? fullAddress : "",
                      address: (address != null || widget.method == 0)
                          ? address
                          : null,
                      message: messageController.text,
                      orderList: widget.orderList!,
                      items: items,
                      voucherId: (voucherId != null) ? voucherId! : 0,
                      voucherCode: (voucherCode != null) ? voucherCode! : null,
                      voucherChild:
                          (voucherChild != null) ? voucherChild! : null,
                      finalPrice: (finalPrice != null)
                          ? finalPrice!
                          : widget.originalPrice!,
                      shippingFees: shippingFees,
                      originalPrice: widget.originalPrice!,
                      discountPrice: discountPrice,
                      discountPrice2: discountPrice2,
                      shipping_discount_price: shipping_discount_price,
                      use_credit: use_credit,
                      vendingMachine: vm,
                      method: widget.method,
                      vm_id: widget.vm_id,
                      delivery: delivery,
                      latitude: latitude,
                      longitude: longitude,
                      quotation: quotation_id,
                      orignalShipping: shippingFees,
                    );
                  }));
                },
                child: Container(
                  color: CupertinoTheme.of(context).primaryColor,
                  height: MediaQuery.of(context).size.height * 8 / 100,
                  width: MediaQuery.of(context).size.width * 20 / 100,
                  child: Center(
                      child: Text(
                    'Next'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        color: CupertinoColors.white),
                  )),
                ),
              ),
            ),
          ),
        if (type == 1)
          GestureDetector(
            onTap: () {},
            child: Visibility(
              visible: (nameController.text != '' &&
                  contactNumController.text != '' &&
                  fullAddress != "" &&
                  finalPrice != null), //paymentMethod != 0,
              replacement: Container(
                color: CupertinoColors.inactiveGray,
                height: MediaQuery.of(context).size.height * 8 / 100,
                width: MediaQuery.of(context).size.width * 20 / 100,
                child: Center(
                  child: Text(
                    'Next'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        color: CupertinoColors.white),
                  ),
                ),
              ),
              child: GestureDetector(
                key: const Key("confirm_checkout"),
                onTap: () {
                  if (contactNumController.text.length >= 11 ||
                      delivery != "Lalamove") {
                    Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) {
                      return CheckoutProductConfirmation(
                        name: nameController.text,
                        email: email!,
                        contact: contactNumController.text,
                        fullAddress: (vm == null || widget.method == 0)
                            ? fullAddress
                            : "",
                        address: (address != null || widget.method == 0)
                            ? address
                            : null,
                        message: messageController.text,
                        orderList: widget.orderList!,
                        items: items,
                        voucherId: (voucherId != null) ? voucherId! : 0,
                        voucherCode:
                            (voucherCode != null) ? voucherCode! : null,
                        voucherChild:
                            (voucherChild != null) ? voucherChild! : null,
                        finalPrice: (finalPrice != null)
                            ? finalPrice!
                            : widget.originalPrice!,
                        shippingFees: shippingFees,
                        orignalShipping: orignalShipping,
                        originalPrice: widget.originalPrice!,
                        discountPrice: discountPrice,
                        discountPrice2: discountPrice2,
                        shipping_discount_price: shipping_discount_price,
                        use_credit: use_credit,
                        vendingMachine: vm,
                        method: widget.method,
                        vm_id: widget.vm_id,
                        delivery: delivery,
                        latitude: latitude,
                        longitude: longitude,
                        quotation: quotation_id,
                      );
                    }));
                  } else {
                    Toast.show(
                        context, "danger", 'Please enter a valid phone number');
                  }
                },
                child: Container(
                  color: CupertinoTheme.of(context).primaryColor,
                  height: MediaQuery.of(context).size.height * 8 / 100,
                  width: MediaQuery.of(context).size.width * 20 / 100,
                  child: Center(
                      child: Text(
                    'Next'.tr,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        color: CupertinoColors.white),
                  )),
                ),
              ),
            ),
          )
      ],
    );
  }

  Future<void> _fetchAddress() async {
    if (location.isNotEmpty) {
      //how to make this more efficent?
      var tempAddress = await Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) {
        return AddressForm(
          delivery: delivery,
          availableAddress: address,
          location: location,
        );
      }));
      if (tempAddress.runtimeType == List<dynamic>) {
        address = address;
      } else {
        address = tempAddress;
      }
    } else {
      var tempAddress = await Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) {
        return AddressForm(
          delivery: delivery,
          availableAddress: address,
        );
      }));
      if (tempAddress.runtimeType == List<dynamic>) {
        address = address;
      } else {
        address = tempAddress;
      }
    }
    if (address.isNotEmpty) {
      setState(() {
        //city = address['city'];
        if (delivery == "Lalamove") {
          location = address[0]['location'];
          latitude = address[0]['latitude'];
          longitude = address[0]['longitude'];
        }
        stateCode = address[0]['state_code'];
        stateName = stateList[stateCode];
        fullAddress = address[0]['address1'] +
            ' ' +
            address[0]['address2'] +
            ',' +
            address[0]['postcode'] +
            ',' +
            address[0]['city'] +
            ',' +
            stateName;
        moveAddress = address[0]['address1'] +
            ',' +
            address[0]['address2'] +
            ',' +
            address[0]['city'] +
            ',' +
            stateName;
      });

      fetchShippingFees(context);
    } else {
      setState(() {});
    }
  }

  Future<void> _submitPoint(BuildContext context) async {
    final webService = WebService(context);
    webService
        .setMethod('POST')
        .setEndpoint('catalog/catalog-products/calculate-price');
    Map<String, String> data = {};
    data.addAll({'original_price': widget.originalPrice!});
    data.addAll({'use_credit': use_credit.toString()});
    if (shippingFees != "") {
      data.addAll({'shipping_price': shippingFees});
    }
    var response = await webService.setData(data).send();
    if (response == null) return;
    if (response.status) {
      Map<String, dynamic> result = jsonDecode(response.body.toString());
      setState(() {
        newPrice = result['discount_price'];
        discountPrice2 = result['credit_deduct_amount'];
        points_used = result['points_used'];
        finalPrice = result['total_price'];
      });
    } else if (response.statusCode == 500) {
      Toast.show(context, 'danger', 'Server Error');
    } else {
      Toast.show(context, 'danger', 'Not Found');
    }
  }

  void clearDiscount() {
    if (newPrice != null && finalPrice != null) {
      if (shippingFees != "0" || stateCode != null) {
        fetchShippingFees(context);
      }

      shippingFees = "0";
      finalPrice = "0";
      double price = 0;
      discountPrice = "0";
      price = double.parse(widget.originalPrice!) - double.parse(discountPrice);
      price = price - double.parse(discountPrice2);
      var calculatePrice =double.parse(price.toString()) + double.parse(shippingFees);
      finalPrice = calculatePrice.toStringAsFixed(2);
    }
    setState(() {
      newPrice = "0";
      discountPrice = '0';
      discountMethod = null;
      voucherCode = null;
      voucherId = null;
      voucherChild = null;
    });
    Toast.show(context, 'success', 'Voucher Cleared!');
  }

  void clearDiscountPoint() {
    if (newPrice != null && finalPrice != null) {
      double price = 0;
      price = double.parse(finalPrice!) + double.parse(discountPrice2);
      var calculatePrice;
      calculatePrice = double.parse(price.toString());

      finalPrice = calculatePrice.toStringAsFixed(2);
    }
    setState(() {
      newPrice = "0";
      discountPrice2 = "0";
      points_used = "0";
    });
    Toast.show(context, 'success', 'Points Cleared!');
  }

  Future<void> fetchFreeDiscount() async {
    widget.orderList!.removeWhere((element) => element['product_id'] == '');
    widget.orderList!.removeWhere((element) => element['product_name'] == '');
    widget.orderList!.removeWhere((element) => element['quantity'] == 0);
    widget.orderList!.removeWhere((element) => element['quantity'] == 0);
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('catalog/catalog-products/calculate-price');
    Map<String, String> data = {};
    data.addAll({'original_price': widget.originalPrice!});
    data.addAll({'voucher_code': "FREEGIFT"});
    data.addAll({'voucher_child': "0"});
    data.addAll({'items': jsonEncode(widget.orderList)});
    data.addAll({"vm_id": widget.vm_id.toString()});
    var response = await webService.setData(data).send();
    if (response == null) return;
    if (response.status) {
      Map<String, dynamic> result = jsonDecode(response.body.toString());
      setState(() {
        result.addAll({'voucher_code': "FREEGIFT"});
        returnResult = result;
      });
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
    } else if (response.statusCode == 500) {
      Toast.show(context, 'danger', 'Server Error');
    } else {
      Toast.show(context, 'danger', 'Not Found');
    }
    finalPrice = "0";
    var price =
        double.parse(widget.originalPrice!) - double.parse(discountPrice);
    price = price - double.parse(discountPrice2);
    if (shippingFees != "") {
      var calculatePrice =
          double.parse(price.toString()) + double.parse(shippingFees);
      finalPrice = calculatePrice.toStringAsFixed(2);
    } else {
      var calculatePrice = double.parse(price.toString());
      finalPrice = calculatePrice.toStringAsFixed(2);
    }
  }

  Future<void> fetchAfterDiscount() async {
    var shipping_deduct_amount;
    var shipping_type;
    returnResult = await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return VoucherSelectProduct(
          delivery: (delivery == "Lalamove") ? 1 : 0,
          use_credit: use_credit,
          shippingPrice: shippingFees,
          originalPrice: widget.originalPrice,
          product_type: 1,
          items: widget.orderList,
          vmId: widget.vm_id);
    }));
    if (returnResult != null) {
      setState(() {
        newPrice = returnResult!['discount_price'];
        discountPrice = returnResult!['deduct_amount'];
        discountMethod = returnResult!['quantifier'];
        voucherCode = returnResult!['voucher_code'];
        voucherId = returnResult!['voucher_id'];
        voucherChild = returnResult!['voucher_child'];
        shipping_deduct_amount = returnResult!['shipping_deduct_amount'];
        shipping_discount_price = returnResult!['shipping_deduct_amount'];
        finalPrice = returnResult!['total_price'];
        shipping_type = (delivery == "Lalamove") ? 1 : 0;
      });
    }
    if (shipping_deduct_amount != null &&
        shippingFees != "" &&
        shipping_type == 1 &&
        shipping_discount_price != null) {
      if (shipping_deduct_amount != "0.00") {
        shippingFees = (double.parse(shippingFees) - double.parse(shipping_deduct_amount)).toStringAsFixed(2);
      } else if (shipping_discount_price != "0.00") {
        shippingFees = (double.parse(shippingFees) -double.parse(shipping_discount_price!)).toStringAsFixed(2);
      }
      if (shipping_deduct_amount != "0.00") {
        discountPrice = shipping_deduct_amount!;
      } else if (shipping_discount_price != "0.00") {
        discountPrice = shipping_discount_price!;
      }
    }
  }

  void assignItems() {
    widget.orderNameList!.removeWhere((element) => element['product_url'] == '');
    widget.orderNameList!.removeWhere((element) => element['product_name'] == '');
    widget.orderNameList!.removeWhere((element) => element['quantity'] == 0);
    if (items != null) {
      items = "";
    }
    setState(() {
      items = widget.orderNameList!.join("\n");
      items = items.replaceAll('}', '');
      items = items.replaceAll('{product_name:', '');
      items = items.replaceAll(', quantity: ', ' X ');
      var temp = items.split(",");
      items = temp[0];
    });
  }

  Future<Map<String, dynamic>?> fetchShippingFees(BuildContext context) async {
    WebService webService = WebService(context);
    final GlobalKey progressDialogKey = GlobalKey<State>();
    for (int i = 0; i < widget.orderList!.length; i++) {
      setState(() {
        widget.orderList!.removeWhere((element) => element['product_id'] == '');
        widget.orderNameList!.removeWhere((element) => element['product_name'] == '');
        widget.orderList!.removeWhere((element) => element['quantity'] == 0);
        widget.orderNameList!.removeWhere((element) => element['quantity'] == 0);
        json = jsonEncode(widget.orderList!);
      });
    }
    Map<String, String> data = {};
    data.addAll({'state_code': stateCode!});
    data.addAll({'items': json});
    data.addAll({'delivery_provider': type.toString()});
    data.addAll({'pickup_type': widget.method.toString()});

    if (type == 1) {
      if (widget.vendingMachine != null &&
          widget.vendingMachine!.vm_id != null) {
        data.addAll({'vm_id': widget.vendingMachine!.vm_id.toString()});
      } else {
        data.addAll({'vm_id': widget.vendingMachine!.id.toString()});
      }
      data.addAll({'latitude': latitude});
      data.addAll({'longitude': longitude});
      data.addAll({'address_1': address[0]['address1']});
      data.addAll({'address_2': address[0]['address2']});
      data.addAll({'postcode': address[0]['postcode']});
      data.addAll({'city': address[0]['city']});
      data.addAll({'state_code': stateCode!});
    }

    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.setMethod('POST').setEndpoint('catalog/shipping-fees/calculate').setData(data).send()
        .timeout(const Duration(seconds: 5), onTimeout: () {
      Toast.show(context, "danger", "Request timed out");
      return null;
    });
    ProgressDialog.hide(progressDialogKey);
    if (response == null) return null;
    if (response.status) {
      _shippingList = jsonDecode(response.body.toString());
      setState(() {
        shippingFees = _shippingList!['price'];
        orignalShipping = _shippingList!['price'];
        if (_shippingList!['quotation_id'] != null) {
          quotation_id = _shippingList!['quotation_id'];
        }
        finalPrice = "0";
        var price =
            double.parse(widget.originalPrice!) - double.parse(discountPrice);
        price = price - double.parse(discountPrice2);
        var calculatePrice =
            double.parse(price.toString()) + double.parse(shippingFees);
        finalPrice = calculatePrice.toStringAsFixed(2);
      });
    } else {
      Toast.show(context, "danger", "Error Fetching");
    }
    return _shippingList;
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    var text = htmlText.replaceAll(exp, ' ');
    return text.replaceAll(exp, ' ');
  }

  Future<void> fetchDelivery() async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('catalog/shipping-types');
    Map<String, String> filter = {};
    filter.addAll({'screen': widget.method.toString()});
    var response = await webService.setFilter(filter).send();
    if (response == null) return;
    if (response.status) {
      List<dynamic> result = jsonDecode(response.body.toString());
      setState(() {
        shippingType = result;
        delivery = shippingType[0]['name'];
      });
    } else if (response.statusCode == 500) {
      Toast.show(context, 'danger', 'Server Error');
    } else {
      Toast.show(context, 'danger', 'Not Found');
    }
  }

  Future<void> _populateForm() async {
    User? user = await User.fetchOne(context);
    if (user != null) {
      if (mounted) {
        setState(() {
          nameController.text = (user.name != null) ? user.name! : '';
          contactNumController.text =
              (user.phoneNo != null) ? user.phoneNo! : '';
          email = (user.email != null) ? user.email : '';
          credit = double.parse(user.credit!);
          available_credit = user.credit!;
          if (address.isNotEmpty) {
            address.add({
              'address1': user.address1!,
              'address2': user.address2!,
              'postcode': user.postcode,
              'city': user.city,
              'state': user.state,
              'country': user.country,
            });
          }
        });
      }
    }
  }
}
