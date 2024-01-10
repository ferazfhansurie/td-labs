// ignore_for_file: library_prefixes, prefer_final_fields, must_be_immutable, curly_braces_in_flow_control_structures, unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/content/event.dart';
import 'package:tdlabs/screens/free/free_select%20copy.dart';
import 'package:tdlabs/screens/home/home.dart';
import 'package:tdlabs/utils/toast.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:get/get.dart' as Get;
import 'package:transparent_image/transparent_image.dart';

class VmFreeSelectScreen extends StatefulWidget {
  int? from;
   VmFreeSelectScreen({
    Key? key,
    this.from,
  }) : super(key: key);
  @override
  _VmFreeSelectScreenState createState() => _VmFreeSelectScreenState();
}

class _VmFreeSelectScreenState extends State<VmFreeSelectScreen> {
  int? vmId;
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderNameList = [];
  List<Event> _popList = [];
  @override
  void initState() {
    super.initState();
    _checkEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Background-01.png"),
                fit: BoxFit.fill),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(
           
          ),
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
                        "Claim your Free Gift Now!".tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              const Divider(color: CupertinoColors.separator, height: 2),
              if (_popList.isNotEmpty)
                ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    Card(
                        child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: _popList[0].vouchers[0]['image_url'],
                        height: 120,
                      ),
                    )),
                    if(_popList[0].image_url != null)
                    Card(
                        child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: _popList[0].image_url,
                        height: 120,
                      ),
                    )),
                  ],
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 88.0, horizontal: 8),
                child: SizedBox(
                  height: 36,
                  child: SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: CupertinoButton(
                      color: CupertinoTheme.of(context).primaryColor,
                      disabledColor: CupertinoColors.inactiveGray,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _submit(context);
                      },
                      child: Text('Claim Now'.tr,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontWeight: FontWeight.w300)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    Response? response;
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('marketing/events/claim');
    Map<String, String> data = {};
    data['event_id'] = _popList[0].id.toString();

    response = await webService.setData(data).send();
    if (response!.status) {
      _showThankyou(context);
    } else {
      Toast.show(context, 'danger', "Unable to claim");
    }
  }

  Future<List?> _checkEvent() async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('marketing/events');
    Map<String, String> filter = {};
    filter.addAll({'type': '1'});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<Event> event =
          parseList.map<Event>((json) => Event.fromJson(json)).toList();
      setState(() {
        _popList.addAll(event);
      });
    }

    return _popList;
  }

  _showThankyou(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      key: const Key("pop_button"),
      child: Text(
        'Back'.tr,
        style: TextStyle(
          color: CupertinoTheme.of(context).primaryColor,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        if(widget.from == 1){
            Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return  const Home();
        }));
        }else{
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                      return const VmFreeSelectScreen2();
                    }));
        }
      
      },
    );

    // set up the AlertDialog
    Container alert = Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 60),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/images/thankyou.jpg",
                width: 300.0,
                height: 400.0,
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(child: cancelButton),
            )
          ],
        ));
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }
}
