import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/util/redeem.dart';

// ignore: must_be_immutable
class RedeemAdapter extends StatefulWidget {
  List<Redeem?>? redeem;
  int? index;
  int? id;
  bool isComingSoon;
  Color? color;

  RedeemAdapter(
      {Key? key,
      required this.redeem,
      this.isComingSoon = false,
      this.index,
      this.color,
      this.id})
      : super(key: key);

  @override
  _RedeemAdapterState createState() => _RedeemAdapterState();
}

class _RedeemAdapterState extends State<RedeemAdapter> {
  @override
  Widget build(BuildContext context) {
    String? name = widget.redeem![widget.index!]!.package_name.toString();
    String? date = widget.redeem![widget.index!]!.redeemed_at.toString();
    String? _points = widget.redeem![widget.index!]!.reward_amount!.toString();
    var arr = _points.split('.');
    _points = arr[0];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Name: ".tr,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    name.tr,
                    style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Amount Collected: ".tr,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    _points,
                    style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Date: ".tr,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
