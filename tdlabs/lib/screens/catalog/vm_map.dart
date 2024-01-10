// ignore_for_file: library_prefixes, prefer_final_fields

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/search/search_bar4.dart';

import '../../adapters/util/flutter_map.dart';
import '../../adapters/util/google_maps.dart';

typedef StringCallback = Function(String value);

// ignore: must_be_immutable
class VmMapScreen extends StatefulWidget {
  String? longitude;
  String? latitude;
  StringCallback? search;
  VmMapScreen({Key? key, this.latitude, this.longitude, this.search})
      : super(key: key);

  @override
  _VmMapScreenState createState() => _VmMapScreenState();
}

class _VmMapScreenState extends State<VmMapScreen> {
  List<VendingMachine> _list = [];
  int? vmId;
  List<String> _categoryList = ['Near Me', 'Smart Keluarga', 'Vendlah'];
  //String _selectedCode = 'all';
  //String _selectedName = '';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  String? search = "";
  int _selected = 0;
  int categoryId = 3;
  String categoryName = "Near Me";
  @override
  void initState() {
    super.initState();
    _fetchVM(context, widget.latitude, widget.longitude);
  }

  Future<List<VendingMachine>?> _fetchVM(
      BuildContext context, String? latitude, String? longitude) async {
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    }
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('catalog/search');
    Map<String, String> filter = {};
    filter.addAll({'latitude': widget.latitude.toString()});
    filter.addAll({'longitude': widget.longitude.toString()});
    filter.addAll({'event_type': "0"});
    if (categoryId != 3) filter.addAll({'type': categoryId.toString()});
    if (search != "") filter.addAll({'search': search.toString()});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<VendingMachine> vms = parseList.map<VendingMachine>((json) => VendingMachine.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _list.addAll(vms);
        });
      }
    }

    return _list;
  }

  void _performSearch({
    String? keyword,
  }) {
    // Reset list
    if (keyword != null) {
      setState(() {
        _list.clear();
        search = keyword;
      });
    }
    _fetchVM(context, widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-01.png"),
              fit: BoxFit.fill),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
         top:30,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
              child: SearchBar4(
                isCatalog: true,
                latitude: widget.latitude,
                longitude: widget.longitude,
                onSubmitted: (value) => _performSearch(
                  keyword: value,
                ),
              ),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
            Column(
              children: [
                Card(
                  elevation: 5,
                  child: SizedBox(
                    width: double.infinity,
                    height: 75,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _categoryList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 5),
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _selected = index;
                                  if (index == 0) {
                                    categoryId = 3;
                                  } else if (index == 1) {
                                    categoryId = 0;
                                  } else {
                                    categoryId = 1;
                                  }
                                  _list.clear();
                                  categoryName = _categoryList[index];
                                  _fetchVM(context, widget.latitude, widget.longitude);
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: (index == _selected)
                                          ? const Color.fromARGB(255, 241, 241, 241)
                                          : Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                      child: (index == 0)
                                          ? const Icon(Icons.near_me, size: 35)
                                          : (index == 1)
                                              ? Image.asset(
                                                  'assets/images/icons-colored-05.png',
                                                  height: 45,
                                                )
                                              : Image.asset(
                                                  'assets/images/vendla.png',
                                                  height: 45,
                                                ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90,
                                    child: Text(_categoryList[index],
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 9,
                                            color: (index == _selected)
                                                ? CupertinoTheme.of(context).primaryColor
                                                : const Color.fromARGB(255, 88, 88, 88),
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
            if (_list.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height - 202,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Map View\n(Based on your Current Location)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                      (Platform.isIOS)
                          ? GoogleMapsWidget(
                              name: "Vending Machine",
                              latitude: widget.latitude.toString(),
                              longitude: widget.longitude.toString(),
                              vm: _list,
                            )
                          : (androidInfo!.manufacturer == "HUAWEI")
                              ? MapWidget(
                                  name: "Vending Machine",
                                  latitude: widget.latitude.toString(),
                                  longitude: widget.longitude.toString(),
                                  vm: _list,
                                )
                              : GoogleMapsWidget(
                                  name: "Vending Machine",
                                  latitude: widget.latitude.toString(),
                                  longitude: widget.longitude.toString(),
                                  vm: _list,
                                )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
