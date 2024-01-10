// ignore_for_file: library_prefixes, prefer_final_fields, must_be_immutable, curly_braces_in_flow_control_structures, unused_field

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/adapters/util/google_maps.dart';
import 'package:tdlabs/models/commerce/vending_machine.dart';
import 'package:tdlabs/screens/catalog/vm_screen.dart';
import 'package:tdlabs/widgets/sliver/sliver_appbar.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:get/get.dart' as Get;

import '../../adapters/catalog/vending_machine.dart';
import '../../adapters/util/flutter_map.dart';

class VmSelectScreen extends StatefulWidget {
  VmSelectScreen({Key? key, this.latitude, this.longitude, this.type})
      : super(key: key);
  String? latitude;
  String? longitude;
  int? type;
  
  @override
  _VmSelectScreenState createState() => _VmSelectScreenState();
}

class _VmSelectScreenState extends State<VmSelectScreen> {
  int? vmId;
  late Future<List<VendingMachine>?> _future;
  bool _isLoading = false;
  List<VendingMachine> _list = [];
  ScrollController? _scrollController;
  int _page = 0;
  int _pageCount = 1;
  bool isLoading = false;
  List<String> _categoryList = ['Near Me', 'Smart Keluarga','Allegra','Anker','Anyway','AZ Syntech'];
  List<String> _categoryList2 = [
    'Near Me',
    'Vendlah',
  ];
  int _selected = 0;
  int categoryId = 3;
  String search = "";
  int _pickerIndex = 0;
  String categoryName = "Near Me";
  bool map = false;
  int type = 0;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  @override
  void initState() {
    super.initState();
    if(widget.type != null)
    type = widget.type!;
    _future = _fetchVM(context, widget.latitude, widget.longitude);
    _scrollController = ScrollController(initialScrollOffset: 5);
    _scrollController!.addListener(() {
      if (_scrollController!.offset >=
              (_scrollController!.position.maxScrollExtent - 100) &&
          !_scrollController!.position.outOfRange) {
        setState(() {
          _future = _fetchVM(context, widget.latitude, widget.longitude);
        });
      }
    });
  }

