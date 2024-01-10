// ignore_for_file: must_call_super, unused_element

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/models/content/content.dart';
import 'package:tdlabs/utils/web_service.dart';

import '../../models/content.dart';
class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({Key? key}) : super(key: key);
  @override
  _DiscoveryScreenState createState() => _DiscoveryScreenState();
}
class _DiscoveryScreenState extends State<DiscoveryScreen> {
  bool _isLoading = false;
  final List<Content> _list = [];
  @override
  void initState() {
    _fetchContents();
  }
  Widget _getContentList() {
    return Column(
      children: [
        for (var content in _list) ContentAdapter(content: content),
      ],
    );
  }
  Widget _dividerNews() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        top: 5,
        right: 13,
        left: 13,
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              'Latest News'.tr,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: CupertinoColors.systemBlue,
                  fontWeight: FontWeight.w300,
                  fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-01.png"),
              fit: BoxFit.fill),
        ),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top,),
        width: double.infinity,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(35.0),
                child: Text(
                  "Article & News".tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              _getContentList()
            ],
          ),
        ),
      ),
    ));
  }

  Future<List<Content>> _fetchContents() async {
    final webService = WebService(context);
    if (!_isLoading) {
      _isLoading = true;
      webService.setEndpoint('feed/contents');
      var response = await webService.send();
      if (response!.status) {
        final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<Content> contents = parseList.map<Content>((json) => Content.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            _list.addAll(contents);
          });
        }
      }
    }
    _isLoading = false;
    return _list;
  }
}
