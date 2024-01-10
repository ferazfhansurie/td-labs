import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  InAppWebViewController? webView;
  double progress = 0;
  String url = "https://covidnow.moh.gov.my/";
  final urlController = TextEditingController();
  late PullToRefreshController pullToRefreshController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        key: const Key("info_screen"),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: CupertinoColors.systemFill,
          child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Background-01.png"),
                    fit: BoxFit.fill),
              ),
              padding: EdgeInsets.only(
               
              ),
              child: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    "Covid Info".tr,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Expanded(child: _webView()),
              ])),
        ),
      ),
    );
  }

  Widget _webView() {
    return InAppWebView(
      key: const Key("web_view"),
      initialUrlRequest: URLRequest(url: Uri.parse(url)),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      onLoadStart: (controller, url) {
        setState(() {
          this.url = url.toString();
          urlController.text = this.url;
        });
      },
      onLoadStop: (controller, url) async {
        pullToRefreshController.endRefreshing();
        setState(() {
          this.url = url.toString();
          urlController.text = this.url;
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
