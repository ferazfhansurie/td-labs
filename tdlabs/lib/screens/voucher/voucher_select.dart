// ignore_for_file: library_prefixes, non_constant_identifier_names, use_key_in_widget_constructors, prefer_final_fields

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/adapters/catalog/voucher.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import '../../models/poc/poc.dart';
import 'package:get/get.dart' as Get;

// ignore: must_be_immutable
class VoucherSelect extends StatefulWidget {
  String? originalPrice;
  Poc? poc;
  int? testType;
  int? mode;
  int? use_credit;
  VoucherSelect(
      {this.originalPrice,
      this.poc,
      this.testType,
      this.mode,
      this.use_credit});
  @override
  _VoucherSelectState createState() => _VoucherSelectState();
}

class _VoucherSelectState extends State<VoucherSelect> {
  List<dynamic>? _voucherList;
  Future<List<dynamic>?>? _future;
  ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
  final _promoCode = TextEditingController();

  String filterByUser = 'true';
  int voucher_child = 0;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void dispose() {
    super.dispose();
    _promoCode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Voucher'.tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                fontSize: 20,
              )),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 14 / 100,
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 44),
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
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: RefreshIndicator(
                  onRefresh: refreshList,
                  child: Container(
                      padding: EdgeInsets.only(
                          top: 10,
                          bottom: MediaQuery.of(context).padding.bottom + 200),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: CupertinoColors.white,
                      child: _voucherBuilder()),
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
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if ((_voucherList != null) && (_voucherList!.isNotEmpty)) {
            return Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: (_voucherList != null) ? _voucherList!.length : 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _selectVoucher(context, index);
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
        });
  }

  Future<void> refreshList() async {
    setState(() {
      _voucherList!.clear();
    });
    _performSearch();
  }

  void _performSearch() {
    // Reset list
    _isLoading = false;
    _future = _fetchVoucher();
  }

  Future<List<dynamic>?>? _fetchVoucher() async {
    final webService = WebService(context);

    if (!_isLoading) {
      _isLoading = true;
      webService.setMethod('GET').setEndpoint('marketing/voucher-codes');
      Map<String, String> filterUser = {};
      filterUser.addAll({'user_id': filterByUser});
      filterUser.addAll({'poc_id': widget.poc!.id.toString()});
      filterUser.addAll({'type': widget.testType.toString()});
      filterUser.addAll({'mode': widget.mode.toString()});

      var response = await webService.setFilter(filterUser).send();

      if (response == null) return null;
      if (response.status) {
        _voucherList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      }
    }
    _isLoading = false;
    return _voucherList;
  }

  Future<void> _submitPromoCode(BuildContext context) async {
    final webService = WebService(context);

    webService.setMethod('POST').setEndpoint('screening/tests/calculate-price');
    Map<String, String> data = {};
    data.addAll({'original_price': widget.originalPrice!});
    data.addAll({'voucher_code': _promoCode.text});
    data.addAll({'voucher_child': voucher_child.toString()});
    data.addAll({'poc_id': widget.poc!.id.toString()});
    data.addAll({'type': widget.testType.toString()});
    data.addAll({'mode': widget.mode.toString()});
    data.addAll({'use_credit': widget.use_credit.toString()});
    var response = await webService.setData(data).send();

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

  Future<void> _selectVoucher(BuildContext context, int index) async {
    final webService = WebService(context);
    voucher_child = 1;

    webService.setMethod('POST').setEndpoint('screening/tests/calculate-price');
    Map<String, String> data = {};
    data.addAll({'original_price': widget.originalPrice!});
    data.addAll({'voucher_code': _voucherList![index]['code']});
    data.addAll({'voucher_child': voucher_child.toString()});
    data.addAll({'poc_id': widget.poc!.id.toString()});
    data.addAll({'type': widget.testType.toString()});
    data.addAll({'mode': widget.mode.toString()});
    data.addAll({'use_credit': widget.use_credit.toString()});
    var response = await webService.setData(data).send();

    if (response == null) return;
    if (response.status) {
      Map<String, dynamic> result = jsonDecode(response.body.toString());
      result.addAll({'voucher_code': _voucherList![index]['code']});
      Navigator.of(context).pop(result);
    } else if (response.statusCode == 500) {
      Toast.show(context, 'danger', 'Server Error');
    } else {
      Toast.show(context, 'danger', 'Error');
    }
  }
}
