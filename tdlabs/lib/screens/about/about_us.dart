// ignore_for_file: library_prefixes, deprecated_member_use

import 'package:email_launcher/email_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' as Get;
import 'package:tdlabs/screens/about/about_us_info.dart';
import 'package:tdlabs/screens/info/policy.dart';
import 'package:tdlabs/screens/info/refund_policy_info.dart';

import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  Email email = Email(
      to: ['customer@tdlabs.co'],
      cc: [''],
      bcc: [''],
      subject: 'Help regarding tdlabs apps',
      body: 'Hello,');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 25,
              color: Colors.white,
            ),
          ),
          backgroundColor: CupertinoTheme.of(context).primaryColor,
          middle: Text(
            'About Us'.tr,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 20,
            ),
          ),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: CupertinoColors.white,
          child: Column(
            children: [
              _aboutUs(),
              const Divider(color: CupertinoColors.separator, height: 1),
             _policyButton() ,
              const Divider(color: CupertinoColors.separator, height: 1),
              _contact(),
              const Divider(color: CupertinoColors.separator, height: 1),
            ],
          ),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _aboutUs() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return const AboutUsinfoScreen();
        }));
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              child: Text(
                'About Us'.tr,
                style: const TextStyle(
                  color: Color.fromARGB(255, 104, 104, 104),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

 _policyButton() {
    return Container(
      color: CupertinoColors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return const PolicyinfoScreen();
        }));
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: CupertinoColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                    child: Text(
                      'Privacy Policy'.tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
          const Divider(color: CupertinoColors.separator, height: 1),
          GestureDetector(
            onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return const RefundPolicyinfoScreen();
        }));
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: CupertinoColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                    child: Text(
                      'Shipping & Refund Policy'.tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
      
        ],
      ),
    );
  }
  Widget _contact() {
    return GestureDetector(
      onTap: () {
        _launchURL("mailto:customer@tdlabs.co?subject=News&body=New%20plugin");
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              child: Text(
                'Contact Us'.tr,
                style: const TextStyle(
                  color: Color.fromARGB(255, 104, 104, 104),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const Icon(CupertinoIcons.mail, size: 20),
          ],
        ),
      ),
    );
  }
}
