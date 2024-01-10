// ignore_for_file: must_be_immutable, unused_field, prefer_final_fields, unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/commerce/catalog.dart';
import 'package:tdlabs/models/health/period.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/screens/about/about_us.dart';
import 'package:tdlabs/screens/history/history_screen.dart';
import 'package:tdlabs/screens/history/product_history_screen.dart';
import 'package:tdlabs/screens/medical/directory/directorycategory.dart';
import 'package:tdlabs/screens/medical/period/period_cycle.dart';
import 'package:tdlabs/screens/others/link.dart';
import 'package:tdlabs/screens/others/referral.dart';
import 'package:tdlabs/screens/wellness/wellness_commercial.dart';
import 'package:tdlabs/screens/wellness/wellness_type.dart';
import 'package:tdlabs/screens/user/id_change.dart';
import 'package:tdlabs/screens/user/profile_form.dart';
import 'package:tdlabs/screens/voucher/voucher.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import '../../screens/medical/ebook/ebook_poc.dart';
import '../../screens/medical/others/health_screening.dart';
import '../../screens/medical/others/medical_ledger.dart';
import '../../screens/medical/period/period_steps.dart';
import '../../screens/medical/screening/screening.dart';
import '../../screens/medical/screening/steps.dart';
import '../../screens/medical/screening/test_select_screen.dart';

