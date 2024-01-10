// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../models/screening/opt_test.dart';

// ignore: must_be_immutable
class OptTestAdapter2 extends StatefulWidget {
  final OptTest optTest;
  List<String> image;
  int index;
  bool isComingSoon;

  OptTestAdapter2(
      {Key? key,
      required this.optTest,
      this.isComingSoon = false,
      required this.index,
      required this.image})
      : super(key: key);

  @override
  _OptTestAdapter2State createState() => _OptTestAdapter2State();
}
class _OptTestAdapter2State extends State<OptTestAdapter2> {
  @override
  Widget build(BuildContext context) {
    return _optTest2();
  }
  Widget _optTest2() {
    return Column(children: [
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: 65,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                  border: Border.all(color: Colors.blueGrey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                        widget.image[widget.index],
                        height: 80, fit: BoxFit.fitHeight),
                    Text(widget.optTest.name.toString().tr,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                  ],
                )),
          ),
        ],
      )
    ]);
  }
}
