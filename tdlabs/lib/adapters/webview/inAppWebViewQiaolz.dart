// ignore_for_file: file_names, deprecated_member_use

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewQiaolzScreen extends StatefulWidget {
  final String title;
  final String url;
  const WebViewQiaolzScreen({Key? key, required this.title, required this.url})
      : super(key: key);
  @override
  _WebViewQiaolzScreenState createState() => _WebViewQiaolzScreenState();
}

class _WebViewQiaolzScreenState extends State<WebViewQiaolzScreen> {
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
          leading: SizedBox(
            width: 100,
            child: Row(
              children: [
                 GestureDetector(
                  onTap: () {
                    _controller?.goBack();
                  },
                  child: const Icon(
                    Icons.chevron_left,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10,),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                        color: Colors.black,
                    )),
               
              ],
            ),
          ),
          automaticallyImplyLeading: false,
          middle: Text(
            widget.title.tr,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w300),
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
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44),
          child: WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _controller = controller;
              _injectBackButtonJs();
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

  void _injectBackButtonJs() {
    String backButtonJs = """
    function goBack() {
      window.history.back();
    }
  """;

    _controller?.evaluateJavascript(backButtonJs);
  }
}
