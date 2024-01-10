// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/poc/poc_category.dart';
import 'package:tdlabs/models/poc/poc_directory.dart';
import 'package:tdlabs/screens/medical/directory/directory.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class DirectoryCategoryScreen2 extends StatefulWidget {
  String? latitude;
  String? longitude;
  List<int>? selectedCategory;
  DirectoryCategoryScreen2(
      {Key? key, this.latitude, this.longitude, this.selectedCategory})
      : super(key: key);
  @override
  _DirectoryCategoryScreen2State createState() =>
      _DirectoryCategoryScreen2State();
}

class _DirectoryCategoryScreen2State extends State<DirectoryCategoryScreen2> {
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
  int pageCount = 0;
  final ScrollController _listScrollController = ScrollController();
  List<String> alphabet = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '#'
  ];
  @override
  void initState() {
    super.initState();
    _fetchPocCategory(context, 0);
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
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
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
                            Navigator.pop(context, widget.selectedCategory);
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
                                  categoryId:  widget.selectedCategory!,
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
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Stack(
                      children: [
                        Container(
                            height: 900,
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
                                    "Select Healthcare Professionals",
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 15,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              controller: _listScrollController,
                                              itemCount: _categoryList.length,
                                              itemBuilder: (context, index) {
                                                PocCategory pocCategory =
                                                    _categoryList[index];
                                                String category =
                                                    _categoryList[index].name;
                                                String currentLetter = category
                                                    .substring(0, 1)
                                                    .toUpperCase();
                                                bool isFirstCategory = index ==
                                                        0 ||
                                                    currentLetter !=
                                                        _categoryList[index - 1]
                                                            .name
                                                            .substring(0, 1)
                                                            .toUpperCase();
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            width: 220,
                                                            height: 20,
                                                            child: Text(
                                                              pocCategory.name,
                                                              maxLines: 1,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontSize: 15),
                                                            ),
                                                          ),
                                                          if (!widget.selectedCategory!.contains(pocCategory.id))
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                             widget.selectedCategory!.add(
                                                              pocCategory.id);
                                                        });
                                                              },
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                width: 25,
                                                                height: 25,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100),
                                                                    color: const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        223,
                                                                        223,
                                                                        223)),
                                                              ),
                                                            ),
                                                          if (widget.selectedCategory!.contains(pocCategory.id))
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                             widget.selectedCategory!.remove(
                                                              pocCategory.id);
                                                        });
                                                              },
                                                              child: Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  width: 25,
                                                                  height: 25,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
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
                                                                      color: Colors
                                                                          .white,
                                                                      size:
                                                                          10)),
                                                            )
                                                        ],
                                                      ),
                                                      if (index !=
                                                              _categoryList
                                                                      .length -
                                                                  1 &&
                                                          currentLetter !=
                                                              _categoryList[
                                                                      index + 1]
                                                                  .name
                                                                  .substring(
                                                                      0, 1)
                                                                  .toUpperCase())
                                                        const Divider(
                                                          color: Colors.black,
                                                        )
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ),
                                        SizedBox(
                                          width: 25,
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: alphabet.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _scrollToCategory(index);
                                                  },
                                                  child: Text(alphabet[index],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 14.35)),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
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
                ),
              ],
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
    webService.setMethod('GET').setEndpoint('screening/poc-categories');
    Map<String, String> filter = {};
    filter.addAll({'depth': "1"});
    var response = await webService.setFilter(filter).send();
    if (response == null) return null;
    if (response.status) {
      setState(() {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        _categoryList = parseList
            .map<PocCategory>((json) => PocCategory.fromJson(json))
            .toList();
        print(_categoryList.length);
      });
    }
    return _categoryList;
  }

  void _scrollToCategory(int index) {
    if (index >= 0 && index < _categoryList.length) {
      String selectedLetter = alphabet[index];
      for (int i = 0; i < _categoryList.length; i++) {
        String category = _categoryList[i].name;
        if (category.startsWith(selectedLetter)) {
          double itemExtent =
              20.0; // Adjust this based on your list item height
          double offset = i * itemExtent;
          _listScrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.bounceIn,
          );
          break;
        }
      }
    }
  }
}
