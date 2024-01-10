// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_place/google_place.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/poc/poc_category.dart';
import 'package:tdlabs/models/poc/poc_directory.dart';
import 'package:tdlabs/screens/medical/directory/directory.dart';
import 'package:tdlabs/screens/medical/directory/directorycategory2.dart';
import 'package:tdlabs/screens/others/lalamove.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class DirectoryCategoryScreen extends StatefulWidget {
  String? latitude;
  String? longitude;
  DirectoryCategoryScreen({Key? key, this.latitude, this.longitude})
      : super(key: key);
  @override
  _DirectoryCategoryScreenState createState() =>
      _DirectoryCategoryScreenState();
}

class _DirectoryCategoryScreenState extends State<DirectoryCategoryScreen> {
  String? directory;
  final List<PocDirectory> _clinicList = [];
  final List<PocCategory> _subcategoryList = [];
  List<PocCategory> _categoryList = [];
  bool isSub = false;
  int categoryIndex = 0;
  int categoryIndex2 = 0;
  int categoryId = 11;
  int subcategoryId = 1;
  int totalSub = 0;
  PocCategory? subCategory;
  List<int>? selectedCategory = [];
  int pageCount = 0;
  final _locationController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final postcodeController = TextEditingController();
  final cityController = TextEditingController();
  late GooglePlace googlePlace;

  @override
  void initState() {
    super.initState();
    String apiKey = MainConfig.googleMapApi;
    googlePlace = GooglePlace(apiKey);
    _locationController.text = "Current Location";
    _fetchPocCategory(context, 0);
    _fetchPocCategory2(context, 0);
  }

  @override
  void dispose() {
    _clinicList.clear();
    _subcategoryList.clear();
    _categoryList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Container(
                      height: 100,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 25 / 100,
                          ),
                          Text(
                            "Directory".tr,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 300,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white),
                          child: Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: Text(
                                  "Search",
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 260,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return DirectoryScreen(
                                  latitude: widget.latitude,
                                  longitude: widget.longitude,
                                  categoryId: selectedCategory!,
                                  selected: 0,
                                );
                              }));
                            },
                            child: Container(
                                alignment: Alignment.center,
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color:
                                        const Color.fromARGB(255, 49, 53, 131)),
                                child: const Icon(Icons.search,
                                    color: Colors.white, size: 30)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Map<String, dynamic> lalamove;
                      var temp = await Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return Lalamove(
                          locationController: _locationController,
                          address1Controller: address1Controller,
                          address2Controller: address2Controller,
                          cityController: cityController,
                          postcodeController: postcodeController,
                          googlePlace: googlePlace,
                        );
                      }));
                      if (temp != null) {
                        lalamove = temp;
                        setState(() {
                          _locationController.text = lalamove['name'];
                          widget.latitude = lalamove['latitude'].toString();
                          widget.longitude = lalamove['longitude'].toString();
                        });
                        try {
                          // Use geocoding to get the address components
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                  lalamove['latitude'], lalamove['longitude'],
                                  localeIdentifier: lalamove['name']);

                          if (placemarks.isNotEmpty) {
                            Placemark placemark = placemarks[0];
                          }
                        } catch (e) {
                          // ignore: avoid_print
                          print('Error getting address components: $e');
                        }
                      } else {
                        setState(() {});
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 150,
                      
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color.fromARGB(255, 48, 186, 168),
                              size: 25),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SizedBox(
                              width: 120,
                              child: Text(
                                _locationController.text,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat', fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Stack(
                      children: [
                        Container(
                            height: 302,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: const Color.fromARGB(255, 201, 201, 201),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Common Searches",
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 15,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  if (_categoryList.isNotEmpty)
                                    ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: _categoryList.length,
                                        itemBuilder: (context, index) {
                                          PocCategory pocCategory =
                                              _categoryList[index];
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: 225,
                                                    child: Text(
                                                      pocCategory.name,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: Colors.black54,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                  if (!selectedCategory!
                                                      .contains(pocCategory.id))
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedCategory!.add(
                                                              pocCategory.id);
                                                        });
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 25,
                                                        height: 25,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            color: const Color
                                                                    .fromARGB(
                                                                255,
                                                                223,
                                                                223,
                                                                223)),
                                                      ),
                                                    ),
                                                  if (selectedCategory!
                                                      .contains(pocCategory.id))
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedCategory!
                                                              .remove(
                                                                  pocCategory
                                                                      .id);
                                                        });
                                                      },
                                                      child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          width: 25,
                                                          height: 25,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              color: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  48,
                                                                  186,
                                                                  168)),
                                                          child: const Icon(
                                                              CupertinoIcons
                                                                  .check_mark,
                                                              color:
                                                                  Colors.white,
                                                              size: 10)),
                                                    )
                                                ],
                                              ),
                                              const Divider(
                                                color: Colors.black,
                                              )
                                            ],
                                          );
                                        }),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      
                                      var check =await Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return DirectoryCategoryScreen2(
                                            latitude: widget.latitude,
                                            longitude: widget.longitude,
                                            selectedCategory: selectedCategory);
                                      }));
                                      if (check != null) {
                                        setState(() {
                                             selectedCategory = check;
                                        });
                                       
                                      }
                                    },
                                    child: const Text(
                                      "View full list of healthcare professionals >",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 11,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 65.0),
                                    child: Divider(
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            )),
                        Positioned(
                          left: 290,
                          child: Container(
                              alignment: Alignment.center,
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color:
                                      const Color.fromARGB(255, 48, 186, 168)),
                              child: const Icon(CupertinoIcons.chevron_down,
                                  color: Colors.white, size: 25)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  showSubCategory(BuildContext context, String name) {
    // set up the AlertDialog
    Widget alert = Container(
      height: 200,
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              'Choose Sub-Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            content: SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(5),
                    itemCount: _subcategoryList.length,
                    itemBuilder: (context, index) {
                      PocCategory category = _subcategoryList[index];
                      return Padding(
                          padding: const EdgeInsets.all(4),
                          child: GestureDetector(
                            onTap: () {},
                            child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(name),
                                )),
                          ));
                    })),
          ),
        ],
      ),
    );
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<List<PocCategory>?>? _fetchPocCategory(
      BuildContext context, int page) async {
    final webService = WebService(context);
    webService
        .setMethod('GET')
        .setEndpoint('screening/poc-category/common-searches');
    Map<String, String> filter = {};

    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      setState(() {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        _categoryList = parseList
            .map<PocCategory>((json) => PocCategory.fromJson(json))
            .toList();
      });
    }
    return _categoryList;
  }

  Future<List<PocCategory>?>? _fetchPocCategory2(
      BuildContext context, int page) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('screening/poc-categories');
    Map<String, String> filter = {};
    filter.addAll({'depth': "1"});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      setState(() {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        var _categoryList2 = parseList
            .map<PocCategory>((json) => PocCategory.fromJson(json))
            .toList();
      });
    }
    return _categoryList;
  }
}
