// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../screens/catalog/catalog_description_screen.dart';


// ignore: must_be_immutable
class VendingMachineAdapter extends StatefulWidget {
  final VendingMachine vendingMachine;
  String? search;
  int index;
  bool isComingSoon;
  bool? isNear;
  Function()? vmTap;

  VendingMachineAdapter({
    Key? key,
    required this.vendingMachine,
    this.isComingSoon = false,
    this.isNear,
    required this.index,
    this.search,
    this.vmTap,
  }) : super(key: key);

  @override
  _VendingMachineAdapterState createState() => _VendingMachineAdapterState();
}

class _VendingMachineAdapterState extends State<VendingMachineAdapter> {
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderNameList = [];
  List<int> orderQuantityList = [];
  List<double> orderTotalList = [];
  final List<Catalog> _listProducts = [];
  @override
  void initState() {
    if (widget.vendingMachine.product_list!.isNotEmpty) {
      retrieveList();
    }

    super.initState();
  }

  void retrieveList() {
    for (int i = 0; i < widget.vendingMachine.product_list!.length; i++) {
      _fetchProducts(widget.vendingMachine.product_list![i]['id']);
    }
  }

  Future<List<Catalog>?> _fetchProducts(int id) async {
    final webService = WebService(context);
    webService.setEndpoint('catalog/catalog-products/$id');
    Map<String, String> filter = {};
  filter.addAll({'vm_id': widget.vendingMachine.vm_id.toString()});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      Catalog product = Catalog.fromJson(jsonDecode(response.body.toString()));
      if (mounted) {
        // check if widget is still mounted
        setState(() {
          _listProducts.add(product);
        });
      }
    }

    return _listProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              widget.vmTap!();
            },
            child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 220,
                          child: Text(widget.vendingMachine.vm_name.toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 104, 104, 104),
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text(widget.vendingMachine.vm_area_name.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CupertinoTheme.of(context).primaryColor,
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                widget.vendingMachine.distance.toString() +" KM",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoTheme.of(context).primaryColor,
                                )),
                            const Icon(
                              CupertinoIcons.map_pin,
                              size: 15,
                            ),
                          ],
                        ),
                        Text(widget.vendingMachine.vm_code.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            )),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                            width: 85,
                            height: 85,
                            color: CupertinoColors.secondarySystemBackground,
                            child: (widget.vendingMachine.vm_image_url! != null)
                                ? SizedBox(
                                    child: FadeInImage.memoryNetwork(
                                        fit: BoxFit.cover,
                                        placeholder: kTransparentImage,
                                        image: widget.vendingMachine.vm_image_url!))
                                : SizedBox(
                                    width: 85,
                                    height: 85,
                                    child: Image.asset('assets/images/icons-colored-05.png'),
                                  )),
                      ),
                    ),
                  ],
                )),
          ),
          if (widget.search != "" &&
              widget.vendingMachine.product_list!.isNotEmpty)
            for (var product in _listProducts)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  GestureDetector(
                    onTap: () {
                      orderList.add({
                        'product_id': product.id,
                        'quantity': '0',
                        'price': product.price,
                        'total': product.price,
                        'cart_type': 0
                      });
                      orderNameList.add({
                        'product_name': product.name,
                        'product_url': product.image_url,
                        'quantity': '0',
                      });
                      orderQuantityList.add(0);
                      orderTotalList.add(double.parse(product.price!));
                      orderList.removeWhere((element) => element['product_id'] == '');
                      orderNameList.removeWhere((element) => element['product_url'] == '');
                      orderNameList.removeWhere((element) => element['product_name'] == '');
                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                        return CatalogDescriptionScreen(
                          index: 0,
                          method: 0,
                          originalPrice: product.price,
                          orderList: orderList,
                          orderNameList: orderNameList,
                          orderQuantityList: orderQuantityList,
                          orderTotalList: orderTotalList,
                          catalog: product,
                          vendingMachine: widget.vendingMachine,
                          free: false,
                          refresh: () {
                            setState(() {
                              orderList.clear();
                              orderNameList.clear();
                              orderQuantityList.clear();
                              orderTotalList.clear();
                  
                            });
                          },
                        );
                      }));
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 150,
                                child: Text(product.name.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 104, 104, 104),
                                        fontWeight: FontWeight.w600)),
                              ),
                              Text(product.price.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      color: CupertinoTheme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                  color:CupertinoColors.secondarySystemBackground,
                                  child: (product.image_url != null)
                                      ? SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: FadeInImage.memoryNetwork(
                                              fit: BoxFit.cover,
                                              placeholder: kTransparentImage,
                                              image: product.image_url!))
                                      : SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: Image.asset('assets/images/icons-colored-05.png'),
                                        )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
        ],
      ),
    );
  }
}
