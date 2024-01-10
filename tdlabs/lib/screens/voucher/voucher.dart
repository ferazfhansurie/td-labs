// ignore_for_file: library_prefixes, prefer_final_fields

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:get/get.dart' as Get;

import '../../adapters/catalog/voucher.dart';

class Voucher extends StatefulWidget {
  const Voucher({Key? key}) : super(key: key);

  @override
  _VoucherState createState() => _VoucherState();
}

class _VoucherState extends State<Voucher> {
  List<dynamic>? _voucherList;
  Future<List<dynamic>?>? _future;
  ScrollController _scrollController = ScrollController();
  String filterByUser = 'true';
  bool _isLoading = false;
  String? imageurl;
  @override
  void initState() {
    //  implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: RefreshIndicator(
            onRefresh: refreshList,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/Background-01.png"),
                      fit: BoxFit.fill),
                ),
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Voucher".tr,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300),
                            ),
                            const Spacer()
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 80 / 100,
                      child: _voucherBuilder(),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  _voucherBuilder() {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if ((snapshot.data != null) && (_voucherList!.isNotEmpty)) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: (snapshot.data != null) ? _voucherList!.length : 0,
                itemBuilder: (context, index) {
                  return VoucherAdapter(
                    image_url: _voucherList![index]['image_url'],
                    isCheckout: false,
                    rate: _voucherList![index]['rate'],
                    description: _voucherList![index]['description'],
                    endDate: _voucherList![index]['end_date'],
                    quantifier: _voucherList![index]['quantifier'],
                    isValid: _voucherList![index]['is_valid'],
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
                    child:  Text('Empty list, pull to refresh.'.tr),
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      },
    );
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

  Future<List<dynamic>?> _fetchVoucher() async {
    final webService = WebService(context);

    if (!_isLoading) {
      _isLoading = true;
      webService.setMethod('GET').setEndpoint('marketing/voucher-codes');
      Map<String, String> filterUser = {};
      filterUser.addAll({'user_id': filterByUser});
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
}
