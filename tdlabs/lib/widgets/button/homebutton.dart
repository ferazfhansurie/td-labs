// ignore_for_file: must_be_immutable, unused_field, prefer_final_fields, unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/util/redeem.dart';
import 'package:tdlabs/screens/about/about_us.dart';
import 'package:tdlabs/screens/catalog/catalog_screen.dart';
import 'package:tdlabs/screens/catalog/vm_type.dart';
import 'package:tdlabs/screens/dependant/dependency.dart';
import 'package:tdlabs/screens/history/product_history_screen.dart';
import 'package:tdlabs/screens/info/subscription.dart';
import 'package:tdlabs/screens/medical/others/medical-select.dart';
import 'package:tdlabs/screens/medical/travel/travel_select.dart';
import 'package:tdlabs/screens/others/link.dart';
import 'package:tdlabs/screens/others/more_screen.dart';
import 'package:tdlabs/screens/others/redeembuy.dart';
import 'package:tdlabs/screens/others/referral.dart';
import 'package:tdlabs/screens/user/id_change.dart';
import 'package:tdlabs/screens/user/profile_form.dart';
import 'package:tdlabs/screens/voucher/voucher.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';

import '../../models/user/user.dart';

class HomeButton extends StatefulWidget {
  HomeButton(
      {Key? key,
      this.home,
      this.index,
      this.url,
      required this.label,
      required this.image,
      required this.image2,
      required this.latitude,
      required this.longitude,
      this.redeem,
      this.points,
      this.limit,
      this.date,
      this.count,
      this.accessToken})
      : super(key: key);

  final String label;
  String image;
  String image2;
  bool? home;
  int? index;
  String? url;
  String latitude;
  String longitude;
  int? limit;
  int? count;
  String? date;
  List<Redeem?>? redeem;
  String? points;
  String? accessToken;

  @override
  _HomeButtonState createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
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
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height + 15,
      child: GestureDetector(
          key: Key("home_button" + widget.index.toString()),
          onTap: () {
            if (widget.home == true) {
              if (widget.index == 0) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return MedicalScreen(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    accessToken: widget.accessToken,
                  );
                }));
              } else if (widget.index == 1) {
                 Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return CatalogScreen();
                }));
              } else if (widget.index == 2) {
                 Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return VmTypeScreen(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                  );
                }));
              } else if (widget.index == 3) {
                                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return const MoreScreen();
                }));
              } else if (widget.index == 4) {
               
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return RedeembuyScreen(
                    url: widget.url,
                  );
                }));
              } else if (widget.index == 5) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return const TravelSelectScreen();
                }));
              } else if (widget.index == 6) {
              
                 Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return Subscription(
                    limit: widget.limit,
                    count: widget.count,
                    points: widget.points,
                    date: widget.date,
                    redeem: widget.redeem,
                    tabIndex: 0,
                    url: widget.url,
                  );
                }));
              } else if (widget.index == 7) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return const Dependency();
                }));

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
                  return  AboutUsScreen();
                }));
              } else {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return  AboutUsScreen();
                }));
              }
            }
          },
          child: Column(
            children: [
              Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 24, 112, 141)
                            .withOpacity(0.6),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Image.asset(widget.image, fit: BoxFit.contain,height: 20,)),
              Container(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontSize: 9,
                      fontWeight: FontWeight.w600),
                ),
              )
            ],
          )),
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
