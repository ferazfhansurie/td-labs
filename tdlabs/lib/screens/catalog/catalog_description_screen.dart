// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlabs/models/commerce/cart.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/screens/catalog/vm_screen.dart';
import 'package:tdlabs/screens/checkout/checkout_product.dart';
import 'package:tdlabs/screens/history/product_history_screen.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/widgets/carousel/carousel.dart';
import 'package:tdlabs/widgets/form/order_counter.dart';
import 'package:get/get.dart';
import 'package:tdlabs/widgets/spinbox/spin_box.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/commerce/catalog.dart';
import '../../utils/progress_dialog.dart';
import 'cart_screen.dart';
import '../../global.dart' as global;

// ignore: must_be_immutable
class CatalogDescriptionScreen extends StatefulWidget {
  int? index;
  Catalog? catalog;
  double? subTotal;
  int? method;
  String? originalPrice;
  List<Map<String, dynamic>>? orderList;
  List<int>? orderQuantityList;
  List<Map<String, dynamic>>? orderNameList;
  List<double>? orderTotalList;
  VendingMachine? vendingMachine;
  bool? free;
  Function()? refresh;
  CatalogDescriptionScreen(
      {Key? key,
      this.index,
      this.catalog,
      this.originalPrice,
      this.orderList,
      this.orderNameList,
      this.orderQuantityList,
      this.orderTotalList,
      this.method,
      this.vendingMachine,
      this.free,
      this.refresh})
      : super(key: key);

  @override
  _CatalogDescriptionScreenState createState() =>
      _CatalogDescriptionScreenState();
}

class _CatalogDescriptionScreenState extends State<CatalogDescriptionScreen> {
  SubTotalController subTotalController = Get.put(SubTotalController());
  final inputController = TextEditingController();
  double? totalAdd;
  List<double> orderTotalList = [];
  List<dynamic> _listCart = [];
  List<Map<String, dynamic>>? _addList = [];
  int index = 0;
  int totalCart = 0;
  VendingMachine? _vm;
  int buyQuantity = 1;
  static final facebookAppEvents = FacebookAppEvents();
  @override
  void initState() {
    _vm = widget.vendingMachine;
    _fetchCart();
    print(widget.index);
    print(widget.orderQuantityList![0]);
    super.initState();
  }

  Future<List<dynamic>?> _fetchCart() async {
    var response = await CatalogCart.fetchCart(
        context, (widget.vendingMachine == null) ? 0 : 1);

    if (response == null) return null;
    if (response.status) {
      _listCart =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      setState(() {
        var items = 0;
        for (int i = 0; i < _listCart.length; i++) {
          items = items + int.parse(_listCart[i]['quantity'].toString());
          if (_listCart[i]['name'] == widget.catalog!.name &&
              _listCart[i]['quantity'] > 0) {
            widget.orderQuantityList![widget.index!] = _listCart[i]['quantity'];
        
          }
         
        }
        if (widget.vendingMachine != null) {
          totalCart = items;
        } else {
          totalCart = _listCart.length;
        }
      });
    }

    return _listCart;
  }

