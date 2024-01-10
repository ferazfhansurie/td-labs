// ignore_for_file: use_key_in_widget_constructors, curly_braces_in_flow_control_structures, must_be_immutable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/commerce/product_history.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/themes/app_colors.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/widgets/connection_error.dart';

import '../../adapters/history/product_history.dart';
import '../../adapters/invoice/payment_invoice_product.dart';

class OrderHistoryScreen extends StatefulWidget {
  bool? isVending;
  bool? free;
  OrderHistoryScreen({this.isVending, this.free});
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Future<List<ProductHistory>?>? future;
  List<ProductHistory> list = [];
  ScrollController scrollController = ScrollController();
  User? user;
  String? stateName;
  Map<String, String> stateList = {
    'all': '',
    'my-01': 'Johor',
    'my-02': 'Kedah',
    'my-03': 'Kelantan',
    'my-04': 'Melaka',
    'my-05': 'Negeri Sembilan',
    'my-06': 'Pahang',
    'my-07': 'Pulau Pinang',
    'my-08': 'Perak',
    'my-09': 'Perlis',
    'my-10': 'Selangor',
    'my-11': 'Terengganu',
    'my-12': 'Sabah',
    'my-13': 'Sarawak',
    'my-14': 'Kuala Lumpur',
    'my-15': 'Labuan',
    'my-16': 'Putrajaya',
  };

  @override
  void initState() {
    //implement initState
    super.initState();
    performSearch();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Background-01.png"),
                fit: BoxFit.fill),
          ),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: RefreshIndicator(
            onRefresh: performSearch,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 100.0),
                          child: Text(
                            "Order History".tr,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _productHistoryBuilder(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _productHistoryBuilder() {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if ((snapshot.data != null) && (list.isNotEmpty)) {
            return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                controller: scrollController,
                itemCount: (snapshot.data != null) ? list.length : 0,
                itemBuilder: (context, index) {
                  ProductHistory productHistory = list[index];
                  bool continuePayment = checkContinuePayment(productHistory);
                  Map<String, dynamic> address = fetchAddress(productHistory);
                  String fullAddress = (address['address_1'] != null)
                      ? fetchFullAddress(address)
                      : "";
                  String phoneNo = '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return PaymentInvoiceProduct(
                          productHistory: productHistory,
                          user: user,
                          continuePayment: continuePayment,
                          fullAddress: fullAddress,
                          phoneNo: phoneNo,
                        );
                      }));
                    },
                    child: ProductHistoryAdapter(
                      productHistory: productHistory,
                      color: (index % 2 == 0)
                          ? AppColors.oddFill
                          : AppColors.evenFill,
                    ),
                  );
                });
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              return RefreshIndicator(
                onRefresh: performSearch,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.bottom -
                        100,
                    child: Center(
                      child: Visibility(
                        visible: (snapshot.data != null),
                        replacement: IntrinsicHeight(
                            child: ConnectionError(onRefresh: performSearch)),
                        child: Text('Empty list, pull to refresh.'.tr),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.only(top: 10),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }
        });
  }



  String? fetchItems(ProductHistory productHistory) {
    List<String> getItems = [];
    String? items;
    if (productHistory.items!.isNotEmpty)
      for (int i = 0; i < productHistory.items!.length; i++) {
        getItems.add(productHistory.items![i]['name'] +
            ' X ' +
            productHistory.items![i]['quantity'].toString());
        items = getItems.join("\n");
      }

    return items;
  }

  Map<String, dynamic> fetchAddress(ProductHistory productHistory) {
    Map<String, dynamic> address = {};
    if (productHistory.orderAddress != null) {
      address.addAll({'address_1': productHistory.orderAddress!.address_1});
      address.addAll({'address_2': productHistory.orderAddress!.address_2});
      address.addAll({'postcode': productHistory.orderAddress!.postcode});
      address.addAll({'city': productHistory.orderAddress!.city});
      address.addAll({'state': productHistory.orderAddress!.stateCode});
    }

    return address;
  }

  String fetchFullAddress(Map<String, dynamic> address) {
    String stateName = (stateList[address['state']] != null)
        ? stateList[address['state']]!
        : "";
    if (address.isNotEmpty) {
      return address['address_1'] +
          ' ' +
          address['address_1'] +
          ',' +
          address['postcode'] +
          ',' +
          address['city'] +
          ',' +
          stateName;
    }

    return '';
  }

  bool checkContinuePayment(ProductHistory productHistory) {
    if (productHistory.statusLabel == 'Submitted' &&
        productHistory.paymentMethod == 2) {
      return true;
    }
    return false;
  }

  void fetchUser() async {
    User? userdata = await User.fetchOne(context);
    setState(() {
      user = userdata;
    });
 
  }

  Future<void> performSearch() async {
    list.clear();
    future = fetchHistory();
  }

  Future<List<ProductHistory>> fetchHistory() async {
    List<String> errors = [];
    var response = await ProductHistory.fetchHistory(context);
    if (response != null) {
      if (response.status) {
        var array =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<ProductHistory> productHistory = array
            .map<ProductHistory>((json) => ProductHistory.fromJson(json))
            .toList();
        setState(() {
          list.addAll(productHistory);
        });
      }
    } else if (response!.error.isNotEmpty) {
      errors.add(response.error.values.toList()[0]);
    } else {
      errors.add('Server connection timeout.');
    }
    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
    return list;
  }
}
