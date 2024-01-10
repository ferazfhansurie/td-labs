// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/content/banners.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/screens/catalog/catalog_screen.dart';
import 'package:tdlabs/screens/catalog/vm_type.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/carousel/carousel_shop.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<Banners> _listBanner = [];
  final List<String> _listImages = [];
  List<int> orderQuantityList = [];
  List<double> orderTotalList = [];
  bool isLoading = false;
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderNameList = [];
  final List<Catalog> _listProduct = [];
  final _searchController = TextEditingController();
  String latitude = "";
  String longitude = "";
  @override
  void initState() {
    _fetchProducts(context);
    _fetchBanners();
    super.initState();
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
  }

  Future<List<Catalog>?> _fetchProducts(BuildContext context) async {
    final webService = WebService(context);
    webService.setEndpoint('catalog/catalog-products');
    Map<String, String> filter = {};
    filter.addAll({'type': '1'});
    filter.addAll({'is_disabled': '0'});
    filter.addAll({'category_id': 4.toString()});

    isLoading = true;
    var response = await webService.setFilter(filter).send();
    isLoading = false;
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Catalog> products =
          parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _listProduct.addAll(products);
        });
      }
    }

    return _listProduct;
  }

  Future<List<Banners>?> _fetchBanners() async {
    _listBanner.clear();
    final webService = WebService(context);
    webService.setEndpoint('feed/banners');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Banners> banners =
          parseList.map<Banners>((json) => Banners.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _listBanner.addAll(banners);
          for (int i = 0; i < _listBanner.length; i++) {
            _listImages.add(_listBanner[i].imageUrl);
          }
        });
      }
    }
    return _listBanner;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        decoration: const BoxDecoration(),
        padding: EdgeInsets.only(
         top:30,
        ),
        width: double.infinity,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 30,
                    ),
                    child: CarouselShop(
                      images: _listImages,
                      height: MediaQuery.of(context).size.height * 25 / 100,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 110,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (){
                              Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return CatalogScreen();
                }));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(255, 236, 236, 236)
                                            .withOpacity(0.4),
                                        spreadRadius: 2,
                                        blurRadius: 1,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                      'assets/images/icons-colored-02.png',
                                      fit: BoxFit.cover)),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "E-Commerce",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              )
                            ],
                          ),
                        ),
                          const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: (){
                             Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return VmTypeScreen(
                    latitude:latitude,
                    longitude:longitude,
                  );
                }));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(255, 236, 236, 236)
                                            .withOpacity(0.4),
                                        spreadRadius: 2,
                                        blurRadius: 1,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                      'assets/images/icons-colored-03.png',
                                      fit: BoxFit.cover)),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Vending Machine",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  CarouselShop(
                    images: _listImages,
                    height: MediaQuery.of(context).size.height * 15 / 100,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 15, top: 15),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Deals".tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  if(_listProduct.isNotEmpty)
                  _catalogView()
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: 250,
                        child: CupertinoTextField(
                          controller: _searchController,
                          placeholder: 'Shop Now'.tr,
                          onSubmitted: (value) {},
                          placeholderStyle: TextStyle(
                            color: CupertinoTheme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          prefix: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              CupertinoIcons.search,
                              size: 20,
                              color: Color.fromARGB(255, 104, 104, 104),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.shopping_cart_outlined, size: 30),
                      const Icon(CupertinoIcons.ellipsis, size: 30)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _catalogView() {
    return SizedBox(
        height: 100,
        child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _listImages.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                        height: 75,
                        width: 170,
                        color: Colors.white,
                        child: (_listProduct[index].image_url != null)
                            ? Image.network(
                                _listProduct[index].image_url!,
                                fit: BoxFit.fill,
                              )
                            : const Icon(
                                CupertinoIcons.cart,
                                size: 25,
                              ))),
              );
            }));
  }
}
