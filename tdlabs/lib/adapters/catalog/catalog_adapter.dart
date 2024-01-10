import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../models/commerce/catalog.dart';
import '../../screens/catalog/catalog_description_screen.dart';

// ignore: must_be_immutable
class CatalogAdapter extends StatefulWidget {
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
  bool? free;
  Function()? refresh;
  CatalogAdapter({
    Key? key,
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
    this.vendingMachine,
    this.free,
    this.refresh,
  }) : super(key: key);
  @override
  _CatalogAdapterState createState() => _CatalogAdapterState();
}

class _CatalogAdapterState extends State<CatalogAdapter> {
  VendingMachine? _vm;
  int index = 0;
  String? overlay;
  @override
  void initState() {
    _vm = widget.vendingMachine;
    index = widget.index!;
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
      child: GestureDetector(
        onTap: () {
          if (widget.catalog!.in_stock == 0 && widget.method == 0) {
            showUnavailableVM(context);
          } else if (_vm != null || widget.method == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CatalogDescriptionScreen(
                          index: widget.index,
                          method: widget.method,
                          originalPrice: widget.originalPrice,
                          orderList: widget.orderList,
                          orderNameList: widget.orderNameList,
                          orderQuantityList: widget.orderQuantityList,
                          orderTotalList: widget.orderTotalList,
                          catalog: widget.catalog!,
                          vendingMachine: _vm,
                          free: widget.free,
                          refresh: widget.refresh,
                        ))).then((result) {
              if (result != null && result == true) {
                widget.refresh!();
               
              }
            });
          } else {
            showVM(context);
          }
        },
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                clipBehavior: Clip.none,
                fit: StackFit.loose,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    child: (widget.catalog!.image_url != null)
                        ? Center(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FadeInImage.memoryNetwork(
                                    height: MediaQuery.of(context).size.height *
                                        15 /
                                        100,
                                    width: MediaQuery.of(context).size.height *
                                        15 /
                                        100,
                                    placeholder: kTransparentImage,
                                    image: widget.catalog!.image_url!)),
                          )
                        : Image.asset(
                            'assets/images/antigen.jpg',
                            height: MediaQuery.of(context).size.height * 15 / 100,
                            width:MediaQuery.of(context).size.height * 15 / 100,
                          ),
                  ),
                  if (overlay != "")
                    Visibility(
                      visible: (overlay != ""),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Card(
                            elevation: 5,
                            color: CupertinoTheme.of(context).primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                overlay!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Colors.white),
                              ),
                            )),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.catalog!.name!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  color: CupertinoTheme.of(context).textTheme.textStyle.color),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 3),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'RM' + widget.catalog!.price!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        if (widget.vendingMachine == null &&
                            widget.catalog!.stock_quantity == 0)
                          Container(
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red)),
                            child: const Text(
                              'Out Of Stock',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        if (widget.vendingMachine != null &&
                            widget.catalog!.in_stock == 0)
                          Container(
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red)),
                            child: const Text(
                              'Out Of Stock',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
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
    // set up the AlertDialog
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
    // show the dialog
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
