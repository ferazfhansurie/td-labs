// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tdlabs/adapters/util/pdf_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HealthScreening extends StatefulWidget {
  String? url;
  HealthScreening({Key? key, this.url}) : super(key: key);
  @override
  _HealthScreeningState createState() => _HealthScreeningState();
}

class _HealthScreeningState extends State<HealthScreening> {
  String? accessToken;
  String? url;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  final Set<String> _visitedUrls = {};
  String? _pdfUrl;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    url = widget.url;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CupertinoPageScaffold(
            child: Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/Background-01.png"),
            fit: BoxFit.fill),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 30,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 60 / 100,
                    child: const Text(
                      "Health Screening",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          _webView()
        ],
      ),
    )));
  }

  _webView() {
    return Flexible(
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: url,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        navigationDelegate: (NavigationRequest request) async {
          // Handle URL opening here

          if (_pdfUrl != null && request.url == _pdfUrl) {
            // Clear the PDF URL and allow navigation
            _pdfUrl = null;
            return NavigationDecision.navigate;
          } else if (request.url.contains("file?token=") &&
              !_visitedUrls.contains(request.url)) {
            _visitedUrls.add(request.url);

            // Store the PDF URL and navigate to the PDFView
            _pdfUrl = request.url;
            var pop = await Navigator.of(context)
                .push(CupertinoPageRoute(builder: (context) {
              return PDFView(
                pdfUrl: request.url,
              );
            }));
            if (pop == true) {
              
              Future.delayed(const Duration(seconds: 1)).then((value) => {
                _visitedUrls.clear()
              });
            
            }
            // Prevent navigation in the WebView
            return NavigationDecision.prevent;
          }
          // Open the URL in the WebView
          return NavigationDecision.navigate;
        },
        onWebResourceError: (WebResourceError error) {

        },
      ),
    );
  }
}
