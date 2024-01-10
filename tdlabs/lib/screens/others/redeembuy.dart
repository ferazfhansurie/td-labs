// ignore_for_file: must_be_immutable
import 'package:tdlabs/models/commerce/package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'dart:convert';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/adapters/util/package_adapter.dart';

class RedeembuyScreen extends StatefulWidget {
  String? url;
  RedeembuyScreen({Key? key, this.url}) : super(key: key);
  @override
  _RedeembuyScreenState createState() => _RedeembuyScreenState();
}

class _RedeembuyScreenState extends State<RedeembuyScreen> {
  String? accessToken;
  String? url;
  final List<Package> _list = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchContents();
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
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/Background-01.png"),
                      fit: BoxFit.fill),
                ),
                padding: EdgeInsets.only(
                   
                    bottom: MediaQuery.of(context).padding.bottom),
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                  "Smart Consuming Package".tr,
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
                        _getContentList(),
                      ],
                    )))));
  }

  Widget _getContentList() {
    return Container(
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        child: Column(
          children: [
            Center(
              child: Image.asset('assets/images/logo.png', height: 30),
            ),
            for (var packages in _list)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: PackageAdapter(package: packages)),
          ],
        ));
  }

  Future<List<Package>> _fetchContents() async {
    final webService = WebService(context);

    if (!_isLoading) {
      _isLoading = true;
      webService.setEndpoint('plan/packages');
      Map<String, String> filter = {};
      filter.addAll({'product_type ': '3'});
      filter.addAll({'type  ': '2'});
      var response = await webService.send();
      if (response!.status) {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<Package> packages =
            parseList.map<Package>((json) => Package.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            _list.addAll(packages);
          });
        }
      }
    }
    _isLoading = false;
    return _list;
  }
}
