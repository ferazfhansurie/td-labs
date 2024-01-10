import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/commerce/product_history.dart';

// ignore: must_be_immutable
class PurchaseAdapter extends StatefulWidget {
  List<ProductHistory?>? redeem;
  int? index;
  int? id;
  bool isComingSoon;

  PurchaseAdapter(
      {Key? key,
      required this.redeem,
      this.isComingSoon = false,
      this.index,
      this.id})
      : super(key: key);

  @override
  _PurchaseAdapterState createState() => _PurchaseAdapterState();
}

class _PurchaseAdapterState extends State<PurchaseAdapter> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Reference No : ".tr +
                  widget.redeem![widget.index!]!.referenceNo.toString(),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
            Text(
              "Date Purchase: ".tr +
                  widget.redeem![widget.index!]!.createdAt.toString(),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
            Text(
              "Total: ".tr + widget.redeem![widget.index!]!.amount.toString(),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
