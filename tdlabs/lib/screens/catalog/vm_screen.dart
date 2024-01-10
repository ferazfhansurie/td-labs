// ignore_for_file: library_prefixes, must_be_immutable, non_constant_identifier_names, unnecessary_null_comparison, unused_local_variable

import 'dart:convert';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlabs/models/commerce/cart.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/screens/checkout/checkout_product.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:tdlabs/widgets/form/order_counter.dart';
import 'package:get/get.dart' as Get;
import 'package:tdlabs/widgets/sliver/sliver_appbar_catalog.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../adapters/catalog/catalog_adapter.dart';

class VmScreen extends StatefulWidget {
  int? tab;
  VendingMachine? vm;
  String? search;
  int? categoryId;
  int? selected;
  bool? free;
  VmScreen(
      {Key? key,
      this.tab,
      this.vm,
      this.search,
      this.categoryId,
      this.selected,
      this.free})
      : super(key: key);

  @override
  _VmScreenState createState() => _VmScreenState();
}

class _VmScreenState extends State<VmScreen>
    with SingleTickerProviderStateMixin {
  final List<Catalog> _listProduct = [];
  Future<List<Catalog>?>? _future;
  Future<List<Catalog>?>? _future2;
  int orderQuantity = 0;
  int price = 15;
  double subTotal = 0;
  double total = 0.0;
  int vm_id = 0;
  int i = 0;
  List<int> orderQuantityList = [];
  List<double> orderTotalList = [];
  bool isLoading = false;
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderNameList = [];
  bool isListView = false;
  SubTotalController subTotalController = Get.Get.put(SubTotalController());
  String vendingMachine = "";
  String? latitude;
  String? longitude;
  int _page = 0;
  int _pageCount = 1;
  VendingMachine? _vm;
  int? vmId;
  List<Map<String, dynamic>>? _listCart;
  ScrollController _scrollController = ScrollController();
  final GlobalKey progressDialogKey = GlobalKey<State>();
  int totalCart = 0;
  String _search = "";
  final List<Catalog> _listCategory = [];
  List<Catalog> _subcategoryList = [];
  int totalSub = 0;
  int? categoryId;
  int _selected = 0;
  static final facebookAppEvents = FacebookAppEvents();
  String categoryName = "All";
  int _pickerIndex = 0;
  @override
  void initState() {
    // implement initState
    if (widget.selected != null) {
      _selected = widget.selected!;
    }
    if (widget.categoryId != null) {
      categoryId = widget.categoryId;
    }
    _vm = widget.vm;
    if (_vm!.vm_id != null) {
      vmId = widget.vm!.vm_id;
    } else {
      vmId = widget.vm!.id;
    }

    if (_vm!.vm_name != null) { 
      vendingMachine = _vm!.vm_name! + " " + " " + _vm!.vm_area_name!;
    } else {
      vendingMachine = _vm!.name! + " " + " " + _vm!.area_name!;
    }

    super.initState();
    _future2 = _fetchCategory(context);
    if (widget.search != null) {
      _performSearch(keyword: widget.search);
    } else {
      _refreshList();
      _future = _fetchProducts();
    }
    _scrollController = ScrollController(initialScrollOffset: 5);
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              (_scrollController.position.maxScrollExtent - 100) &&
          !_scrollController.position.outOfRange) {
        setState(() {
          _future = _fetchProducts();
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
    orderNameList.clear();
    orderTotalList.clear();
  }

  void _performSearch({String? keyword}) {
    if (keyword != null) {
      setState(() {
        _search = keyword;
        _listProduct.clear();
        _page = 0;
        _pageCount = 1;
      });
    } else {
      _search == "";
    }
    _future = _fetchProducts();
  }

  void retrieveList() {
    for (i = 0; i < _listProduct.length; i++) {
      Catalog products = _listProduct[i];
      orderList.add({
        'product_id': _listProduct[i].id,
        'quantity': (orderQuantityList[i] != 0)
            ? orderQuantityList[i]
            : _listCart![i]['quantity'],
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
    orderList.removeWhere((element) => element['product_id'] == '');
    orderNameList.removeWhere((element) => element['product_url'] == '');
    orderNameList.removeWhere((element) => element['product_name'] == '');
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
    orderList.removeWhere((element) => element['product_id'] == '');
    orderNameList.removeWhere((element) => element['product_url'] == '');
    orderNameList.removeWhere((element) => element['product_name'] == '');
  }

  Widget _catalogView2(double itemWidth, double itemHeight) {
    return RefreshIndicator(
      color: CupertinoTheme.of(context).primaryColor,
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
                  mainAxisSpacing: 0,
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
                    key: Key("vm_tap " + index.toString()),
                    index: index,
                    method: 0,
                    originalPrice: total.toStringAsFixed(2),
                    orderList: orderList,
                    orderNameList: orderNameList,
                    orderQuantityList: orderQuantityList,
                    orderTotalList: orderTotalList,
                    catalog: products,
                    isListView: false,
                    vendingMachine: _vm,
                    free: widget.free,
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
                        child: Text('Fetching Products'.tr),
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

  Widget _bottomNavbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('SubTotal'.tr),
            Text( 'RM ' + total.toStringAsFixed(2),
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
                            method: 1,
                            vendingMachine: _vm,
                            vm_id: _vm!.vm_id,
                            originalPrice: total.toStringAsFixed(2),
                            orderList: orderList,
                            orderNameList: orderNameList,
                            free: widget.free,
                          ))).then((result) {
                if (result != null && result == true) {
                  _refreshList();
                }
              });
            },
            child: Container(
              color: const Color.fromARGB(255, 24, 112, 141),
              height: MediaQuery.of(context).size.height * 8 / 100,
              width: MediaQuery.of(context).size.width * 20 / 100,
              child: Center(
                  child: Text(
                'Checkout'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
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
      key: const Key("vm_screen"),
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
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                        name: (_vm!.vm_name != null) ? _vm!.vm_name! : _vm!.name!,
                        category: categoryName,
                        search: (value) => _performSearch(keyword: value,),
                        type: 1,
                        vm: widget.vm,
                        showPicker: _showPicker),
                    pinned: true,
                  ),
                  const SliverPadding(padding: EdgeInsets.all(4)),
                  _categoryBuilder(),
                  _catalogBuilder(itemWidth, itemHeight)
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

  Widget _catalogBuilder(double itemWidth, double itemHeight) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (vmId != null) {
            if (!isLoading || _listProduct.isNotEmpty) {
              if (_listProduct.isNotEmpty) {
                return _catalogView2(itemWidth, itemHeight);
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
          } else {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 105),
              child: Center(
                child: Text(
                  'Please select vending machine'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        },
        childCount: 1,
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
                                      await _fetchSubCategory( context, category.id!);
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
                                            ? const Color.fromARGB(
                                                255, 238, 238, 238)
                                            : Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
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
                scrollController:FixedExtentScrollController(initialItem: _pickerIndex),
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
                            Navigator.pop(context);
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                              return VmScreen(
                                selected: _selected,
                                vm: widget.vm,
                                categoryId: (category.name != "All")
                                    ? category.id
                                    : null,
                              );
                            }));
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

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
    _future = _fetchProducts();
  }

  Future<List<dynamic>?> _fetchCart() async {
    total = 0;
    var response = await CatalogCart.fetchCart(context, 1);
    if (response == null) return null;
    if (response.status) {
      _listCart =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      var items = 0;
      for (int i = 0; i < _listCart!.length; i++) {
        setState(() {
          total = total + double.parse(_listCart![i]["sub_total"]);
          items = items + int.parse(_listCart![i]['quantity'].toString());
        });
      }
      totalCart = items;
    }

    return _listCart;
  }

  Future<List<Catalog>?> _fetchSubCategory(BuildContext context, int id) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('catalog/product-categories');
    Map<String, String> filter = {};
    filter.addAll({"parent_category": id.toString()});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      if (mounted) {
        setState(() {
          _subcategoryList =parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
          totalSub = _subcategoryList.length;
        });
      }
    }
    return _subcategoryList;
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
      List<Catalog> products =parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _listCategory.addAll(products);
        });
      }
    }
    return _listCategory;
  }

  Future<List<Catalog>?> _fetchProducts() async {
    final webService = WebService(context);
    if (isLoading == false && (_page < _pageCount)) {
      setState(() {
        _page++;
      });
      webService.setEndpoint('catalog/catalog-products').setPage(_page);
      Map<String, String> filter = {};
      filter.addAll({'type': '1'});
      filter.addAll({'is_disabled': '0'});
      filter.addAll({'is_vm_stock': '1'});
      if (_search != "") {
        filter.addAll({'search': _search});
      }
      if (vmId != null) filter.addAll({'vm_id': vmId.toString()});
      if (categoryId != null) {
        filter.addAll({'category_id': categoryId.toString()});
      }
      isLoading = true;
      var response = await webService.setFilter(filter).send();
      isLoading = false;
      if (response == null) return null;
      if (response.status) {
        final parseList =
            jsonDecode(response.body!).cast<Map<String, dynamic>>();
        List<Catalog> catalogProducts =
            parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
        setState(() {
          for (int i = 0; i < catalogProducts.length; i++) {
            _listProduct.addIf(
                catalogProducts[i].in_stock == 1, catalogProducts[i]);
          }
        });
        _pageCount = response.pagination!['pageCount']!;
      }
    }

    return _listProduct;
  }
}
