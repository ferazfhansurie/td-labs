// ignore_for_file: library_prefixes, prefer_final_fields

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlabs/widgets/form/order_counter.dart';
import '../../adapters/catalog/catalog_adapter copy.dart';
import '../../models/commerce/cart.dart';
import '../../models/commerce/catalog.dart';
import '../../utils/web_service.dart';
import 'package:get/get.dart' as Get;
import 'cart_screen.dart';

// ignore: must_be_immutable
class VM extends StatefulWidget {
  int? categoryId;
  VM({Key? key, this.categoryId}) : super(key: key);
  @override
  _VMState createState() => _VMState();
}
class _VMState extends State<VM> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  final List<Catalog> _listProduct = [];
  List<dynamic>? _listCart;
  int orderQuantity = 0;
  int price = 15;
  double subTotal = 0;
  int i = 0;
  List<int> orderQuantityList = [];
  List<double> orderTotalList = [];
  bool isLoading = true;
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderNameList = [];
  bool isListView = false;
  int totalCart = 0;
  double total = 0.0;
  String _search = "";
  SubTotalController subTotalController = Get.Get.put(SubTotalController());
  @override
  void initState() {
    // implement initState
    super.initState();
    _refreshList();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }
  @override
  void dispose() {
    //implement dispose
    super.dispose();
    _listProduct.clear();
    orderQuantityList.clear();
    orderNameList.clear();
    _animationController!.dispose();
    orderTotalList.clear();
  }
  void retrieveList() {
    for (i = 0; i < _listProduct.length; i++) {
      Catalog products = _listProduct[i];
      orderList.add({
        'product_id': _listProduct[i].id,
        'quantity': orderQuantityList[i],
        'price': products.price,
        'total': orderTotalList[i],
        'cart_type': 0
      });
      orderNameList.add({
        'product_name': _listProduct[i].name,
        'quantity': orderQuantityList[i]
      });
    }
  }
  Widget _catalogView2(double itemWidth, double itemHeight) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 70 / 100,
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: (itemWidth / itemHeight),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 150),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _listProduct.length,
        itemBuilder: (context, index) {
          // ignore: unused_local_variable
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
              'quantity': 0,
            });
          }
          Catalog products = _listProduct[index];
          // ignore: unused_local_variable
          String description = products.description!;
          return Padding(
            padding: const EdgeInsets.all(1),
            child: CatalogAdapter2(
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
            ),
          );
        },
      ),
    );
  }

  Future<List<dynamic>?> _fetchCart() async {
    var response = await CatalogCart.fetchCart(context, 0);
    if (response == null) return null;
    if (response.status) {
      _listCart =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      totalCart = _listCart!.length;
      for (int i = 0; i < _listCart!.length; i++) {
        setState(() {
          total = total + double.parse(_listCart![i]["sub_total"]);
        });
      }
    }

    return _listCart;
  }

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 3;
    double itemHeight = 160;
    return Scaffold(
      body: CupertinoPageScaffold(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
               
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ClipRRect(
                      child: Image.asset(
                        'assets/images/vm_banner.jpg',
                        height: MediaQuery.of(context).size.height * 25 / 100,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      color: CupertinoTheme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "WELCOME".tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                        return CartScreen(
                                          tab: 0,
                                        );
                                      }));
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "Category - ".tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: CupertinoTheme.of(context).primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          Icons.local_hospital_outlined,
                                          color: CupertinoTheme.of(context).primaryColor,
                                          size: 25,
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                        return CartScreen(
                                          tab: 0,
                                        );
                                      }));
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "View Cart - ".tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: CupertinoTheme.of(context).primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Stack(
                                          children: [
                                            Icon(
                                              Icons.shopping_cart_outlined,
                                              color: CupertinoTheme.of(context).primaryColor,
                                              size: 25,
                                            ),
                                            Positioned(
                                              top: 0.0,
                                              right: 0.0,
                                              child: Container(
                                                padding: const EdgeInsets.all(1),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
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
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RefreshIndicator(
                      color: CupertinoTheme.of(context).primaryColor,
                      onRefresh: _refreshList,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 100,
                          child: Column(
                            children: [
                              (!isLoading)
                                  ? (_listProduct.isNotEmpty)
                                      ? _catalogView2(itemWidth, itemHeight)
                                      : SizedBox(
                                          width:MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size .height *40 /100,
                                          child: Center(
                                              child: Text(
                                            'No product found. Pull to refresh'.tr,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          )),
                                        )
                                  : SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height:MediaQuery.of(context).size.height *40 /100,
                                      child: const Center(
                                          child: CircularProgressIndicator()),
                                    ),
                            ],
                          ),
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
    );
  }

  Future<void> _refreshList() async {
    setState(() {
      total.toStringAsFixed(2);
      isLoading = true;
      _listProduct.clear();
    });
    _fetchCart();
    _fetchProducts(context);
  }

  Future<List<Catalog>?> _fetchProducts(BuildContext context) async {
    final webService = WebService(context);
    webService.setEndpoint('catalog/catalog-products');
    Map<String, String> filter = {};
    filter.addAll({'type': '1'});
    filter.addAll({'is_disabled': '0'});
    filter.addAll({'is_mall_stock': '1'});
    if (_search != "") {
      filter.addAll({'search': _search});
    }
    if (widget.categoryId != null) {
      filter.addAll({'category_id': widget.categoryId.toString()});
    }
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Catalog> products =
          parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _listProduct.addAll(products);
          isLoading = false;
        });
      }
    }
    return _listProduct;
  }
}
