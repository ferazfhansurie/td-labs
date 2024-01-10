// ignore_for_file: library_prefixes, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:get/get.dart' as Get;
import 'package:url_launcher/url_launcher.dart';

class HelpdeskScreen extends StatefulWidget {
  const HelpdeskScreen({Key? key}) : super(key: key);

  @override
  _HelpdeskScreenState createState() => _HelpdeskScreenState();
}

class _HelpdeskScreenState extends State<HelpdeskScreen> {
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
            padding: EdgeInsets.only(
             
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
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
                          "Help Desk".tr,
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
                const SizedBox(
                  height: 55,
                ),
                SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FlutterSocialButton(
                                mini: true,
                                onTap: () {
                                  _launchURL();
                                },
                              ),
                               Text(
                                "Email".tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FlutterSocialButton(
                                mini: true,
                                onTap: () {
                                  _launchWhatsapp();
                                },
                                buttonType: ButtonType.whatsapp,
                              ),
                              const Text(
                                "Whatsapp",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FlutterSocialButton(
                                buttonType: ButtonType.phone,
                                mini: true,
                                onTap: () {
                                  _launchURLTel();
                                },
                              ),
                               Text(
                                "Call".tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              FlutterSocialButton(
                                mini: true,
                                onTap: () {
                                  _launchURLFacebook();
                                },
                                buttonType: ButtonType.facebook,
                              ),
                              const Text(
                                "Facebook",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  _launchURLTel() async {
    const url = "tel:03-89992552";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURLFacebook() async {
    const url = "https://www.facebook.com/TedaWellness";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURL() async {
    const url = "mailto:customer@tdlabs.co?subject=News&body=New%20Message";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchWhatsapp() async {
    const url = 'https://wa.me/60146717681?text=Helpdesk,New%20Message';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
