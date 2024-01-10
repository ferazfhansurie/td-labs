// ignore_for_file: must_be_immutable, prefer_final_fields, unused_field, non_constant_identifier_names, unnecessary_null_comparison, unnecessary_statements

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/commerce/product_history.dart';
import 'package:tdlabs/models/util/redeem.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/themes/app_colors.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../adapters/history/product_history copy.dart';
import '../../adapters/history/redeem_history.dart';
import '../../adapters/invoice/payment_invoice_package.dart';
import '../../adapters/invoice/payment_invoice_product.dart';
import '../../global.dart' as global;
import 'package:intl/intl.dart';
class Subscription extends StatefulWidget {
  String? points;
  String? url;
  int? tabIndex;
  int? limit;
  int? count;
  String? date;
  List<Redeem?>? redeem;
  Subscription(
      {Key? key,
      this.url,
      this.tabIndex,
      this.redeem,
      this.points,
      this.limit,
      this.date,
      this.count})
      : super(key: key);
  @override
  _SubscriptionState createState() => _SubscriptionState();
}
class _SubscriptionState extends State<Subscription> {
  String? accessToken;
  String? url;
  int? _tabIndex = 0;
  int? _tabIndex2 = 0;
  List<Redeem?>? _redeem;
  int _points = 0;
  int? limit;
  List<Redeem> _list = [];
  List<ProductHistory> list = [];
  String? last_redeem;
  String reward = '';
  int? redeem_limit;
  int? redeem_count = 0;
  bool? valid_redeem;
  String _packageName = "";
  String _amount = "0";
  bool isLoading = false;
  String _date = "";
  List<Redeem> history = [];
  WebViewController? _controller;
  User? user;
  String credit = "";
  String cash = "";
  NumberFormat myFormat =  NumberFormat("#,##0.00", "en_US");
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
    _refreshContent();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _redeem = widget.redeem;
    _date = widget.date!;
    _tabIndex = widget.tabIndex;
    url = widget.url;
    limit = widget.limit;
  }
  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _refreshContent() async {
    fetchUser();
    _checkRedeem();
    _fetchHistory();
    fetchPurchaseHistory();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CupertinoPageScaffold(
            child: RefreshIndicator(
                onRefresh: _refreshContent,
                child: Container(
                  padding: EdgeInsets.only(
                   
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/Background-01.png"),
                        fit: BoxFit.fill),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                (_tabIndex == 0)
                                    ? "Daily Rewards".tr
                                    : "My Wallet".tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer()
                            ],
                          ),
                        ),
                      ),
                      (_tabIndex == 0) ? _redeemView() : _historyView(),
                    ],
                  ),
                ))));
  }

  _historyView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            elevation: 5,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Color.fromARGB(255, 52, 169, 176),
                          Color.fromARGB(255, 49, 42, 130),
                        ],
                        begin: Alignment.center,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  "Wallet",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: CupertinoTheme.of(context)
                                        .primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Image.asset(
                                  "assets/images/icons-colored-03.png",
                                  height: 45,
                                )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'RM ',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: CupertinoTheme.of(context).primaryColor,
                                        fontSize: 12),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: cash,
                                        style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 104, 104, 104),
                                            fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(2),
                                alignment: Alignment.topRight,
                                child: RichText(
                                  maxLines: 1,
                                  text: TextSpan(
                                    text: credit,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 15),
                                    children: const <TextSpan>[
                                      TextSpan(
                                        text: ' TDC',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            thickness: 2,
                          ),
                          Container(
                            padding:const EdgeInsets.only(top: 1, left: 5, bottom: 1),
                            alignment: Alignment.topLeft,
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: "RM 1",
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 104, 104, 104),
                                        fontSize: 14),
                                    children: <TextSpan>[
                                      const TextSpan(
                                        text: (" = "),
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w300,
                                            color: Color.fromARGB(255, 104, 104, 104),
                                            fontSize: 14),
                                      ),
                                      TextSpan(
                                        text: ("10,000 TDC"),
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w300,
                                            color: CupertinoTheme.of(context).primaryColor,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            height: 40,
            width: MediaQuery.of(context).size.width,
            child: _tabBarHistory(),
          ),
        ),
        (_tabIndex2 == 0)
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Reward History'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            String fullAddress = "";
                            String phoneNo = '';
                            return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                    return PaymentInvoicePackage(
                                      redeem: history[index],
                                      user: user,
                                      fullAddress: fullAddress,
                                      phoneNo: phoneNo,
                                    );
                                  }));
                                },
                                child: RedeemAdapter(
                                  index: index,
                                  redeem: history,
                                  color: (index % 2 == 0)
                                      ? AppColors.oddFill
                                      : AppColors.evenFill,
                                ));
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Purchase History'.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            ProductHistory productHistory = list[index];
                            bool continuePayment = false;
                            String fullAddress = "";
                            String phoneNo = '';
                            return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                    return PaymentInvoiceProduct(
                                      productHistory: productHistory,
                                      user: user,
                                      continuePayment: continuePayment,
                                      fullAddress: fullAddress,
                                      phoneNo: phoneNo,
                                    );
                                  }));
                                },
                                child: ProductHistoryAdapter2(
                                  productHistory: productHistory,
                                  color: (index % 2 == 0)
                                      ? AppColors.oddFill
                                      : AppColors.evenFill,
                                ));
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              )
      ],
    );
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
      return address['address_1'] +' ' +address['address_2'] +',' +address['postcode'] +',' +address['city'] +',' +stateName;
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

  Future<void> fetchUser() async {
    User? userdata = await User.fetchOne(context);
    setState(() {
      user = userdata;
      var convert = double.parse(user!.credit_cash!);
      cash = myFormat.format(convert);
      var convert2 = double.parse(user!.credit!);
      credit = myFormat.format(convert2);
    });
  }

  _redeemView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 166,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  "Reward Available Today".tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    reward + " (TDC) ",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: (_redeem![0]!.package_id == null) ? 65 : 175,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
                boxShadow: [
                  BoxShadow(
                    color:const Color.fromARGB(255, 49, 42, 130).withOpacity(0.6),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: (_redeem![0]!.package_id == null)
                  ? Center(
                      child: Text(
                        "Subscribe to our packages to gain rewards".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 104, 104, 104),
                          fontSize: 15,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (valid_redeem != true)
                                ? const Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                                      child: Icon(
                                        CupertinoIcons.money_dollar_circle_fill,
                                        size: 46,
                                        color: Color.fromARGB(255, 49, 42, 130),
                                      ),
                                    ),
                                  )
                                : const Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                                      child: Icon(
                                        CupertinoIcons.money_dollar_circle,
                                        size: 46,
                                        color: Color.fromARGB(255, 49, 42, 130),
                                      ),
                                    ),
                                  ),
                            Text(
                              "Collected: " + redeem_count.toString(),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: (valid_redeem == true),
                          replacement: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Come back tomorrow for more".tr,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color:CupertinoTheme.of(context).primaryColor,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (valid_redeem!) {
                                setState(() {
                                  isLoading = true;
                                });
                                if (isLoading == true) {
                                  _onLoading();
                                }
                                _claimRewards();
                              } else {
                                Toast.show(context, 'danger','Come back tomorrow for more'.tr);
                              }
                            },
                            child: Card(
                              color: CupertinoTheme.of(context).primaryColor,
                              elevation: 5,
                              child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    "Tap to redeem now!".tr,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 40 / 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(child: CircularProgressIndicator()),
                    Center(
                      child: Text(
                        'Loading'.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )));
      },
    );
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); //pop dialog
    });
  }

  Widget _tabBarHistory() {
    return CupertinoSlidingSegmentedControl(
      backgroundColor: Colors.white,
      thumbColor: CupertinoTheme.of(context).primaryColor,
      // borderColor: Colors.white24,
      children: {
        0: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Rewards'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: (_tabIndex2 == 0)
                    ? Colors.white
                    : const Color.fromARGB(255, 104, 104, 104)),
          ),
        ),
        1: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Purchases'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: (_tabIndex2 == 1)
                    ? Colors.white
                    : const Color.fromARGB(255, 104, 104, 104)),
          ),
        ),
      },
      groupValue: _tabIndex2,
      onValueChanged: (value) {
        setState(() {
          _tabIndex2 = value as int;
        });
      },
    );
  }

  Future<List?> _checkRedeem() async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('plan/rewards/get-package');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      _redeem = parseList.map<Redeem>((json) => Redeem.fromJson(json)).toList();
      setState(() {
        valid_redeem = _redeem![0]!.is_valid;
        var convert = double.parse((_redeem![0]!.reward_amount != null && valid_redeem == true)
                ? _redeem![0]!.reward_amount!
                : "0");
        reward = myFormat.format(convert);
        redeem_limit = (_redeem![0]!.redeem_limit != null)
            ? _redeem![0]!.redeem_limit!
            : 0;
        redeem_count = (_redeem![0]!.redeem_count != null)
            ? _redeem![0]!.redeem_count!
            : 0;
        _date = (_redeem![0]!.redeem_at != null) ? _redeem![0]!.redeem_at! : "";
      });
    }
    return _redeem;
  }

  Future<List<ProductHistory>> fetchPurchaseHistory() async {
    List<String> errors = [];
    var response = await ProductHistory.fetchRedeemHistory(context);
    if (response != null) {
      if (response.status) {
        var array =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<ProductHistory> productHistory = array.map<ProductHistory>((json) => ProductHistory.fromJson(json)).toList();
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

  Future<List?> _fetchHistory() async {
    history.clear();
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('plan/redeem-histories');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Redeem> redeem = parseList.map<Redeem>((json) => Redeem.fromJson(json)).toList();
      setState(() {
        history.addAll(redeem);
      });
    }
    return history;
  }

  Future _claimRewards() async {
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('plan/rewards/redeem');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      setState(() {
        _redeem![0]!.is_valid! == false;
        _redeem![0]!.redeem_count! + 1;
      });
      global.updateSubScreen = true;
      global.updateHomeScreen = true;
      _refreshContent();
      isLoading = false;
      if (isLoading == false) {
        Toast.show(context, 'success', 'Reward Claimed');
      }
    }
  }
}
