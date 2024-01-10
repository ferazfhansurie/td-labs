// ignore_for_file: must_be_immutable, non_constant_identifier_names, unnecessary_null_comparison

import 'dart:convert';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tdlabs/adapters/catalog/cart.dart';
import 'package:tdlabs/models/commerce/cart.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/screens/catalog/catalog_description_screen.dart';
import 'package:tdlabs/screens/catalog/catalog_screen.dart';
import 'package:tdlabs/screens/catalog/vm_screen.dart';
import 'package:tdlabs/screens/catalog/vm_select.dart';
import 'package:tdlabs/screens/checkout/checkout_product.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../utils/toast.dart';
import 'package:tdlabs/utils/progress_dialog.dart';

class CartScreen extends StatefulWidget {
  int? tab;
  VendingMachine? vm;
  CartScreen({Key? key, this.tab, this.vm}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>>? _cartList;
  Future<List<dynamic>?>? _future;
  final ScrollController _scrollController = ScrollController();
  double total = 0.0;
  int? _tabIndex = 0; //0 = mall/1=vm/2 main
  int vm_id = 0;
  String subTotal = "";
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderNameList = [];
  List<int> orderQuantityList = [];
  List<double> orderTotalList = [];
  List<Map<String, dynamic>> tempList = [];
  List<Map<String, dynamic>> unavailableList = [];
  final List<Catalog> _listProduct = [];
  int totalCart = 0;
  String? vmName;
  String? vmArea;
  String? vmCode;
  String? vmUrl;
  VendingMachine? vm;
  String longitude = "";
  String latitude = "";
  Catalog? catalog;
  static final facebookAppEvents = FacebookAppEvents();
  final GlobalKey progressDialogKey = GlobalKey<State>();
  @override
  void initState() {
    //  implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    if (widget.tab != null) _tabIndex = widget.tab;
    _performSearch();
    getLocation();
  }

  Future<void> refreshList() async {
    setState(() {
      _cartList!.clear();
      orderList.clear();
      orderNameList.clear();
      total = 0;
      vm_id = 0;
      totalCart = 0;
      vm = null;
    });
    _performSearch();
  }

  void _refreshTotal() {
    total = 0;
    totalCart = 0;
    var items = 0;
    for (int i = 0; i < _cartList!.length; i++) {
      setState(() {
        total = total + double.parse(_cartList![i]["sub_total"].toString());
        items = items + int.parse(_cartList![i]['quantity'].toString());
      });
    }
    setState(() {
      if (_tabIndex == 1) {
        totalCart = items;
      } else {
        totalCart = _cartList!.length;
      }
    });
  }

  void _performSearch() {
    _future = _fetchCart();
  }

  Future<void> _removeItem(List<Map<String, dynamic>> items) async {
    ProgressDialog.show(context, progressDialogKey);
    var response = await CatalogCart.removeItem(
      context,
      items,
    );
    ProgressDialog.hide(progressDialogKey);
    if (response != null) {
      if (response.status) {
        Navigator.pop(context);
        refreshList();
        Toast.show(context, "success", "Item removed");
      }
    }
  }

//this is a function to fetching vending machine
  Future<VendingMachine?> _fetchVM(
    BuildContext context,
  ) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('vm/vending-machines/$vm_id');

    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      Map<String, dynamic> result = jsonDecode(response.body.toString());
      VendingMachine vms =
          VendingMachine.fromJson(jsonDecode(response.body.toString()));
      setState(() {
        vm = vms;
        vmName = result['name'];
        vmArea = result['area_name'];
        vmCode = result['code'];
        vmUrl = result['image_url'];
      });
    }

