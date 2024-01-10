// ignore_for_file: library_prefixes, must_be_immutable, unnecessary_null_comparison, unused_local_variable, duplicate_ignore, unnecessary_new

import 'dart:convert';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlabs/screens/checkout/checkout_product.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:tdlabs/widgets/form/order_counter.dart';
import 'package:tdlabs/widgets/sliver/sliver_appbar_catalog.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../adapters/catalog/catalog_adapter.dart';
import '../../models/commerce/cart.dart';
import '../../models/commerce/catalog.dart';
import '../../utils/web_service.dart';
import 'package:get/get.dart' as Get;
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  int? categoryId;
  String? search;
  int? selected;
  bool? promo;
  CatalogScreen({
    Key? key,
    this.categoryId,
    this.search,
    this.selected,
    this.promo,
  }) : super(key: key);

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  final List<Catalog> _listProduct = [];
  List<Map<String, dynamic>>? _listCart;
  int orderQuantity = 0;
  int price = 15;
  double subTotal = 0;
  int i = 0;
  List<int> orderQuantityList = [];
  List<double> orderTotalList = [];
  bool isLoading = false;
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderNameList = [];
  bool isListView = false;
  int totalCart = 0;
  double total = 0.0;
  String _search = "";
  SubTotalController subTotalController = Get.Get.put(SubTotalController());
  final List<Catalog> _listCategory = [];
  Future<List<Catalog>?>? _future;
  Future<List<Catalog>?>? _future2;
  List<Catalog> _subcategoryList = [];
  int totalSub = 0;
  int? categoryId;
  int _selected = 0;
  ScrollController _scrollController = ScrollController();
  int _page = 0;
  int _pageCount = 1;
  String categoryName = "All";
  int _pickerIndex = 0;
  static final facebookAppEvents = FacebookAppEvents();
  @override
  void initState() {
    // implement initState
    super.initState();

    if (widget.selected != null) {
      _selected = widget.selected!;
    }
    _fetchCart();
    if (widget.categoryId != null) {
      setState(() {
        categoryId = widget.categoryId;
        _refreshList();
      });
      if (widget.promo == true) {
        _future2 = _fetchCategory(context);
      }
    } else {
      _future2 = _fetchCategory(context);
    }
    if (widget.search != null) {
      _performSearch(keyword: widget.search);
    } else {
      _future = _fetchProducts(context);
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scrollController = ScrollController(initialScrollOffset: 5);
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              (_scrollController.position.maxScrollExtent - 100) &&
          !_scrollController.position.outOfRange) {
        setState(() {
          _future = _fetchProducts(context);
        });
      }
    });
  }

  @override
  void dispose() {
    //implement dispose
    super.dispose();
    _listProduct.clear();
    orderQuantityList.clear();
    orderList.clear();
    orderNameList.clear();
    _animationController!.dispose();
    orderTotalList.clear();
  }

  void retrieveList() {
    for (i = 0; i < _listProduct.length; i++) {
      Catalog products = _listProduct[i];
      orderList.add({
        'product_id': _listProduct[i].id,
        'quantity': (orderQuantityList[i] != 0)
            ? orderQuantityList[i]
            : (_listCart![i]['quantity'] != null)
                ? _listCart![i]['quantity']
                : 0,
        'price': products.price,
        'total': orderTotalList[i],
        'cart_type': 0
      });
      orderNameList.add({
        'product_name': _listProduct[i].name,
        'product_url': _listProduct[i].image_url,
        'quantity': (orderQuantityList[i] != 0)
            ? orderQuantityList[i]
            : _listCart![i]['quantity'],
      });
    }
  }

  void retrieveCart() {
    orderList = [];
    orderNameList = [];
    for (i = 0; i < _listCart!.length; i++) {
      orderList.add({
        'product_id': _listCart![i]['product_id'],
        'quantity': _listCart![i]['quantity'],
        'price': _listCart![i]['price'],
        'total': _listCart![i]['sub_total'],
        'cart_type': 0
      });
      orderNameList.add({
        'product_name': _listCart![i]['name'],
        'product_url': _listCart![i]['image_url'],
        'quantity': _listCart![i]['quantity'],
      });
    }
  }

  Widget _catalogView2(double itemWidth, double itemHeight) {
    return RefreshIndicator(
      color: Colors.white,
      onRefresh: _refreshList,
      child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if ((snapshot.data != null)) {
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: (itemWidth / itemHeight),
                ),
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 100),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _listProduct.length,
                itemBuilder: (context, index) {
                  for (var i in _listProduct) {
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
                  }
                  Catalog products = _listProduct[index];
                  return CatalogAdapter(
                    key: Key("mall_tap " + index.toString()),
                    index: index,
                    method: 1,
                    originalPrice: total.toStringAsFixed(2),
                    orderList: orderList,
                    orderNameList: orderNameList,
                    orderQuantityList: orderQuantityList,
                    orderTotalList: orderTotalList,
                    overlay: products.overlay_name,
                    catalog: products,
                    isListView: false,
                    refresh: _refreshList,
                  );
                },
              );
            } else {
              if (snapshot.connectionState == ConnectionState.done) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height -MediaQuery.of(context).padding.top -44,
                    child: Center(
                      child: Visibility(
                        visible: (snapshot.data != null),
                        replacement: IntrinsicHeight(
                            child: ConnectionError(onRefresh: _refreshList)),
                        child: Text('No result found.'.tr),
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }
          }),
    );
  }

  Widget _catalogView1() {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 150),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _listProduct.length,
        itemBuilder: (context, index) {
          // ignore: unused_local_variable, curly_braces_in_flow_control_structures
          for (var i in _listProduct) {
            orderQuantityList.add(0);
            orderTotalList.add(0);
            orderList.add({
              'product_id': '',
              'quantity': 0,
              'total': 0.00,
              'price': 0,
            });
            orderNameList.add({
              'product_name': '',
              'product_url': '',
              'quantity': 0,
            });
          }
          Catalog products = _listProduct[index];
          // ignore: unused_local_variable
          String description = products.description!;
          return CatalogAdapter(
            catalog: products,
            orderCounter: OrderCounter(
              product: products,
              index: index,
              orderQuantityList: orderQuantityList,
              orderList: orderList,
              orderNameList: orderNameList,
              orderTotalList: orderTotalList,
            ),
            isListView: true,
          );
        },
      ),
    );
  }

  void _performSearch({String? keyword}) {
    // Reset list

    if (keyword != null) {
      setState(() {
        _page = 0;
        _pageCount = 1;
        _search = keyword;
        _listProduct.clear();
      });
    } else {
      _search == "";
    }
    _future = _fetchProducts(context);
  }

  Future<List<dynamic>?> _fetchCart() async {
    total = 0;
    var response = await CatalogCart.fetchCart(context, 0);
    if (response == null) return null;
    if (response.status) {
      _listCart =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      totalCart = _listCart!.length;
      for (int i = 0; i < _listCart!.length; i++) {
        if (mounted) {
          setState(() {
            
            total = total + double.parse(_listCart![i]["sub_total"]);
          });
        }
      }
    }

    return _listCart;
  }

  Widget _bottomNavbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(
          width: 175,
        ),
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
          visible: totalCart > 0,
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
            onTap: () async {
              orderList.removeWhere((element) => element['product_id'] == '');
              orderNameList.removeWhere((element) => element['product_name'] == '');
              orderNameList.removeWhere((element) => element['product_url'] == '');
              orderList.removeWhere((element) => element['quantity'] == 0);
              orderNameList.removeWhere((element) => element['quantity'] == 0);
              retrieveCart();
              facebookAppEvents.logInitiatedCheckout();
              Navigator.push(context,MaterialPageRoute(
                      builder: (context) => CheckoutProductScreen(
                        cart: _listCart,
                            method: 0,
                            originalPrice: total.toStringAsFixed(2),
                            orderList: orderList,
                            orderNameList: orderNameList,
                          ))).then((result) {
                if (result != null && result == true) {
                  _refreshList();
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

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 2;
    double itemHeight = 220;
    return Scaffold(
      key: const Key("mall_screen"),
      body: CupertinoPageScaffold(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Background-02.png"),
                    fit: BoxFit.fill),
              ),
              padding: EdgeInsets.only(top: 25),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                slivers: [
                  SliverPersistentHeader(
                    delegate: CustomSliverAppBarCatalogDelegate(
                        expandedHeight: 75,
                        name: categoryName,
                        category: categoryName,
                        search: (value) => _performSearch( keyword: value,),
                        type: 0,
                        showPicker: _showPicker),
                    pinned: true,
                  ),
                  const SliverPadding(padding: EdgeInsets.all(4)),
                  _categoryBuilder(),
                  _catalogBuilder(itemWidth, itemHeight),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 7 / 100,
          color: CupertinoColors.white,
          child: _bottomNavbar()),
    );
  }

  Future<void> _refreshList() async {
    setState(() {
      total.toStringAsFixed(2);
      _listProduct.clear();
      _page = 0;
      _pageCount = 1;
      isLoading = false;
    });
    _fetchCart();
    _future = _fetchProducts(context);
  }

  Widget header() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.topLeft,
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
              "TD Mall".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (context) {
                    return CartScreen(
                      tab: 0,
                    );
                  }));
                },
                child: Stack(
                  children: const [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                )),
            GestureDetector(
              onTap: () {},
              child: const Icon(
                CupertinoIcons.ellipsis,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryBuilder() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            Card(
              elevation: 5,
              child: SizedBox(
                width: double.infinity,
                height: 80,
                child: FutureBuilder(
                    future: _future2,
                    builder: (context, snapshot) {
                      if ((snapshot.data != null)) {
                        return SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.only(
                                  bottom:MediaQuery.of(context).padding.bottom),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _listCategory.length,
                              itemBuilder: (context, index) {
                                Catalog category = _listCategory[index];
                                String description = category.name!;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _selected = index;
                                        categoryId = category.id;
                                        categoryName = category.name!;
                                      });
                                      await _fetchSubCategory(context, category.id!);
                                      if (totalSub < 2) {
                                        _refreshList();
                                      } else {
                                        showSubCategory(context);
                                      }
                                    },
                                    child: Container(
                                      width: 70,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:BorderRadius.circular(100),
                                        color: (index == _selected)
                                            ? const Color.fromARGB(255, 238, 238, 238)
                                            : Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: Column(
                                          mainAxisAlignment:MainAxisAlignment.center,
                                          crossAxisAlignment:CrossAxisAlignment.center,
                                          children: [
                                            (category.image_url != null)
                                                ? SizedBox(
                                                    height: 40,
                                                    width: 40,
                                                    child: FadeInImage.memoryNetwork(
                                                      placeholder:kTransparentImage,
                                                      image:category.image_url!,
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    height: 35,
                                                    width: 35,
                                                    child: Icon(
                                                      CupertinoIcons.cart,
                                                      size: 25,
                                                    ),
                                                  ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Text(category.name!.tr,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  overflow:TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: const Text(
                            "Fetching Category",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w300),
                          ),
                        );
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catalogBuilder(double itemWidth, double itemHeight) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (!isLoading || _listProduct.isNotEmpty) {
            if (_listProduct.isNotEmpty) {
              if (isListView) {
                return _catalogView1();
              } else {
                return _catalogView2(itemWidth, itemHeight);
              }
            } else {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.4,
                child: const Center(
                  child: Text(
                    "No Item Found",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              );
            }
          } else {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        },
        childCount: 1,
      ),
    );
  }

  _showPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () async {
                      _page = 0;
                      _pageCount = 1;
                      setState(() {
                        _selected = _pickerIndex;
                        categoryId = _listCategory[_pickerIndex].id!;
                        categoryName = _listCategory[_pickerIndex].name!;
                      });
                      await _fetchSubCategory(context, categoryId!);
                      if (totalSub < 2) {
                        _refreshList();
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        showSubCategory(context);
                      }
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: _pickerIndex),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    _pickerIndex = value;
                  });
                },
                itemExtent: 32.0,
                children: [
                  for (var session in _listCategory)
                    Text(
                      session.name!,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  showSubCategory(BuildContext context) {
    // set up the AlertDialog
    Widget alert = Container(
      height: 200,
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              'Choose Sub-Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            content: SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(5),
                    itemCount: _subcategoryList.length,
                    itemBuilder: (context, index) {
                      Catalog category = _subcategoryList[index];
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              categoryId = category.id;
                            });
                            Navigator.pop(context);
                            _refreshList();
                          },
                          child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(category.name!),
                              )),
                        ),
                      );
                    })),
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

  Future<List<Catalog>?> _fetchCategory(BuildContext context) async {
    final webService = WebService(context);
    webService.setEndpoint('catalog/product-categories');
    Map<String, String> filter = {};
    filter.addAll({'depth': "1"});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Catalog> products = parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _listCategory.addAll(products);
        });
      }
    }
    return _listCategory;
  }

  Future<List<Catalog>?> _fetchProducts(BuildContext context) async {
    final webService = WebService(context);
    if (isLoading == false && (_page < _pageCount)) {
      setState(() {
        _page++;
      });
      webService.setEndpoint('catalog/catalog-products').setPage(_page);
      Map<String, String> filter = {};
      filter.addAll({'type': '1'});
      filter.addAll({'is_disabled': '0'});
      if (_search != "") {
        filter.addAll({'search': _search});
      }
      if (categoryId != null) {
        filter.addAll({'category_id': categoryId.toString()});
      }
      isLoading = true;
      var response = await webService.setFilter(filter).send();
      isLoading = false;
      if (response == null) return null;
      if (response.status) {
        final parseList = jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<Catalog> products = parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            _listProduct.addAll(products);
          });
          _pageCount = response.pagination!['pageCount']!;
        }
      }
    }
    return _listProduct;
  }

  Future<List<Catalog>?> _fetchSubCategory(BuildContext context, int id) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('catalog/product-categories');
    Map<String, String> filter = {};
    filter.addAll({"parent_category": id.toString()});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList = jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      if (mounted) {
        setState(() {
          _subcategoryList =parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
          totalSub = _subcategoryList.length;
        });
      }
    }
    return _subcategoryList;
  }
}
