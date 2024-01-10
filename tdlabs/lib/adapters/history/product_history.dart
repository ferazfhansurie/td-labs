import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import '../../models/commerce/product_history.dart';

class ProductHistoryAdapter extends StatefulWidget {
  final ProductHistory? productHistory;
  final Color? color;

  const ProductHistoryAdapter({Key? key, this.productHistory, this.color})
      : super(key: key);

  @override
  _ProductHistoryAdapterState createState() => _ProductHistoryAdapterState();
}

class _ProductHistoryAdapterState extends State<ProductHistoryAdapter> {
  @override
  Widget build(BuildContext context) {
    Color _color =
        (widget.color != null) ? widget.color! : CupertinoColors.systemGrey6;
    List<String> getItems = [];
    String? items;
    if (widget.productHistory!.items!.isNotEmpty)
      // ignore: curly_braces_in_flow_control_structures
      for (int i = 0; i < widget.productHistory!.items!.length; i++) {
        setState(() {
          getItems.add(widget.productHistory!.items![i]['name'] +
              ' X ' +
              widget.productHistory!.items![i]['quantity'].toString());
          items = getItems.join("\n");
        });
      }

    switch (widget.productHistory!.paymentMethod) {
      case 1:
        setState(() {});
        break;
      case 2:
        setState(() {});
        break;
      default:
    }

    Widget status(String statusName, Color cardColor, Color nameColor) {
      return Flexible(
          child: Container(
        width: 80,
        padding: const EdgeInsets.only(left: 15),
        alignment: Alignment.center,
        child: Card(
          color: cardColor,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
            child: Text(
              statusName,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: nameColor,
                fontSize: 8,
              ),
            ),
          ),
        ),
      ));
    }

    String statusName = 'N/A';
    Color colorStatus = Colors.blueGrey;
    Color nameColor = Colors.black;
    switch (widget.productHistory!.statusLabel) {
      case 'Pending':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = const Color.fromARGB(255, 255, 128, 0);
          nameColor = Colors.white;
        });
        break;
      case 'Assigning Driver':
        setState(() {
          var temp = widget.productHistory!.statusLabel!.split(' ');
          statusName = temp[0];
          colorStatus = const Color.fromARGB(255, 255, 128, 0);
          nameColor = Colors.white;
        });
        break;
         case 'On Going':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.blueAccent;
          nameColor = Colors.white;
        });
        break;
      case 'Submitted':
        setState(() {
          statusName = 'Pending'.tr;
          colorStatus = Colors.blueGrey;
          nameColor = Colors.white;
        });
        break;
      case 'Paid':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.blueAccent;
          nameColor = Colors.white;
        });
        break;
      case 'Processed':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.blue;
          nameColor = Colors.white;
        });
        break;
      case 'Shipped':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.lightGreen;
          nameColor = Colors.white;
        });
        break;
      case 'Completed':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.green;
          nameColor = Colors.white;
        });
        break;
      case 'Cancelled':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.red;
          nameColor = Colors.white;
        });
        break;
      case 'Void':
        setState(() {
          statusName = widget.productHistory!.statusLabel!;
          colorStatus = Colors.black;
          nameColor = Colors.white;
        });
        break;
      default:
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 7),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Ref No. '.tr,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                  color:CupertinoTheme.of(context).primaryColor)),
                          Text(widget.productHistory!.referenceNo!,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  color:CupertinoTheme.of(context).primaryColor)),
                        ],
                      ),
                      Text(
                          DateFormat('dd/MM/yyyy')
                              .format(widget.productHistory!.createdAt!),
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontSize: 11,
                              color: CupertinoColors.secondaryLabel)),
                    ],
                  ),
                  Divider(
                      height: 1,
                      thickness: 1,
                      color: CupertinoTheme.of(context).primaryColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: widget.productHistory!.items != [],
                        replacement: Container(
                          padding: const EdgeInsets.only(top: 2),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *25 /100,
                                  child: Text('Order Item(s): '.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        color:Color.fromARGB(255, 104, 104, 104),
                                        fontWeight: FontWeight.w300,
                                      ))),
                              const Text(
                                'N/A',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 11,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(top: 20),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *20 /100,
                                  child: Text('Order Item(s): '.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        color: Color.fromARGB(255, 104, 104, 104),
                                        fontWeight: FontWeight.w300,
                                      ))),
                              Container(
                                width: MediaQuery.of(context).size.width *50 /100,
                                constraints: const BoxConstraints(),
                                child: Text(
                                  (items != null) ? items! : '',
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w300,
                                      color: CupertinoTheme.of(context).primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: status(statusName.tr, colorStatus, nameColor),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Text(
                          'Total: '.tr,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                        Text(
                          "RM" + widget.productHistory!.total!,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w300,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
