// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';


class WebViewFormScreen extends StatefulWidget {
  final String title;
  final String url;
  const WebViewFormScreen({Key? key, required this.title, required this.url})
      : super(key: key);
  @override
  _WebViewFormScreenState createState() => _WebViewFormScreenState();
}

class _WebViewFormScreenState extends State<WebViewFormScreen> {
  InAppWebViewController? webView;
  bool _isLoading = true;
  String url = "";
   double progress = 0;
  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          middle: Text(widget.title.tr,
                        style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w300),),
          trailing: GestureDetector(
            onTap: () {
              Navigator.pop(context, '1');
            },
            child: Text(
              'Done'.tr,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  color: CupertinoTheme.of(context).primaryColor),
            ),
          ),
        ),
        child: _webViewScreeen());
  }

  Widget _webViewScreeen() {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding:EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44),
          child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
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
        ),
        ),
        (!_isLoading)
            ? Container()
            : Container(
                color: CupertinoColors.quaternarySystemFill,
                child: const CircularProgressIndicator()),
      ],
    );
  }
}
