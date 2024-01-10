// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/util/redeem.dart';

// ignore: must_be_immutable
class Point extends StatefulWidget {
  List<Redeem?>? redeem;
  int? count;
  int? index;
  int? id;
  bool isComingSoon;
  Point(
      {Key? key,
      required this.redeem,
      this.isComingSoon = false,
      this.index,
      this.count,
      this.id})
      : super(key: key);

  @override
  _PointState createState() => _PointState();
}

class _PointState extends State<Point> {
  @override
  Widget build(BuildContext context) {
    int day = (widget.index! + 1);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (widget.index! < widget.count!)
            ? const Card(
                elevation: 5,
                child: Padding(
                  padding:EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                  child: Icon(
                    CupertinoIcons.money_dollar_circle_fill,
                    size: 34,
                    color: Color.fromARGB(255, 49, 42, 130),
                  ),
                ),
              )
            : const Card(
                elevation: 5,
                child: Padding(
                  padding:EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                  child: Icon(
                    CupertinoIcons.money_dollar_circle,
                    size: 34,
                    color: Color.fromARGB(255, 49, 42, 130),
                  ),
                ),
              ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            "Day ".tr + day.toString(),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
