// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// ignore: must_be_immutable, camel_case_types
class appWeb extends StatefulWidget {
  String? url;
  appWeb({Key? key, this.url}) : super(key: key);
  @override
  _appWebState createState() => _appWebState();
}

// ignore: camel_case_types
class _appWebState extends State<appWeb> {
  InAppWebViewController? webView;
  double progress = 0;
  String url = "";
  @override
  Widget build(BuildContext context) {
    return _innAppWebView();
  }
  Widget _innAppWebView() {
    return Column(children: <Widget>[
      Container(
          child: progress < 1.0
              ? LinearProgressIndicator(value: progress)
              : Container()),
      Expanded(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.url!)),
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
    ]);
  }
}