class MedicalButton extends StatefulWidget {
  MedicalButton({
    Key? key,
    this.home,
    this.index,
    this.url,
    required this.label,
    required this.image,
    required this.image2,
    this.enabledButton,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  final String label;
  String image;
  String image2;
  bool? home;
  int? index;
  String? url;
  bool? enabledButton;
  String? latitude;
  String? longitude;
  @override
  _MedicalButtonState createState() => _MedicalButtonState();
}

class _MedicalButtonState extends State<MedicalButton> {
  GlobalKey globalKey = GlobalKey();
  int _userId = 0;
  String userPhone = '';
  String userName = '';
  String userEmail = '';
  int? usernameType;
  int? userLanguage;
  String userReferrence = '';
  List<dynamic> _companyList = [];
  List<dynamic> _languageList = [];
   List<dynamic> _voucherList = [];
  int language = 0;
  String appVersion = MainConfig.APP_VER;
  final locales = [
    {
      'name': 'English',
      'locale': const Locale('en', 'US'),
    },
    {'name': 'Bahasa Malaysia', 'locale': const Locale('ms', 'MY')},
    {'name': '简体中文'.tr, 'locale': const Locale('zh', 'ZH')},
  ];
  Future<void> _fetchUM() async {
    ProgressDialog.show(context, progressDialogKey);
    var um = await UserMenstrual.fetch(context);
    if (um == null) {
      ProgressDialog.hide(progressDialogKey);
      setState(() {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return PeriodSteps();
        }));
      });
    } else {
      ProgressDialog.hide(progressDialogKey);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return CycleAnalysis(
          um: um,
        );
      }));
    }
  }
  Future<void> _fetchVoucher(List<Map<String, dynamic>> orderList,
      List<Map<String, dynamic>> orderNameList, List<Catalog> products) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('catalog/voucher-codes');
    var response = await webService.send();
 
    if (response!.status) {
      _voucherList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return WellnessCommersialScreen(
          orderList: orderList,
          orderNameList: orderNameList,
          product: products[0],
          voucherList: _voucherList,
        );
      }));
    } else {
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return WellnessCommersialScreen(
          orderList: orderList,
          orderNameList: orderNameList,
          product: products[0],
        );
      }));
    }
  }
  final GlobalKey progressDialogKey = GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: GestureDetector(
          onTapCancel: () {},
          onTap: () async {
            if (widget.home == true) {
              if (widget.index == 0) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return DirectoryCategoryScreen(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                  );
                }));
              } else if (widget.index == 1) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return const EBookSelectScreen();
                }));
              } else if (widget.index == 2) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return HealthScreening(
                    url: widget.url,
                  );
                }));
              } else if (widget.index == 3) {
                await _fetchUM();
              } else if (widget.index == 4) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return const EbookPocScreen();
                }));
              } else if (widget.index == 5) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return  HistoryScreen(tabIndex: 1,tab: true,);
                }));
              } else if (widget.index == 6) {
                  _fetchProducts(context);
              } else if (widget.index == 7) {
                _fetchProducts(context);
              }
            } else {
              _fetchUser();
              if (widget.index == 0) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return const ProfileFormScreen();
                }));
              } else if (widget.index == 1) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return IDChangeScreen(
                    phoneNo: userPhone,
                    email: userEmail,
                    usernameType: usernameType,
                  );
                }));
              } else if (widget.index == 2) {
                showLocaleDialog(context);
              } else if (widget.index == 3) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return const LinkScreen();
                })).then((value) {
                  if (value == true) {
                    _fetchCompanyInvites();
                  }
                });
              } else if (widget.index == 4) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return OrderHistoryScreen();
                }));
              } else if (widget.index == 5) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return const Voucher();
                }));
              } else if (widget.index == 6) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return const ReferralScreen();
                }));
              } else if (widget.index == 7) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return AboutUsScreen();
                }));
              } else {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return AboutUsScreen();
                }));
              }
            }
          },
          child: Column(
            children: [
              Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 48, 186, 168),
                        Color.fromARGB(255, 49, 42, 130),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: (widget.index != 6)?(widget.enabledButton == false)
                      ? Image.asset(widget.image, fit: BoxFit.fill)
                      : Image.asset(widget.image2, fit: BoxFit.fill):Icon(Icons.qr_code_rounded,
                      color: Colors.white,
                                              size: 40),),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              )
            ],
          )),
    );
  }

  Future<void> _fetchProducts(BuildContext context) async {
    final webService = WebService(context);
    final GlobalKey progressDialogKey = GlobalKey<State>();
    webService.setEndpoint('catalog/catalog-products');
    Map<String, String> filter = {};
    filter.addAll({'type': '5'});
    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.setFilter(filter).send();
    print(response!.body);
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Catalog> products =
          parseList.map<Catalog>((json) => Catalog.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          List<Map<String, dynamic>> orderList = [];
          List<Map<String, dynamic>> orderNameList = [];
          orderList.add({
            'product_id': products[0].id,
            'quantity': 1,
            'price': products[0].price,
            'total': 1,
            'cart_type': 0
          });
          orderNameList.add({
            'product_name': products[0].name,
            'product_url': products[0].image_url,
            'quantity': 1,
          });
          ProgressDialog.hide(progressDialogKey);
          _fetchVoucher(orderList, orderNameList, products);
         });
      }
    }
  }

  showPickValidationType(BuildContext context) {
    // set up the AlertDialog
    Widget alert = Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              'Choose Your Validation'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return TestSelectScreen(
                          validationType: 0,
                        );
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'General Validation(Free)'.tr,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return Steps();
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Professional Validation(Fees Apply)'.tr,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //continueButton,
                    ],
                  )
                ],
              ),
            ),
            actions: const [
              //cancelButton,
              //continueButton,
            ],
          ),
        ],
      ),
    );
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> showLocaleDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                'Choose your language'.tr,
                style: const TextStyle(
                  color: Color.fromARGB(255, 104, 104, 104),
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Montserrat',
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) => GestureDetector(
                          onTap: () async {
                            setState(() {
                              userLanguage = index;
                            });
                            var response = await User.updateLanguage(
                                context, _userId, userLanguage!);
                            if (response != null) {
                              if (response.status) {
                                Toast.show(
                                    context, 'success', 'Record updated.');
                              } else if (response.error.isNotEmpty) {
                                Toast.show(context, 'danger', 'Fail');
                              }
                              updateLocale(
                                  locales[index]['locale'] as Locale, context);
                            }
                          },
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                locales[index]['name'].toString(),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 104, 104, 104),
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Montserrat',
                                ),
                              )),
                        ),
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: 3),
              ),
            ));
  }

  void updateLocale(Locale locale, BuildContext context) {
    Get.updateLocale(locale);
    Navigator.pop(context);
  }

  Future<void> _fetchUser() async {
    User? user = await User.fetchOne(context); // get current user
    if (user != null) {
      setState(() {
        _userId = user.id!;
        userName = (user.name != null) ? user.name! : '';
        userPhone = (user.phoneNo != null) ? user.phoneNo! : '';
        userReferrence =
            (user.referrerReference != null) ? user.referrerReference! : '';
        userEmail = (user.email != null) ? user.email! : '';
        usernameType = user.usernameType;
        userLanguage = (user.language != null) ? user.language! : 0;
      });
    }
  }

  Future<List<dynamic>?> _fetchCompanyInvites() async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('company/invites');
    Map<String, String> filterStatus = {};
    filterStatus.addAll({'status': '0'});
    var response = await webService.setFilter(filterStatus).send();
    if (response == null) return null;
    if (response.status) {
      _companyList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
    }
    return _companyList;
  }
}
