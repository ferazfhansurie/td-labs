// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Membership extends StatefulWidget {
  String? url;
  Membership({Key? key, this.url}) : super(key: key);
  @override
  _MembershipState createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  String? accessToken;
  String? url;
  InAppWebViewController? webView;
  double progress = 0;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    url = widget.url;
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
              transitionBetweenRoutes: true,
              backgroundColor: CupertinoTheme.of(context).primaryColor,
              middle: Text(
                'Membership'.tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                ),
              ),
            ),
            child: _webView()));
  }

  _webView() {
    return InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(url!)),
        onWebViewCreated: (InAppWebViewController controller) {
          webView = controller;
        },
        onLoadStart: (InAppWebViewController? controller, Uri? uri) {
          setState(() {
            url = uri.toString();
          });
        },
        onLoadStop: (InAppWebViewController? controller, Uri? uri) async {
          setState(() {
            url = uri.toString();
          });
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          setState(() {
            this.progress = progress / 100;
          });
        },
      );
  }
}
