import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/custom_progress_indicator copy.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({Key? key, required this.title, required this.url})
      : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool _isLoading = true;
    String? url;

  InAppWebViewController? webView;
  double progress = 0;
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          trailing: GestureDetector(
            key: const Key("back"),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  fontWeight: FontWeight.w300),
            ),
          ),
          middle: Text(widget.title,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w300))),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44),
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
          (!_isLoading)
              ? Container()
              : Container(
                  color: CupertinoColors.quaternarySystemFill,
                  child: const CustomProgressIndicator()),
        ],
      ),
    );
  }
}