  void _pop() {
    _addList!.clear();
    widget.refresh!();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        child: WillPopScope(
          onWillPop: () async {
            const shouldPop = true;
            _pop();
            return shouldPop;
          },
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/Background-01.png"),
                      fit: BoxFit.fill),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                //color: ThemeColors.blueGreen,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(
                      top: 30,
                      left: 5,
                      right: 5),
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    _pop();
                                  },
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                (widget.vendingMachine == null)
                                    ? "TD Mall".tr
                                    : "Smart Keluarga",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (widget.vendingMachine == null) {
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return CartScreen(
                                          tab: 0,
                                        );
                                      }));
                                    } else {
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return CartScreen(
                                          tab: 1,
                                          vm: widget.vendingMachine,
                                        );
                                      }));
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      Positioned(
                                        top: 0.0,
                                        right: 0.0,
                                        child: Container(
                                          padding: const EdgeInsets.all(1),
                                          decoration: BoxDecoration(
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 15,
                                            minHeight: 15,
                                          ),
                                          child: Text(
                                            totalCart.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              GestureDetector(
                                onTap: () {
                                  _showMore(context);
                                },
                                child: const Icon(
                                  CupertinoIcons.ellipsis,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 80 / 100,
                        child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: catalogDesc()),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 7 / 100,
          color: CupertinoColors.white,
          child: bottomNav()),
    );
  }

  Widget bottomNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: (widget.vendingMachine == null)
              ? (widget.catalog!.stock_quantity != 0)
              : (widget.catalog!.in_stock != 0),
          replacement: SizedBox(
            height: MediaQuery.of(context).size.height * 8 / 100,
            width: MediaQuery.of(context).size.width * 25 / 100,
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  color: CupertinoColors.inactiveGray,
                ),
                Text(
                  'Add to Cart'.tr,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            )),
          ),
          child: GestureDetector(
            key: const Key("add_cart"),
            onTap: () async {
              var limit = widget.catalog!.stock_quantity!;
              if (widget.vendingMachine == null) {
                if (widget.orderQuantityList![widget.index!] == limit) {
                  Toast.show(context, "danger", "No Stock Left");
                } else {
                  _addtoCart(widget.catalog!, widget.index!, 1, 0);
                }
              } else if (totalCart < 3) {
                if (widget.catalog!.in_stock == 0) {
                  Toast.show(context, "danger", "No Stock Left");
                } else {
                  _addtoCart(widget.catalog!, widget.index!, 1, 0);
                }
              } else {
                Toast.show(context, "danger", "Cart is full");
              }
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 8 / 100,
              width: MediaQuery.of(context).size.width * 25 / 100,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart),
                  Text(
                    'Add to Cart'.tr,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              )),
            ),
          ),
        ),
        const Spacer(),
        Visibility(
          visible: (widget.vendingMachine == null)
              ? (widget.catalog!.stock_quantity != 0)
              : (widget.catalog!.in_stock != 0),
          replacement: Container(
            color: CupertinoColors.inactiveGray,
            height: MediaQuery.of(context).size.height * 8 / 100,
            width: MediaQuery.of(context).size.width * 25 / 100,
            child: Center(
              child: Text(
                'Buy Now'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white),
              ),
            ),
          ),
          child: GestureDetector(
            onTap: () async {
              totalAdd = 0.00;
              _showPickerInput(widget.catalog!, widget.index!, 0, 0);
            },
            child: Container(
              color: const Color.fromARGB(255, 24, 112, 141),
              height: MediaQuery.of(context).size.height * 8 / 100,
              width: MediaQuery.of(context).size.width * 25 / 100,
              child: Center(
                  child: Text(
                'Buy Now'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white),
              )),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _clearItems(Catalog product, int index) async {
    double price = double.parse(product.price!);
    double quantity = 0;
    int quantityStore = 0;
    totalAdd = 0.00;
    double sum = 0.0;
    if (mounted) {
      setState(() {
        widget.orderQuantityList![index] = quantityStore;
        widget.orderList![index]['total'] =
            price * quantity; // assign total to product called
        widget.orderList![index]['product_id'] = product.id;
        widget.orderList![index]['quantity'] = widget.orderQuantityList![index];
        widget.orderNameList![index]['product_name'] = product.name;
        widget.orderNameList![index]['product_url'] = product.image_url;
        widget.orderNameList![index]['quantity'] =
            widget.orderQuantityList![index];
        widget.orderTotalList![index] = price * quantity;
        for (double productSum in widget.orderTotalList!) {
          sum += productSum;
        }
        subTotalController.getSubTotal = RxDouble(sum);
      });
    }
    widget.orderList!.removeWhere((element) => element['product_id'] == '');
    widget.orderNameList!
        .removeWhere((element) => element['product_name'] == '');
    widget.orderNameList!
        .removeWhere((element) => element['product_url'] == '');
    widget.orderList!.removeWhere((element) => element['quantity'] == 0);
    widget.orderNameList!.removeWhere((element) => element['quantity'] == 0);
    Navigator.pop(context);
    Toast.show(context, "success", "Item removed");
  }

  _showMore(BuildContext context) {
    // set up the AlertDialog
    Widget alert = Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              'Options'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return OrderHistoryScreen();
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order History'.tr,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () {
                      _launchURL('https://tdlabs.co/privacy-policy.html');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Privacy Policy'.tr,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () {
                      _launchURL('https://tdlabs.co/shipping_refund.html');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping & Refund Policy'.tr,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: const [
              //cancelButton,
              //continueButton,
            ],
          ),
        ],
      ),
    );
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _addtoCart(
      Catalog product, int index, int buy, int clear) async {
    double price = double.parse(product.price!);
    double quantity = 1;
    int quantityStore = 1;
    totalAdd = 0.00;
    double sum = 0.0;
    List<String> errors = [];
    final GlobalKey progressDialogKey = GlobalKey<State>();
     print(widget.orderQuantityList![index]);
    if (mounted) {
      ProgressDialog.show(context, progressDialogKey);
      if (widget.orderQuantityList![index] < 1 || _addList!.isEmpty) {
        setState(() {
          widget.orderQuantityList![index] =
              widget.orderQuantityList![index] + quantityStore;
          widget.orderList![index]['total'] = price *
              widget
                  .orderQuantityList![index]; // assign total to product called
          widget.orderList![index]['product_id'] = product.id;
          widget.orderList![index]['quantity'] =
              widget.orderQuantityList![index];
          widget.orderList![index]['cart_type'] = (_vm != null) ? 1 : 0;
          widget.orderNameList![index]['product_name'] = product.name;
          widget.orderNameList![index]['product_url'] = product.image_url;
          widget.orderNameList![index]['quantity'] =
              widget.orderQuantityList![index];
          widget.orderTotalList![index] = price * quantity;
          _addList = widget.orderList!;
          _addList!.removeWhere((element) => element['product_id'] == '');
          _addList!.removeWhere((element) => element['product_url'] == '');
          _addList!.removeWhere((element) => element['quantity'] == 0);
          for (double productSum in widget.orderTotalList!) {
            sum += productSum;
          }
          subTotalController.getSubTotal = RxDouble(sum);
        });
       
      } else {
          _addList!.clear();
        await _fetchCart();
        setState(() {
          _addList![0]['quantity'] = _addList![0]['quantity']+1;
          _addList![0]['sub_total'] = price * widget.orderQuantityList![index];
             _addList!.removeWhere((element) => element['product_id'] == '');
          _addList!.removeWhere((element) => element['quantity'] == 0);
        });
        var response;
        facebookAppEvents.logAddToCart(
            id: product.id.toString(),
            type: 'product',
            currency: 'MYR',
            price: price);
        if (_vm == null) {
          response = await CatalogCart.addItem(context, _addList!);
        } else {
          response = await CatalogCart.addItemVM(context, _addList!, _vm!.vm_id!);
        }
        if (response!.status) {
          await _fetchCart();
        } else if (response.error.isNotEmpty) {
          errors.add(response.error.values.toList()[0]);
        } else {
          errors.add('Server connection timeout.');
        }
      }
      if (errors.isNotEmpty) {
        if (errors
            .contains("Cannot combine items from different vending machine")) {
          _showChange(context);
        } else {
          Toast.show(context, "error", errors.toList()[0]);
        }
      }
    }
    var response;
    facebookAppEvents.logAddToCart(
        id: product.id.toString(),
        type: 'product',
        currency: 'MYR',
        price: price);
    if (_vm == null) {
      response = await CatalogCart.addItem(context, _addList!);
      ProgressDialog.hide(progressDialogKey);
    } else {
      response = await CatalogCart.addItemVM(context, _addList!, _vm!.vm_id!);
      ProgressDialog.hide(progressDialogKey);
    }
    if (response != null) {
      if (response.status) {
        global.updateHomeScreen = true;
        await _fetchCart();
        Toast.show(context, "success", "Item added to cart");
      } else if (response.error.isNotEmpty) {
        errors.add(response.error.values.toList()[0]);
      } else {
        errors.add('Server connection timeout.');
      }
      if (errors.isNotEmpty) {
        _addList!.clear();
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return VmScreen(
            vm: widget.vendingMachine,
          );
        }));
        _showChange(context);
      }
    }
  }

  _showChange(BuildContext context) {
    Widget continueButton = CupertinoButton(
      child: Text(
        'Cart'.tr,
        style: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return CartScreen(tab: 1, vm: widget.vendingMachine);
        }));
      },
    );
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      contentPadding: const EdgeInsets.all(0.0),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 52, 169, 176),
              Color.fromARGB(255, 49, 42, 130),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Items cannot be from diffrent Machines",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  continueButton,
                ],
              ),
            )
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(true), child: alert);
      },
    );
  }

  _showPickerInput(Catalog product, int index, int buy, int clear) {
    if (clear == 1) {
      _clearItems(product, index);
    }
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: widget.catalog!.image_url!,
                              height: 100,
                              width: 100,
                            )),
                      ),
                      Container(
                        width: 175,
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(widget.catalog!.name!,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20)),
                            ),
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: RichText(
                                text: TextSpan(
                                  text: 'RM ',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w300,
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
                                      fontSize: 20),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: widget.catalog!.price!,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor,
                                          fontSize: 28),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Quantity".tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        )),
                    //if stock less than 3 it shows stock quantity
                    SpinBox(
                      min: 0,
                      max: (widget.vendingMachine == null)
                          ? (widget.catalog!.stock_quantity! > 20)
                              ? 20
                              : widget.catalog!.stock_quantity!
                          : 3,
                      value: buyQuantity,
                      onChanged: (value) {
                        setState(() {
                          buyQuantity = value;
                        });
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    elevation: 5,
                    child: CupertinoButton(
                      color: CupertinoTheme.of(context).primaryColor,
                      disabledColor: CupertinoColors.inactiveGray,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        double price = double.parse(product.price!);
                        double quantity = double.parse(buyQuantity.toString());
                        int quantityStore = buyQuantity;
                        totalAdd = 0.00;
                        double sum = 0.0;

                        if (mounted) {
                          setState(() {
                            _addList!.addAll(widget.orderList!);
                            widget.orderQuantityList![index] = quantityStore;
                            widget.orderList![index]['price'] = price;
                            widget.orderList![index]['total'] = price *
                                quantity; // assign total to product called
                            widget.orderList![index]['product_id'] = product.id;
                            widget.orderList![index]['quantity'] =
                                widget.orderQuantityList![index];
                            widget.orderList![index]['cart_type'] =
                                (_vm != null) ? 1 : 0;
                            widget.orderNameList![index]['product_name'] =
                                product.name;
                            widget.orderNameList![index]['product_url'] =
                                product.image_url;
                            widget.orderNameList![index]['quantity'] =
                                widget.orderQuantityList![index];
                            widget.orderTotalList![index] = price * quantity;
                            for (double productSum in widget.orderTotalList!) {
                              sum += productSum;
                            }
                            subTotalController.getSubTotal = RxDouble(sum);
                          });
                        }
                        widget.orderList!.removeWhere(
                            (element) => element['product_id'] == '');
                        widget.orderList!.removeWhere(
                            (element) => element['product_url'] == '');
                        widget.orderNameList!.removeWhere(
                            (element) => element['product_name'] == '');
                        widget.orderList!
                            .removeWhere((element) => element['price'] == 0);
                        widget.orderList!
                            .removeWhere((element) => element['quantity'] == 0);
                        widget.orderNameList!
                            .removeWhere((element) => element['quantity'] == 0);
                        facebookAppEvents.logInitiatedCheckout();

                        Navigator.pop(context);
                        Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          return CheckoutProductScreen(
                            vendingMachine: widget.vendingMachine,
                            originalPrice: subTotalController.getSubTotal!
                                .toStringAsFixed(2),
                            orderList: widget.orderList,
                            orderNameList: widget.orderNameList,
                            method: (_vm != null) ? 1 : 0,
                            vm_id: (_vm != null) ? _vm!.vm_id : 0,
                            free: widget.free,
                          );
                        })).then((value) {
                          if (value == true) {
                            widget.refresh!();
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text('Buy Now'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void retrieveList() {
    for (int i = 0; i < widget.orderList!.length; i++) {
      widget.orderList!.add({
        'product_id': widget.orderList![i]['product_id'],
        'product_url': widget.orderList![i]['product_url'],
        'quantity': widget.orderList![i]['quantity'],
        'price': widget.orderList![i]['price'],
        'total': widget.orderList![i]['total'],
        'cart_type': 0
      });
    }
  }

  Widget catalogDesc() {
    return Column(
      children: [
        //Carousel(images: _catalogProduct.images),
        if (widget.catalog!.image_url != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
                alignment: Alignment.center,
                child: (widget.catalog!.images!.length > 1)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CarouselSlide(
                          images: widget.catalog!.images!,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: widget.catalog!.image_url!))),
          ),
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    child: Text(widget.catalog!.name!,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'RM' + widget.catalog!.price!,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  if (widget.vendingMachine == null &&
                      widget.catalog!.stock_quantity == 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.red)),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Text(
                              'Out Of Stock',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.vendingMachine != null &&
                      widget.catalog!.in_stock == 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.red)),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Text(
                              'Out Of Stock',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ])),
        const Divider(color: CupertinoColors.separator),
        Container(
          color: CupertinoColors.white,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description'.tr,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Divider(
                  thickness: 2,
                ),
                Text(
                  widget.catalog!.description!,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