    return vm;
  }

  Future<List<dynamic>?> _fetchCart() async {
    var items = 0;
    var response = await CatalogCart.fetchCart(context, _tabIndex!);
    if (response == null) return null;
    if (response.status) {
      _cartList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      for (int i = 0; i < _cartList!.length; i++) {
        setState(() {
          items = items + int.parse(_cartList![i]['quantity'].toString());
          total = total + double.parse(_cartList![i]["sub_total"]);
          _fetchProducts(i);
          if (_cartList![i]["vm_id"] != null) {
            vm_id = _cartList![i]["vm_id"];
            if (vm_id != null) {
              _fetchVM(context);
            }
          }
        });
        if (_cartList!.isNotEmpty) {
          orderList.add({
            'product_id': _cartList![i]['product_id'],
            'quantity': _cartList![i]['quantity'],
            'price': _cartList![i]['price'],
            'total': _cartList![i]['sub_total'],
            'cart_type': _cartList![i]['cart_type'],
          });
          orderNameList.add({
            'product_name': _cartList![i]['name'],
            'product_url': _cartList![i]['image_url'],
            'quantity': _cartList![i]['quantity'],
          });
        }
      }

      if (_tabIndex == 1) {
        totalCart = items;
      } else {
        totalCart = _cartList!.length;
      }
    }

    return _cartList;
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
  }

  Future<List<Catalog>?> _fetchProducts(int j) async {
    final webService = WebService(context);
    var id = _cartList![j]['product_id'];
    webService.setEndpoint('catalog/catalog-products/$id');

    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      Catalog catalogs = Catalog.fromJson(jsonDecode(response.body.toString()));
      setState(() {
        catalog = catalogs;
        _cartList![j]['stock_quantity'] = catalog!.stock_quantity;
        _cartList![j]['in_stock'] = catalog!.in_stock;
        if (_cartList![j]['in_stock'] == 0 && _cartList![j]['vm_id'] != null) {
          unavailableList.add(_cartList![j]);
        }
      });
    }
    return _listProduct;
  }

  void retrieveList() {
    for (int i = 0; i < _cartList!.length; i++) {
      orderList.add({
        'product_id': _cartList![i]['product_id'],
        'quantity': _cartList![i]['quantity'],
        'price': _cartList![i]['price'],
        'total': _cartList![i]['sub_total'],
        'cart_type': _cartList![i]['cart_type'],
      });
      orderNameList.add({
        'product_name': _cartList![i]['product_id'],
        'product_url': _cartList![i]['image_url'],
        'quantity': _cartList![i]['quantity'],
      });
    }
  }

  void _pop() {
    Navigator.popUntil(context, (route) => route.isFirst);
    if (widget.tab == 0) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return CatalogScreen();
      }));
    } else if (widget.tab == 1) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return VmScreen(
          vm: widget.vm,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key("cart_screen"),
      body: CupertinoPageScaffold(
        child: WillPopScope(
          onWillPop: () async {
            const shouldPop = true;
            _pop();
            return shouldPop;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: RefreshIndicator(
              onRefresh: refreshList,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height + 55,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/Background-01.png"),
                        fit: BoxFit.fill),
                  ),
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                  if (widget.tab == 0) {
                                    Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (context) {
                                      return CatalogScreen();
                                    }));
                                  } else if (widget.tab == 1) {
                                    Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (context) {
                                      return VmScreen(
                                        vm: widget.vm,
                                      );
                                    }));
                                  }
                                },
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Cart".tr,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300),
                              ),
                              const Spacer()
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width,
                        child: _tabBar(),
                      ),
                      if (vmUrl != null && _tabIndex == 1)
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return VmSelectScreen(
                                latitude: latitude,
                                longitude: longitude,
                              );
                            }));
                          },
                          child: Column(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: 72,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        border:
                                            Border.all(color: Colors.blueGrey),
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Card(
                                                    color: CupertinoColors
                                                        .secondarySystemBackground,
                                                    elevation: 2,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    child: (vmUrl! != null)
                                                        ? SizedBox(
                                                            width: 40,
                                                            height: 40,
                                                            child: FadeInImage
                                                                .memoryNetwork(
                                                              placeholder:
                                                                  kTransparentImage,
                                                              image: vmUrl!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : SizedBox(
                                                            width: 40,
                                                            height: 40,
                                                            child: Image.asset(
                                                                'assets/images/icons-colored-05.png'),
                                                          )),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 220,
                                                    child: Text(
                                                        vmName.toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    104,
                                                                    104,
                                                                    104),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                  Text(vmArea.toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            CupertinoTheme.of(
                                                                    context)
                                                                .primaryColor,
                                                      )),
                                                  Text(vmCode.toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Card(
                                                    color: CupertinoColors
                                                        .secondarySystemBackground,
                                                    elevation: 2,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    child: SizedBox(
                                                      width: 30,
                                                      height: 30,
                                                      child: Image.asset(
                                                          'assets/images/icons-colored-05.png'),
                                                    )),
                                              ),
                                            ],
                                          ))),
                                ),
                              ],
                            )
                          ]),
                        ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 25),
                        height: MediaQuery.of(context).size.height * 78 / 100,
                        child: _cartBuilder(),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 7 / 100,
          color: CupertinoColors.white,
          child: _bottomNavbar()),
    );
  }

  Widget _tabBar() {
    return CupertinoSlidingSegmentedControl(
      backgroundColor: Colors.white,
      thumbColor: CupertinoTheme.of(context).primaryColor,
      children: {
        0: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Mall'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: (_tabIndex == 0)
                    ? Colors.white
                    : const Color.fromARGB(255, 88, 88, 88)),
          ),
        ),
        1: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Vending Machine'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: (_tabIndex == 1)
                    ? Colors.white
                    : const Color.fromARGB(255, 88, 88, 88)),
          ),
        ),
      },
      groupValue: _tabIndex,
      onValueChanged: (value) {
        if (mounted) {
          setState(() {
            _tabIndex = value as int?;
          });

          refreshList();
        }
      },
    );
  }

  _showClear(BuildContext context) {
    Widget cancelButton = CupertinoButton(
      key: const Key("pop_button"),
      child: Text(
        'Cancel'.tr,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = CupertinoButton(
      child: Text(
        'Clear'.tr,
        style: const TextStyle(
          color: Color.fromARGB(255, 255, 0, 0),
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        setState(() {
          totalCart = totalCart - 1;
        });
        _removeItem(_cartList!);
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
                "Are you sure you want to clear your cart?",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  continueButton,
                  cancelButton,
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

  Widget _bottomNavbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () async {
            _showClear(context);
          },
          child: Container(
            color: Colors.red[500],
            height: MediaQuery.of(context).size.height * 8 / 100,
            width: MediaQuery.of(context).size.width * 20 / 100,
            child: Center(
                child: Text(
              'Clear'.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  color: CupertinoColors.white),
            )),
          ),
        ),
        const Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('SubTotal'.tr),
            Text(
              'RM ' + total.toStringAsFixed(2),
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
        Visibility(
          visible: (totalCart > 0 && unavailableList.isEmpty),
          replacement: Container(
            color: CupertinoColors.inactiveGray,
            height: MediaQuery.of(context).size.height * 8 / 100,
            width: MediaQuery.of(context).size.width * 20 / 100,
            child: Center(
              child: Text(
                'Checkout'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: CupertinoColors.white),
              ),
            ),
          ),
          child: GestureDetector(
            key: const Key("checkout"),
            onTap: () async {
              orderList.removeWhere((element) => element['product_id'] == '');
              orderNameList
                  .removeWhere((element) => element['product_name'] == '');
              orderNameList
                  .removeWhere((element) => element['product_url'] == '');
              orderList.removeWhere((element) => element['quantity'] == 0);
              orderNameList.removeWhere((element) => element['quantity'] == 0);
              facebookAppEvents.logInitiatedCheckout();
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return CheckoutProductScreen(
                cart: _cartList,
                  from: 3,
                  method: _tabIndex,
                  originalPrice: total.toStringAsFixed(2),
                  orderList: orderList,
                  orderNameList: orderNameList,
                  vm_id: vm_id,
                );
              })).then((value) {
                if (value == true) {
                  retrieveList();
                  refreshList();
                }
              });
            },
            child: Container(
              color: CupertinoTheme.of(context).primaryColor,
              height: MediaQuery.of(context).size.height * 8 / 100,
              width: MediaQuery.of(context).size.width * 20 / 100,
              child: Center(
                  child: Text(
                'Checkout'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: CupertinoColors.white),
              )),
            ),
          ),
        ),
      ],
    );
  }

  _cartBuilder() {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if ((snapshot.data != null) && (_cartList!.isNotEmpty)) {
          return Scrollbar(
            controller: _scrollController,
            child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: (snapshot.data != null) ? _cartList!.length : 0,
                itemBuilder: (context, index) {
                  orderQuantityList.add(0);
                  orderTotalList.add(0);
                  orderList.add({
                    'product_id': '',
                    'quantity': 0,
                    'price': 0,
                    'total': 0.00,
                  });
                  orderNameList.add({
                    'product_name': '',
                    'proudct_url': '',
                    'quantity': 0,
                  });
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return CatalogDescriptionScreen(
                          index: index,
                          catalog: catalog,
                          orderList: orderList,
                          orderNameList: orderNameList,
                          orderQuantityList: orderQuantityList,
                          method: _tabIndex,
                          vendingMachine: vm,
                        );
                      }));
                    },
                    child: CartAdapter(
                      item: _cartList!,
                      index: index,
                      add: () async {
                        if (vm == null &&
                            _cartList![index]['quantity'] ==
                                _cartList![index]['stock_quantity']) {
                          Toast.show(context, "danger", 'Item Out of Stock');
                        } else {
                          if (_cartList![index]['vm_id'] == null) {
                            setState(() {
                              _cartList![index]['quantity'] =
                                  _cartList![index]['quantity'] + 1;
                              orderNameList[index]['quantity'] =
                                  _cartList![index]['quantity'];
                              _cartList![index]['sub_total'] = double.parse(
                                      _cartList![index]['sub_total']
                                          .toString()) +
                                  double.parse(
                                      _cartList![index]['price'].toString());
                            });
                            var response =
                                await CatalogCart.addItem(context, _cartList!);
                            if (response!.status) {
                              _refreshTotal();
                            }
                          } else {
                            if (_cartList![index]['quantity'] < 3 &&
                                _cartList!.length < 3 &&
                                totalCart < 3) {
                              setState(() {
                                _cartList![index]['quantity'] =
                                    _cartList![index]['quantity'] + 1;
                                orderNameList[index]['quantity'] =
                                    _cartList![index]['quantity'];
                                orderList[index]['quantity'] =
                                    _cartList![index]['quantity'];
                                _cartList![index]['sub_total'] = double.parse(
                                        _cartList![index]['sub_total']
                                            .toString()) +
                                    double.parse(
                                        _cartList![index]['price'].toString());
                              });
                              var response = await CatalogCart.addItemVM(
                                  context,
                                  _cartList!,
                                  _cartList![index]['vm_id']);
                              if (response != null) {
                                _refreshTotal();
                              }
                            } else {
                              Toast.show(context, "danger", "Cart is full");
                            }
                          }
                        }
                      },
                      minus: () async {
                        setState(() {
                          if (_cartList![index]['quantity'] > 1) {
                            _cartList![index]['quantity'] =
                                _cartList![index]['quantity'] - 1;
                            orderNameList[index]['quantity'] =
                                _cartList![index]['quantity'];
                            orderList[index]['quantity'] =
                                _cartList![index]['quantity'];
                            _cartList![index]['sub_total'] = double.parse(
                                    _cartList![index]['sub_total'].toString()) -
                                double.parse(
                                    _cartList![index]['price'].toString());
                          }
                        });
                        if (_cartList![index]['vm_id'] == null) {
                          var response =
                              await CatalogCart.addItem(context, _cartList!);
                          if (response != null) {
                            _refreshTotal();
                          }
                        } else {
                          var response = await CatalogCart.addItemVM(
                              context, _cartList!, _cartList![index]['vm_id']);
                          if (response != null) {
                            _refreshTotal();
                          }
                        }
                      },
                      delete: () {
                        for (int i = 0; i < _cartList!.length; i++) {
                          if (index == i) {
                            tempList.add(_cartList![i]);
                          }
                        }
                        setState(() {
                          totalCart = totalCart - 1;
                        });
                        _removeItem(tempList);
                      },
                    ),
                  );
                }),
          );
        } else {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.bottom -
                    100,
                child: Center(
                  child: Visibility(
                    visible: (snapshot.data != null),
                    replacement: IntrinsicHeight(
                        child: ConnectionError(onRefresh: refreshList)),
                    child: Text('Empty list, pull to refresh.'.tr),
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      },
    );
  }
}
