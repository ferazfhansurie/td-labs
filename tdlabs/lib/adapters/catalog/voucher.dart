// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class VoucherAdapter extends StatefulWidget {
  bool? isCheckout = false;
  String? rate;
  String? description;
  String? endDate;
  int? quantifier;
  bool? isValid;
  String? image_url;

  VoucherAdapter(
      {Key? key,
      this.isCheckout,
      this.rate,
      this.description,
      this.endDate,
      this.quantifier,
      this.isValid,
      this.image_url})
      : super(key: key);
  @override
  _VoucherAdapterState createState() => _VoucherAdapterState();
}

class _VoucherAdapterState extends State<VoucherAdapter> {
  String rate = '';
  String endDate = '';

  @override
  void initState() {
    // implement initState
    super.initState();
    if (widget.endDate != null) {
      endDate =DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.endDate!));
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.quantifier) {
      case 0:
        rate = widget.rate!.substring(0, widget.rate!.indexOf('.')) + '%';
        break;
      case 1:
        rate = 'RM' + widget.rate!.substring(0, widget.rate!.indexOf('.'));
        break;
      case 2:
        rate = 'RM' + widget.rate!.substring(0, widget.rate!.indexOf('.'));
        break;
      default:
    }
    if (widget.isValid == true) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: (widget.image_url == null)
              ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        border: Border.all(
                          color: CupertinoColors.separator,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                child: Center(
                                  child: Text(
                                    rate,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 25,
                                      color: CupertinoTheme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                height: MediaQuery.of(context).size.height * 10 /100,
                                width: MediaQuery.of(context).size.width *20 /100,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(top: 15),
                                        alignment: Alignment.center,
                                        width:MediaQuery.of(context).size.width *50 / 100,
                                        child: Text(
                                            (widget.description != null)
                                                ? widget.description!
                                                : '',
                                            softWrap: true,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 15)),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(top: 2),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (widget.endDate != null)
                                          ? 'Valid till : ' + endDate
                                          : '',
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Visibility(
                            visible: (widget.isCheckout == true),
                            replacement: Container(),
                            child: const Icon(
                              CupertinoIcons.chevron_right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    border: Border.all(
                      color: CupertinoColors.separator,
                    ),
                  ),
                  child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,image:widget.image_url!),
                ));
    } else {
      return Container();
    }
  }
}
