// ignore_for_file: file_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../models/commerce/catalog.dart';
import '../../screens/catalog/catalog_description_screen.dart';

// ignore: must_be_immutable
class CatalogAdapter2 extends StatefulWidget {
  int? index;
  Catalog? catalog;
  Widget? orderCounter;
  bool? isListView;
  int? method;
  String? originalPrice;
  String? overlay;
  List<Map<String, dynamic>>? orderList;
  List<int>? orderQuantityList;
  List<Map<String, dynamic>>? orderNameList;
  List<double>? orderTotalList;
  VendingMachine? vendingMachine;
  CatalogAdapter2(
      {Key? key,
      this.index,
      this.catalog,
      this.orderCounter,
      this.isListView = true,
      this.originalPrice,
      this.overlay,
      this.orderList,
      this.orderNameList,
      this.orderQuantityList,
      this.orderTotalList,
      this.method,
      this.vendingMachine})
      : super(key: key);
  @override
  _CatalogAdapter2State createState() => _CatalogAdapter2State();
}

class _CatalogAdapter2State extends State<CatalogAdapter2> {
  VendingMachine? _vm;
  int index = 0;
  String? overlay;
  @override
  void initState() {
    _vm = widget.vendingMachine;
    index = widget.index! + 1;
    overlay = (widget.catalog!.overlay_name != null)
        ? widget.catalog!.overlay_name
        : "";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return _animatedSwitcher();
  }
  Widget _animatedSwitcher() {
    return GestureDetector(
      onTap: () {},
      child: AnimatedSwitcher(
        transitionBuilder: __transitionBuilder,
        duration: const Duration(milliseconds: 600),
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeInBack.flipped,
        child: (widget.catalog!.isDescHide!) ? _buildFront() : _buildRear(),
      ),
    );
  }
  Widget _buildFront() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: GestureDetector(
          onTap: () {
            if (widget.catalog!.in_stock == 0 && widget.method == 0) {
              showUnavailableVM(context);
            } else if (_vm != null || widget.method == 1) {
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return CatalogDescriptionScreen(
                  index: widget.index,
                  method: widget.method,
                  originalPrice: widget.originalPrice,
                  orderList: widget.orderList,
                  orderNameList: widget.orderNameList,
                  orderQuantityList: widget.orderQuantityList,
                  orderTotalList: widget.orderTotalList,
                  catalog: widget.catalog!,
                  vendingMachine: _vm,
                );
              }));
            } else {
              showVM(context);
            }
          },
          child: Column(
            children: [
              Container(
                height: 30,
                alignment: Alignment.topLeft,
                child: Card(
                    elevation: 5,
                    color: CupertinoTheme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        '00' + index.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                            color: Colors.white),
                      ),
                    )),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 1),
                child: (widget.catalog!.image_url != null)
                    ? FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image:widget.catalog!.image_url!,
                        height: 80,
                        width: 80,
                      )
                    : Image.asset(
                        'assets/images/antigen.jpg',
                        height: 80,
                        width: 80,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(1),
                child: Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.catalog!.name!,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 8,
                          color: CupertinoTheme.of(context).textTheme.textStyle.color),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(1),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RM' + widget.catalog!.price!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                        color: CupertinoTheme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showUnavailableVM(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      child: Text(
        'Back'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Item not avaialble in this machine \nPlease try another".tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      actions: [
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }

  showVM(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      child: Text(
        'Back'.tr,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(
        "Please pick a vending machine".tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      actions: [
        cancelButton,
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }

  Widget _buildRear() {
    return Container(
      key: const ValueKey(false),
      child: Card(
        elevation: 2,
        color: CupertinoTheme.of(context).primaryColor,
        child: IntrinsicHeight(
          child: Container(
            height: 280,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Column(
              children: [
                Text(
                  'Description'.tr,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Divider(
                  thickness: 2,
                ),
                Text(widget.catalog!.description!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget __transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final value = min(rotateAnim.value, pi / 2);
        return Transform(
          transform: Matrix4.rotationY(value),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }
}
