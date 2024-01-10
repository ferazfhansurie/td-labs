// ignore_for_file: library_prefixes, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../adapters/webview/inAppWebView.dart';
import 'package:get/get.dart' as Get;

class PolicyinfoScreen extends StatefulWidget {
  const PolicyinfoScreen({Key? key}) : super(key: key);
  @override
  _PolicyinfoScreenState createState() => _PolicyinfoScreenState();
}

class _PolicyinfoScreenState extends State<PolicyinfoScreen> {
  String url = 'https://tdlabs.co/web/privacy.html';
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Privacy Policy'.tr,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                )),
          ),
          child: _appWeb()),
    );
  }
  Widget _appWeb() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44),
      color: CupertinoColors.systemFill,
      child: appWeb(
        url: url,
      ),
    );
  }
}
