// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({Key? key, required this.title, required this.url})
      : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
                                  fontWeight: FontWeight.w300
                                ),),
          trailing: GestureDetector(
            onTap: () {
              Navigator.pop(context, '1');
            },
            child: Text(
              (widget.title != "Lalamove Tracking")?'Cancel'.tr:"Back".tr,
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
          child: WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onPageFinished: (finish) async {
              setState(() {
                _isLoading = false;
              });
              String html = await _controller!.runJavascriptReturningResult(
                  "document.getElementById('payment_status').innerHTML;");
              if (html != 'null') {
                // ignore: unnecessary_string_escapes
                String returnStatus = html.replaceAll('\"', '');
                Navigator.pop(context, returnStatus);
                return;
              }
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
