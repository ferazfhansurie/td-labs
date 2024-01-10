// ignore_for_file: library_prefixes, prefer_final_fields

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlabs/adapters/util/notification.dart';
import 'package:tdlabs/models/util/notification.dart';
import 'package:tdlabs/themes/app_colors.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:get/get.dart' as Get;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Notifications>? _voucherList;
  Future<List<dynamic>?>? _future;
  ScrollController _scrollController = ScrollController();
  String filterByUser = 'true';
  bool _isLoading = false;
  String? imageurl;
  @override
  void initState() {
    //  implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: RefreshIndicator(
            onRefresh: refreshList,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,

                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  children: [
                    Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(45.0),
                            bottomRight: Radius.circular(45.0),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 48, 186, 168),
                              Color.fromARGB(255, 49, 53, 131),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                       
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 18 / 100,
                            ),
                            Container(
                              alignment: Alignment.center,
                              height: 75,
                              child: Text(
                                "Notifications".tr,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ],
                        )),
                
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 85 / 100,
                      padding: EdgeInsets.only(top: 30),
                      child: _notificationBuilder(),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  _notificationBuilder() {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if ((snapshot.data != null) && (_voucherList!.isNotEmpty)) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              padding: EdgeInsets.zero,
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: (snapshot.data != null) ? _voucherList!.length : 0,
                itemBuilder: (context, index) {
                  return Container(
                  
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if( index != 0 &&_voucherList![index].createdAtText != _voucherList![index-1].createdAtText)
                        Container(
                          width: double.infinity,
                          color: Colors.grey[350],
                        
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_voucherList![index].createdAtText,
                                              style: TextStyle(fontSize: 18, color: Colors.grey[750], fontWeight: FontWeight.w500),),
                          )), 
                  
                          if(index == 0 )
                         Container(
                          width: double.infinity,
                          color: Colors.grey[350],
                        
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Today",
                                              style: TextStyle(fontSize: 18, color: Colors.grey[750], fontWeight: FontWeight.w500),),
                          )), 
                        NotificationAdapter(
                          notification: _voucherList![index],
                          color: (index % 2 == 0)
                              ? AppColors.evenFill
                              : AppColors.evenFill,
                        ),
                         Divider()
                      ],
                    ),
                  );
                }),
          );
        } else {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.bottom -
                    50,
                child: Center(
                  child: Visibility(
                    visible: (snapshot.data != null),
                    replacement: IntrinsicHeight(
                        child: ConnectionError(onRefresh: refreshList)),
                    child: Text('Empty Notifications'.tr),
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      },
    );
  }

  Future<void> refreshList() async {
    setState(() {
      _voucherList!.clear();
    });
    _performSearch();
  }

  void _performSearch() {
    // Reset list
    _isLoading = false;

    _future = _fetchVoucher();
  }

  Future<List<dynamic>?> _fetchVoucher() async {
    final webService = WebService(context);

    if (!_isLoading) {
      _isLoading = true;
      webService.setMethod('GET').setEndpoint('notification/logs');
      var response = await webService.send();
      print(response!.body);
      if (response.status) {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<Notifications> noti = parseList
            .map<Notifications>((json) => Notifications.fromJson(json))
            .toList();
        _voucherList =noti;
      }
    }
    _isLoading = false;
    return _voucherList;
  }
}
