// ignore_for_file: non_constant_identifier_names, prefer_final_fields, library_prefixes

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlabs/adapters/catalog/voucher.dart';
import 'package:tdlabs/screens/info/helpdesk.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:get/get.dart' as Get;

// ignore: must_be_immutable
class VoucherSelectProduct extends StatefulWidget {
  String? originalPrice;
  int? product_type;
  int? use_credit;
  List<dynamic>? items;
  int? vmId;
  String? shippingPrice;
  int? delivery;
  VoucherSelectProduct(
      {Key? key,
      this.originalPrice,
      this.shippingPrice,
      this.product_type,
      this.use_credit,
      this.items,
      this.delivery,
      this.vmId})
      : super(key: key);
  @override
  _VoucherSelectProductState createState() => _VoucherSelectProductState();
}

class _VoucherSelectProductState extends State<VoucherSelectProduct> {
  List<dynamic>? _voucherList;
  List<dynamic>? _voucherList2;
  Future<List<dynamic>?>? _future;
  ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _promoCode = TextEditingController();
  String filterByUser = 'true';
  int voucher_child = 0;
  int _tabIndex = 0;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _performSearch(tab: _tabIndex);
  }

  @override
  void dispose() {
    super.dispose();
    _promoCode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
    
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
              padding: EdgeInsets.only(top: 35),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                 Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                 
                                    size: 35,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text('Voucher'.tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                fontSize: 20,
              )),
                              const Spacer(),
                            Container(
              padding: const EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (context) {
                    return const HelpdeskScreen();
                  }));
                },
                child: Icon(
                  CupertinoIcons.question_circle_fill,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              )),
                            ],
                          ),
                        ),
                      ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 5 / 100,
                  color: CupertinoTheme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      'Apply Promo Code'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.white),
                    ),
                  ),
                ),
                _promoInput(),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 5 / 100,
                  margin: const EdgeInsets.only(top: 10),
                  color: CupertinoTheme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      'Choose Available Voucher'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.white),
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: RefreshIndicator(
                      onRefresh: refreshList,
                      child: Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: CupertinoColors.white,
                          child: Column(
                            children: [
                              _voucherBuilder(),
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  _promoInput() {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Form(
            key: _formKey,
            child: Flexible(
              child: CupertinoTextField(
                placeholder: 'Enter Promo Code'.tr,
                controller: _promoCode,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
          ),
          CupertinoButton(
              child: Text('Apply'.tr),
              onPressed: () {
                _submitPromoCode(context);
              }),
        ],
      ),
    );
  }

  _voucherBuilder() {
    return Flexible(
      child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if ((snapshot.data != null) && (_voucherList!.isNotEmpty)) {
              return Scrollbar(
                controller: _scrollController,
                child: ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                        (snapshot.data != null) ? _voucherList!.length : 0,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (widget.shippingPrice != "" &&
                              widget.shippingPrice != "0") {
                            _selectVoucher(context, index);
                          } else {
                            Toast.show(context, "danger","Please Select Location To Use This Voucher");
                          }
                        },
                        child: VoucherAdapter(
                          image_url: _voucherList![index]['image_url'],
                          isCheckout: true,
                          rate: _voucherList![index]['rate'],
                          description: _voucherList![index]['description'],
                          endDate: _voucherList![index]['end_date'],
                          quantifier: _voucherList![index]['quantifier'],
                          isValid: _voucherList![index]['is_valid'],
                        ),
                      );
                    }),
              );
            } else {
              if (snapshot.connectionState == ConnectionState.done) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.bottom -
                        100,
                    child: Center(
                      child: Visibility(
                        visible: (snapshot.data != null),
                        replacement: IntrinsicHeight(
                            child: ConnectionError(onRefresh: refreshList)),
                        child: Text('Empty list, pull to refresh.'.tr),
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }
          }),
    );
  }

  Future<void> refreshList() async {
    setState(() {
      _voucherList!.clear();
      _voucherList2!.clear();
    });
    // Reset list
    _isLoading = false;
    _future = _fetchVoucher();
  }

  Future<void> _performSearch({int? tab}) async {
    // Reset list
    _isLoading = false;
    if (_voucherList != null) {
      _voucherList!.clear();
    }
    if (_voucherList2 != null) {
      _voucherList2!.clear();
    }

    _future = _fetchVoucher();
  }

  Future<List<dynamic>?>? _fetchVoucher() async {
    final webService = WebService(context);
    if (!_isLoading) {
      _isLoading = true;
      webService.setMethod('GET').setEndpoint('marketing/voucher-codes');
      Map<String, String> filterUser = {};

      Map<String, String> filterShip = {};
 
      var response = await webService.send();
      print(response!.body);
      if (response == null) return null;
      if (response.status) {
        _voucherList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        if (widget.delivery == 1) {
          var response2 = await webService.setFilter(filterShip).send();
          if (response2 == null) return null;
          if (response2.status) {
            _voucherList2 = jsonDecode(response2.body.toString())
                .cast<Map<String, dynamic>>();
            _voucherList!.add(_voucherList2![0]);
          }
        }
      }
    }
    _isLoading = false;
    return _voucherList; 
  }

  Future<void> _submitPromoCode(BuildContext context) async {
    voucher_child = 0;
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('catalog/catalog-products/calculate-price');
    Map<String, String> data = {};
     data.addAll({'original_price': widget.originalPrice!});
    data.addAll({'voucher_code': _promoCode.text});
    data.addAll({'voucher_child': voucher_child.toString()});
    data.addAll({'use_credit': widget.use_credit.toString()});
    data.addAll({'items': jsonEncode(widget.items)});
    data.addAll({"vm_id": widget.vmId.toString()});
    if (widget.shippingPrice != null) {
      data.addAll({'shipping_price': widget.shippingPrice!});
    }
    if (widget.use_credit != null) {
      data.addAll({'use_credit': widget.use_credit.toString()});
    }
    var response = await webService.setData(data).send();
    print(response!.body);
    if (response == null) return;
    if (response.status) {
      Map<String, dynamic> result = jsonDecode(response.body.toString());
      result.addAll({'voucher_code': _promoCode.text});
      Navigator.of(context).pop(result);
    } else if (response.statusCode == 500) {
      Toast.show(context, 'danger', 'Server Error');
    } else {
      voucher_child = 1;
    Map<String, String> data = {};
     data.addAll({'original_price': widget.originalPrice!});
    data.addAll({'voucher_code': _promoCode.text});
    data.addAll({'voucher_child': voucher_child.toString()});
    data.addAll({'use_credit': widget.use_credit.toString()});
    data.addAll({'items': jsonEncode(widget.items)});
    data.addAll({"vm_id": widget.vmId.toString()});
    if (widget.shippingPrice != null) {
      data.addAll({'shipping_price': widget.shippingPrice!});
    }
    if (widget.use_credit != null) {
      data.addAll({'use_credit': widget.use_credit.toString()});
    }
    var response = await webService.setData(data).send();
    print(response!.body);
    if (response == null) return;
    if (response.status) {
      Map<String, dynamic> result = jsonDecode(response.body.toString());
      result.addAll({'voucher_code': _promoCode.text});
      Navigator.of(context).pop(result);
    } else if (response.statusCode == 500) {
      Toast.show(context, 'danger', 'Server Error');
    } else {
           Toast.show(context, 'danger', 'Not Found');
    }
    }
  }

  Future<void> _selectVoucher(BuildContext context, int index) async {
    final webService = WebService(context);
    voucher_child = 1;
    webService.setMethod('POST').setEndpoint('catalog/catalog-products/calculate-price');
    Map<String, String> data = {};
    data.addAll({'original_price': widget.originalPrice!});
    data.addAll({'voucher_code': _voucherList![index]['code']});
    data.addAll({'voucher_child': voucher_child.toString()});
    data.addAll({'use_credit': widget.use_credit.toString()});
    data.addAll({'items': jsonEncode(widget.items)});
    data.addAll({"vm_id": widget.vmId.toString()});
    if (widget.shippingPrice != null) {
      data.addAll({'shipping_price': widget.shippingPrice!});
    }
    if (widget.use_credit != null) {
      data.addAll({'use_credit': widget.use_credit.toString()});
    }

    var response = await webService.setData(data).send();
    print(response!.body);
    if (response == null) return;
    if (response.status) {
      Map<String, dynamic> result = jsonDecode(response.body.toString());
      result.addAll({'voucher_code': _voucherList![index]['code']});
      Navigator.of(context).pop(result);
    } else if (response.statusCode == 500) {
      Toast.show(context, 'danger', 'Server Error');
    } else {
      Toast.show(context, 'danger', 'Invalid Voucher');
    }
  }
}
