// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/commerce/cart.dart';
import 'package:tdlabs/models/time_session.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/screens/catalog/cart_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/history/product_history_screen.dart';

typedef StringCallback = Function(String value);

class SearchBar4 extends StatefulWidget {
  String? value;
  final bool showScanner;
  final StringCallback onSubmitted;
  List<TimeSession>? list;
  String? name;
  int? type;
  VendingMachine? vm;
  String? latitude;
  String? longitude;
  bool? map;
  bool? isCatalog;
  Function()? showMap;
  SearchBar4(
      {Key? key,
      this.showScanner = false,
      required this.onSubmitted,
      this.list,
      this.value,
      this.name,
      this.type,
      this.vm,
      this.latitude,
      this.longitude,
      this.map,
      this.showMap,
      this.isCatalog})
      : super(key: key);

  @override
  _SearchBar4State createState() => _SearchBar4State();
}

class _SearchBar4State extends State<SearchBar4> {
  final _searchController = TextEditingController();
  int totalCart = 0;
  List<dynamic> _listCart = [];
  @override
  void initState() {
    super.initState();
    widget.latitude;
    if (widget.type != null) {
      _fetchCart();
    }

    if (widget.value != null) {
      _searchController.text = widget.value!;
    }

    _searchController.addListener(() {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: 350,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child:  Icon(
                    Icons.chevron_left,
                    size: MediaQuery.of(context).size.width *11/100,
                  )),
              Flexible(
                child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 16),
                    decoration: InputDecoration(
                        suffixIcon: Visibility(
                          visible: (_searchController.text != ""),
                          child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  widget.onSubmitted("");
                                });
                              },
                              child: Icon(
                                CupertinoIcons.clear_circled_solid,
                                color: CupertinoTheme.of(context).primaryColor,
                              )),
                        ),
                        icon: const Icon(Icons.search),
                        filled: false,
                        hintText: (widget.name == null)
                            ? 'Search'.tr
                            : (widget.name != "All".tr)
                                ? widget.name
                                : (widget.type == 0)
                                    ? "TD-Mall".tr
                                    : "TD-Vend".tr,
                        alignLabelWithHint: true,
                        hintStyle: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16),
                        border: InputBorder.none),
                    onSubmitted: widget.onSubmitted),
              ),
              Visibility(
                visible: (widget.name != null),
                replacement: (widget.map == false)
                    ? GestureDetector(
                        onTap: () {
                         widget.showMap!();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(
                            CupertinoIcons.map,
                            size: 25,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                        widget.showMap!();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(
                            CupertinoIcons.list_bullet,
                            size: 25,
                          ),
                        ),
                      ),
                child: GestureDetector(
                  onTap: () {
                    _showMore();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>?> _fetchCart() async {
    var response = await CatalogCart.fetchCart(context, widget.type!);
    if (response == null) return null;
    if (response.status) {
      _listCart =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      totalCart = _listCart.length;
    }

    return _listCart;
  }

  _showMore() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: double.infinity,
          child: Material(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Options'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  ),
                ),
                const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) {
                      return CartScreen(
                        tab: widget.type,
                        vm: (widget.vm != null) ? widget.vm! : null,
                      );
                    }));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cart'.tr,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Stack(
                          children: [
                            const Icon(
                              CupertinoIcons.cart_fill,
                              size: 30,
                            ),
                            Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration:  BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
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
                    ),
                  ),
                ),
                const Divider(),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order History'.tr,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(
                          CupertinoIcons.clock_fill,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                InkWell(
                  onTap: () {
                    _launchURL('https://tdlabs.co/privacy-policy.html');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Privacy Policy'.tr,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(
                          CupertinoIcons.lock_fill,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                InkWell(
                  onTap: () {
                    _launchURL('https://tdlabs.co/shipping_refund.html');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shipping & Refund Policy'.tr,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(
                          Icons.local_shipping,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
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
}
