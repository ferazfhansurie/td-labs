// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/commerce/catalog.dart';

// ignore: must_be_immutable
class ItemAdapter extends StatefulWidget {
  final Catalog product;
  List<Catalog>? listProduct;
  String name;
  int index;
  bool isComingSoon;
  bool? isNear;
  List<int>? orderQuantityList;
  List<Map<String, dynamic>>? orderList = [];
  List<Map<String, dynamic>>? orderNameList = [];
  bool? vmStock;
  Function()? onDelete;
  ItemAdapter({
    Key? key,
    required this.name,
    required this.product,
    this.isComingSoon = false,
    this.listProduct,
    this.isNear,
    required this.index,
    this.orderQuantityList,
    this.orderList,
    this.orderNameList,
    this.onDelete,
    this.vmStock,
  }) : super(key: key);

  @override
  _ItemAdapterState createState() => _ItemAdapterState();
}

class _ItemAdapterState extends State<ItemAdapter> {
  @override
  Widget build(BuildContext context) {
    return _item();
  }
  Widget _item() {
    return Text(
      widget.name,
      maxLines: 10,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w300,
        color: (widget.product.in_stock == 1)
            ? CupertinoTheme.of(context).primaryColor
            : Colors.red,
      ),
    );
  }
}
