// ignore_for_file: library_prefixes, prefer_final_fields, must_be_immutable, curly_braces_in_flow_control_structures, file_names

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/screens/checkout/checkout_product.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:get/get.dart' as Get;

import '../../adapters/catalog/vending_machine.dart';

class VmFreeSelectScreen2 extends StatefulWidget {
  const VmFreeSelectScreen2({
    Key? key,
  }) : super(key: key);
  @override
  _VmFreeSelectScreen2State createState() => _VmFreeSelectScreen2State();
}

class _VmFreeSelectScreen2State extends State<VmFreeSelectScreen2> {
  int? vmId;
  late Future<List<VendingMachine>?> _future;
  bool _isLoading = false;
  List<VendingMachine> _list = [];
  ScrollController? _scrollController;
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderNameList = [];
  final List<Catalog> _listProduct = [];
  @override
  void initState() {
    super.initState();
    _future = _fetchVM(context);
  }

  Future<List<VendingMachine>?> _fetchVM(
    BuildContext context,
  ) async {
    final webService = WebService(context);

    webService.setMethod('GET').setEndpoint('vm/vending-machines');
    Map<String, String> filter = {};
    filter.addAll({'event_type': "1"});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<VendingMachine> vms = parseList.map<VendingMachine>((json) => VendingMachine.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _list.addAll(vms);
        });
      }
    }

    return _list;
  }

  Future<List<Catalog>?> _fetchProducts(BuildContext context) async {
    final webService = WebService(context);
    webService.setEndpoint('catalog/catalog-products');

    Map<String, String> filter = {};
    filter.addAll({'type': '4'});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList = jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Catalog> products = parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _listProduct.addAll(products);
        });
      }
    }

    return _listProduct;
  }

  _vmBuilder() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 75 / 100,
      child: RefreshIndicator(
        onRefresh: _refreshList,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if ((snapshot.data != null)) {
              return ListView.builder(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: (snapshot.data != null) ? _list.length : 0,
                itemBuilder: (context, index) {
                  VendingMachine vm = _list[index];
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        vmId = vm.id;
                      });
                      final GlobalKey progressDialogKey = GlobalKey<State>();
                      ProgressDialog.show(context, progressDialogKey);
                      var catalog = await _fetchProducts(context);
                      ProgressDialog.hide(progressDialogKey);
                      List<Map<String, dynamic>> orderList = [];
                      List<Map<String, dynamic>> orderNameList = [];
                      orderList.add({
                        'product_id': catalog![0].id,
                        'quantity': 1,
                        'price': catalog[0].price,
                        'total': catalog[0].price,
                        'cart_type': 0
                      });
                      orderNameList.add({
                        'product_name': catalog[0].name,
                        'product_url': catalog[0].image_url,
                        'quantity': 1,
                      });
                      if (orderList.isNotEmpty && orderNameList.isNotEmpty)
                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                          return CheckoutProductScreen(
                            method: 1,
                            vendingMachine: vm,
                            vm_id: vm.id,
                            originalPrice: catalog[0].price,
                            orderList: orderList,
                            orderNameList: orderNameList,
                            from: 3,
                            free: true,
                          );
                        }));
                    },
                    child:VendingMachineAdapter(vendingMachine: vm, index: index),
                  );
                },
              );
            } else {
              if (snapshot.connectionState == ConnectionState.done) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top -44,
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
          },
        ),
      ),
    );
  }
  Future<void> _refreshList() async {
    _performSearch();
  }
  void _performSearch({String? keyword, String? stateCode}) {
    // Reset list
    _isLoading = false;
    if (keyword != null) if (stateCode != null) {
      setState(() {
        _list.clear();
      });
    }
    _future = _fetchVM(
      context,
    );
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-01.png"),
              fit: BoxFit.fill),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
         
        ),
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
                        size: 25,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Free Gift Vending Machine".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 10),
              child: Text(
                "Nearest Vending Machine \nbased on your current location".tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w300),
              ),
            ),
            (_isLoading == false)
                ? _vmBuilder()
                : SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 40 / 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(child: CircularProgressIndicator()),
                        Center(
                          child: Text(
                            'Fetching Nearest Machines'.tr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ))
          ],
        ),
      ),
    );
  }
}
