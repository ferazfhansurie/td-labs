// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/commerce/cart.dart';
import 'package:tdlabs/models/time_session.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';

typedef StringCallback = Function(String value);

class SearchBar5 extends StatefulWidget {
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
  SearchBar5(
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
  _SearchBar5State createState() => _SearchBar5State();
}

class _SearchBar5State extends State<SearchBar5> {
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
                  child: const Icon(
                    Icons.chevron_left,
                    size: 40,
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



}
