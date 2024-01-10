// ignore_for_file: library_prefixes, unused_local_variable

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:get/get.dart' as Get;
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);
  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String? _inviteCode = '';
  Image? imageInvite;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Background-01.png"),
                fit: BoxFit.fill),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(
             
              bottom: MediaQuery.of(context).padding.bottom),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
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
                            size: 25,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Referral".tr,
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
                _refInfo(),
                _refImage(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      'Terms & Conditions Apply'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _refInfo() {
    return Container(
      padding: const EdgeInsets.only(
        right: 10,
        left: 10,
        top: 5,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Earn Commission'.tr,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w300),
              ),
              Text(
                'Invite your friend using your referral code and earn your rewards now'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Image.asset(
                  'assets/images/referral-01.png',
                  fit: BoxFit.cover,
                  height: 270,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _refImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 12 / 100,
      padding: const EdgeInsets.only(
        right: 10,
        left: 10,
        bottom: 5,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 49, 42, 130),
            Color.fromARGB(255, 52, 169, 176),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white),
      ),
      child: InkWell(
        onTap: () {
          shareInviteCode(_inviteCode!.toLowerCase());
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 5),
              child: Image.asset(
                'assets/images/icons-white-25.png',
                alignment: Alignment.center,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 30 / 100,
                height: 80,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Share Referral Code Now'.tr,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  _inviteCode!,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void share(String savePath) async {
    File testFile = File(savePath);
    if (!await testFile.exists()) {
      await testFile.create(recursive: true);
      testFile.writeAsStringSync("test for share documents file");
    }
  }

  Future<void> shareInviteCode(String referralId) async {
    Uri url = await createDynamicLink(referralId: referralId);
    Share.share("$url");
  }

  Future<Uri> createDynamicLink({required String referralId}) async {
    String url = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.manufacturer == "HUAWEI") {
      (MainConfig.modeLive)
          ? url = 'http://cloud.tdlabs.co/referral?id=$referralId'
          : url = 'http://dev.tdlabs.co/referral?id=$referralId';
    } else {
      (MainConfig.modeLive)
          ? url = 'http://cloud.tdlabs.co/referral?id='
          : url = 'http://dev.tdlabs.co/referral?id=';
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        // This should match firebase but without the query param
        uriPrefix: 'https://tdlabs.page.link',
        // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
        link: Uri.parse('$url$referralId'),
        androidParameters: const AndroidParameters(
          packageName: 'com.tedainternational.tdlabs',
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.tedainternational.tdlabs',
          minimumVersion: '1',
          appStoreId: '1554227226',
        ),
        socialMetaTagParameters: const SocialMetaTagParameters(
          title: 'Book A Test For Covid-19 never been easier!',
          description: 'Register an account with Tdlabs now to start.',
        ),
      );
      final link = await dynamicLinks.buildLink(parameters);
      final ShortDynamicLink shortenedLink =
          await dynamicLinks.buildShortLink(parameters);
      url = shortenedLink.shortUrl.toString();
    }

    return Uri.parse(url);
  }

  /* get User model from api */
  Future<void> _fetchUser() async {
    User? user = await User.fetchOne(context); // get current user
    if (user != null) {
      if (mounted) {
        setState(() {
          _inviteCode = user.referrerReference;
        });
      }
    }
  }
}
