import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/main.dart';
import '../../models/poc/poc.dart';


class PocAdapter extends StatefulWidget {
  final Poc? poc;
  final Color? color;
  final bool? active;
  final bool? ebook;
  const PocAdapter({Key? key, this.poc, this.color, this.active, this.ebook})
      : super(key: key);

  @override
  _PocAdapterState createState() => _PocAdapterState();
}

class _PocAdapterState extends State<PocAdapter> {
  final NumberFormat _formatter = NumberFormat(',##0.00');
  Color? reportColor;
  Color? nameColor;
  Widget? reportWidget;
  @override
  Widget build(BuildContext context) {
    Color? _color =(widget.color != null) ? widget.color : CupertinoColors.systemGrey6;
    bool? _active = (widget.active != null) ? widget.active : false;
    double price =(widget.poc!.price != null) ? double.parse(widget.poc!.price!) : 0;
    bool ebook = widget.ebook!;
    switch (widget.poc!.reportType) {
      case 1:
        reportColor = CupertinoColors.activeBlue;
        nameColor = Colors.white;
        break;
      case 2:
        reportColor = Colors.deepOrange;
        nameColor = Colors.white;
        break;
      default:
    }

    reportWidget = Container(
      alignment: Alignment.centerRight,
      child: Card(
        color: reportColor,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
          child: Text(
            widget.poc!.reportName!,
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: nameColor),
          ),
        ),
      ),
    );
    return Container(
        width: MediaQuery.of(context).size.width,
        color: _color,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(widget.poc!.name!,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w300)),
                          ),
                          Visibility(
                            visible: _active!,
                            child: const Icon(CupertinoIcons.checkmark_alt,
                                size: 20),
                          ),
                        ],
                      ),
                      if (ebook == false) Align(child: reportWidget!),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(widget.poc!.address!,
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                                color: Colors.grey[700])),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: (widget.poc!.reportType == 2)
                            ? Text(
                                MainConfig.CURRENCY + _formatter.format(price),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w300,
                                ))
                            : const Text(''),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
          ],
        ));
  }
}
