// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:tdlabs/models/content/content.dart';
import 'package:tdlabs/utils/web_service.dart';

import '../../models/content.dart';
class BannerScreen extends StatefulWidget {
  String title;
  BannerScreen({Key? key, required this.title}) : super(key: key);
  @override
  State<BannerScreen> createState() => _BannerScreenState();
}
class _BannerScreenState extends State<BannerScreen> {
  bool _isLoading = false;
  final List<Content> _list = [];
  @override
  void initState() {
    _fetchContents();
    super.initState();
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
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
                        widget.title.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300),
                      ),
                      const Spacer()
                    ],
                  ),
                ),
              ),
              if (_list.isNotEmpty) ContentAdapter(content: _list[0]),
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
        List<Content> contents =parseList.map<Content>((json) => Content.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            for (int i = 0; i < contents.length; i++) {
              if (contents[i].title == widget.title) {
                _list.add(contents[i]);
              }
            }
          });
        }
      }
    }
    _isLoading = false;
    return _list;
  }
}
