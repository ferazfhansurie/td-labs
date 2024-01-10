// ignore_for_file: must_call_super, unused_local_variable, unused_element

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/util/id_verify.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/button/homebutton.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../models/user/user.dart';

//need to do-language & referral
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GlobalKey globalKey = GlobalKey();
  int _userId = 0;
  String userPhone = '';
  String userName = '';
  String userEmail = '';
  String userToken = '';
  String linkEmail = '';
  int? usernameType;
  int? userLanguage;
  String userReferrence = '';
  List<dynamic> _companyList = [];
  List<dynamic> _languageList = [];
  int language = 0;
  String appVersion = MainConfig.APP_VER;
  int verificationStatus = 0;
  String userQr = "";
  final locales = [
    {
      'name': 'English',
      'locale': const Locale('en', 'US'),
    },
    {'name': 'Bahasa Malaysia', 'locale': const Locale('ms', 'MY')},
    {'name': '简体中文'.tr, 'locale': const Locale('zh', 'ZH')},
  ];
  @override
  void initState() {
    _fetchUser();
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
        userQr = "tdlabs.co?reference_no=" +
            userReferrence +
            "&phone_no=" +
            userPhone;
        /* _auth = (user.oauth_social!.isNotEmpty) ? user.oauth_social : [];
        linkEmail = (user.oauth_social!.isNotEmpty) ? _auth![0]['email'] : "";*/
      });
      fetchStatus(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-01.png"),
              fit: BoxFit.fill),
        ),
        padding: EdgeInsets.only(
         
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "Profile".tr,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              _qrCode(),
              _userInfo(),
              _inviteCode(),
              const SizedBox(height: 20),
              _navButton(),
              /* GoogleLink(
                  method: 1,
                  linked: (linkEmail == '') ? 0 : 1,
                  title: (linkEmail == '') ? "Link account" : "Linked"),*/
              _logoutButton(),
              const SafeArea(
                top: false,
                child: SizedBox(height: 10),
              ),
              Text(
                'App version '.tr + appVersion,
                style: const TextStyle(
                    fontFamily: 'Montserrat', fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  static Future<void> signOutGoogle({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      Toast.show(context, "danger", e.toString());
    }
  }

  _qrCode() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 20 / 100,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      alignment: Alignment.center,
      child: RepaintBoundary(
        key: globalKey,
        child: QrImageView(
          version: QrVersions.auto,
          data: userQr,
          gapless: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }

  _userInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            userName,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w300),
          ),
          (verificationStatus == 1)
              ? const Icon(
                  Icons.verified_user,
                  color: Colors.green,
                  size: 20,
                )
              : const Icon(
                  Icons.verified_user_outlined,
                  size: 20,
                )
        ],
      ),
    );
  }

  _userIdInfo() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "Mobile Phone: ".tr,
          style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w300),
        ),
        Text(
          userPhone,
          style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w300),
        ),
      ]),
    );
  }

  _inviteCode() {
    return Container(
      width: MediaQuery.of(context).size.width * 40 / 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Invite Code: ".tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w300),
            ),
            Text(
              userReferrence,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }

  _navButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: MediaQuery.of(context).size.height * 35 / 100,
      width: double.infinity,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.1,
          crossAxisCount: 4,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          int number = index;
          return HomeButton(
            latitude: "",
            longitude: "",
            index: index,
            image:
                'assets/images/iconss-colored-0' + number.toString() + '.png',
            image2:
                'assets/images/iconss-colored-0' + number.toString() + '.png',
            label: (index == 0)
                ? 'Update Profile'.tr
                : (index == 1)
                    ? 'Change ID'.tr
                    : (index == 2)
                        ? 'Language'.tr
                        : (index == 3)
                            ? 'Link'.tr
                            : (index == 4)
                                ? 'Order History'.tr
                                : (index == 5)
                                    ? 'Voucher'.tr
                                    : (index == 6)
                                        ? 'Referral'.tr
                                        : 'About Us'.tr,
          );
        },
      ),
    );
  }

  _logoutButton() {
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 52, 169, 176),
              Color.fromARGB(255, 49, 42, 130),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25)),
      width: 150,
      height: 36,
      child: SizedBox(
        child: CupertinoButton(
          disabledColor: CupertinoColors.inactiveGray,
          padding: EdgeInsets.zero,
          onPressed: () async {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            sharedPreferences.remove('api.access_token');
            sharedPreferences.remove('api.refresh_token');
            signOutGoogle(context: context);
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text('Logout'.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w300)),
        ),
      ),
    );
  }

  Future<void> fetchStatus(BuildContext context) async {
    var response = await IdVerify.fetch(context);
    if (response != null) {
      if(mounted) {
        setState(() {
        verificationStatus = response['status'];
      });
      }
    }
  }

  Future<void> showLocaleDialog(BuildContext context) async {
    User user = User();
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
                              context,
                              _userId,
                              userLanguage!,
                            );

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

  Future<List<dynamic>?> _fetchLanguage() async {
    final webService = WebService(context);

    webService.setMethod('GET').setEndpoint('option/list/language');
    var response = await webService.send();
    if (response == null) return null;

    if (response.status) {
      _languageList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
    }
    return _languageList;
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