  Future<List<VendingMachine>?> _fetchVM(
      BuildContext context, String? latitude, String? longitude) async {
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    }
    final webService = WebService(context);
    if (isLoading == false && (_page < _pageCount)) {
      setState(() {
        _page++;
        isLoading = true;
      });
      webService.setMethod('GET').setEndpoint('catalog/search').setPage(_page);
      Map<String, String> filter = {};
      filter.addAll({'latitude': latitude.toString()});
      filter.addAll({'longitude': longitude.toString()});
      filter.addAll({'event_type': "0"});
      if (categoryId != 3) filter.addAll({'type': categoryId.toString()});
      if (search != "") filter.addAll({'search': search.toString()});
      var response = await webService.setFilter(filter).send();
      print(response!.body);
      if (response == null) return null;
      if (response.status) {
        final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<VendingMachine> vms = parseList.map<VendingMachine>((json) => VendingMachine.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            _list.addAll(vms);
            isLoading = false;
          });
        }
      }
      _pageCount = response.pagination!['pageCount']!;
    }
    return _list;
  }

  Widget _vmMap() {
    return SliverToBoxAdapter(
      child: Padding(
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
      ),
    );
  }

  Widget _vmBuilder() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (_list.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child:  const Column(
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else {
            VendingMachine vm = _list[index];
            return GestureDetector(
              onTap: () {
                if (search == "" || vm.product_list!.isEmpty) {
                  setState(() {
                    vmId = vm.id;
                  });
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return VmScreen(vm: vm);
                      },
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: VendingMachineAdapter(
                    vendingMachine: vm,
                    index: index,
                    search: search,
                    vmTap: () {
                      setState(() {
                        vmId = vm.id;
                      });
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) {
                            return VmScreen(vm: vm);
                          },
                        ),
                      );
                    }),
              ),
            );
          }
        },
        childCount: (_list.isEmpty) ? 1 : _list.length,
      ),
    );
  }

  Future<void> _refreshList() async {
    _performSearch();
  }

  void _performSearch({
    String? keyword,
  }) {
    // Reset list

    _isLoading = false;
    if (keyword != null) {
      setState(() {
        _list.clear();
        _page = 0;
        _pageCount = 1;
        search = keyword;
      });
    }
    _future = _fetchVM(context, widget.latitude, widget.longitude);
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              delegate: CustomSliverAppBarDelegate(
                
                  expandedHeight: 75,
                  category: categoryName,
                  latitude: widget.latitude,
                  longitude: widget.longitude,
                  isCatalog: true,
                  mapShown: map,
                  map: () {
                    setState(() {
                      map = !map;
                    });
                  },
                  search: (value) => _performSearch(
                        keyword: value,
                      ),
                  showPicker: _showPicker),
              pinned: true,
            ),
            const SliverPadding(padding: EdgeInsets.all(8)),
            _categoryBuilder(),
            const SliverToBoxAdapter(
                child: Divider(
              height: 5,
            )),
            (type != 1)
                ? (_isLoading == false && _list.isNotEmpty)
                    ? (map == false)
                        ? _vmBuilder()
                        : _vmMap()
                    : SliverToBoxAdapter(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height:
                                MediaQuery.of(context).size.height * 40 / 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Center(
                                    child: CircularProgressIndicator()),
                                Center(
                                  child: Text(
                                    'Fetching Nearest Machines'.tr,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )),
                      )
                : SliverToBoxAdapter(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 40 / 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                'Coming Soon'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )),
                  )
          ],
        ),
      ),
    );
  }

  Widget _categoryBuilder() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          if (type == 0)
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
                              } else if (index == 2) {
                              categoryId = 2;
                            }else {
                                categoryId = 1;
                              }
                              _list.clear();
                              categoryName = _categoryList[index];
                              _page = 0;
                              _future = _fetchVM(
                                  context, widget.latitude, widget.longitude);
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 1),
                                  child: (index == 0)
                                      ? const Icon(Icons.near_me, size: 35)
                                       : (index == 1)
                                        ? Image.asset(
                                            'assets/images/icons-colored-05.png',
                                               height: 50,
                                                 width: 50,
                                          )
                                        : (index == 2)
                                            ? Image.asset(
                                                'assets/images/allegra.png',
                                                   height: 50,
                                                 width: 50,
                                              )
                                            : (index == 3)
                                            ? Image.asset(
                                                'assets/images/Anker_logo.png',
                                                height: 50,
                                                width: 50,
                                              )
                                            : (index == 4)
                                            ? Image.asset(
                                                'assets/images/anyway_logo.png',
                                                height: 50,
                                                width: 50,
                                              ):Image.asset(
                                                'assets/images/az_logo.png',
                                                height: 50,
                                                 width: 50,
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
                                            ? CupertinoTheme.of(context)
                                                .primaryColor
                                            : const Color.fromARGB(
                                                255, 88, 88, 88),
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
          if (type == 1)
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
                              categoryName = _categoryList[index];
                              _page = 0;
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 1),
                                  child: (index == 0)
                                      ? const Icon(Icons.near_me, size: 35)
                                      :  Image.asset(
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
                                            ? CupertinoTheme.of(context)
                                                .primaryColor
                                            : const Color.fromARGB(
                                                255, 88, 88, 88),
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
    );
  }

  _showPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      _page = 0;
                      _pageCount = 1;
                      setState(() {
                        _selected = _pickerIndex;
                        if (_pickerIndex == 0) {
                          categoryId = 3;
                        } else if (_pickerIndex == 1) {
                          categoryId = 0;
                        } else {
                          categoryId = 1;
                        }
                        categoryName = _categoryList[_pickerIndex];
                        _list.clear();
                      });
                      _refreshList();
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                    child: Text('Confirm'.tr),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: _pickerIndex),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (value) {
                  setState(() {
                    _pickerIndex = value;
                  });
                },
                itemExtent: 32.0,
                children: [
                  for (var session in _categoryList)
                    Text(
                      session.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
