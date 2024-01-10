// ignore_for_file: must_be_immutable, deprecated_member_use, unused_field

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:tdlabs/models/poc/poc_category.dart';
import 'package:tdlabs/models/poc/poc_directory.dart';
import 'package:tdlabs/screens/medical/ebook/ebook_form.dart';
import 'package:tdlabs/widgets/sliver/sliver_appbar.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../../adapters/poc/poc_directory.dart';
import '../../../adapters/util/flutter_map.dart';
import '../../../adapters/util/google_maps.dart';

class DirectoryScreen extends StatefulWidget {
  String? categoryName;
  List<int>? categoryId;
  String? latitude;
  String? longitude;
  int? selected;
  DirectoryScreen(
      {Key? key,
      this.categoryId,
      this.categoryName,
      this.latitude,
      this.longitude,
      this.selected})
      : super(key: key);

  @override
  _DirectoryScreenState createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  String? directory;
  final List<PocDirectory> _clinicList = [];
  final List<PocCategory> _subcategoryList = [];
  List<PocCategory> _categoryList = [];
  List<AvailableMap> availableMaps = [];
  final List<Poc> _list = [];
  int? totalPage;
  int? perPage = 0;
  bool isSub = false;
  int categoryIndex = 0;
  int categoryIndex2 = 0;
  int subcategoryId = 1;
  List<int> categoryId = [];
  int totalSub = 0;
  PocCategory? subCategory;
  String _search = '';
  Future<List<PocDirectory>?>? _future;
  Future<List<PocCategory>?>? _future2;
  int _page = 0;
  int _pageCount = 1;
  int _page2 = 0;
  final int _pageCount2 = 1;
  bool isLoading = false;
  String categoryName = "";
  int _pickerIndex = 0;
  ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final GlobalKey progressDialogKey = GlobalKey<State>();
  Map<String, String> stateList = {
    'all': '',
    'my-01': 'Johor',
    'my-02': 'Kedah',
    'my-03': 'Kelantan',
    'my-04': 'Melaka',
    'my-05': 'Negeri Sembilan',
    'my-06': 'Pahang',
    'my-07': 'Pulau Pinang',
    'my-08': 'Perak',
    'my-09': 'Perlis',
    'my-10': 'Selangor',
    'my-11': 'Terengganu',
    'my-12': 'Sabah',
    'my-13': 'Sarawak',
    'my-14': 'Kuala Lumpur',
    'my-15': 'Labuan',
    'my-16': 'Putrajaya',
  };
  bool showPage = false;
  int _selected = 0;
  bool scrolled = false;
  double height = 1000;
  bool map = false;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  bool fetchLoading = false;
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    setState(() {
      categoryId = widget.categoryId!;
      _future2 = _fetchPocCategory(context, 0);
      _future = _fetchClinicDirectory();
      if (widget.selected != null) {
        _selected = widget.selected!;
      }
      _showMap();
      _pageController = PageController(viewportFraction: 0.4, initialPage: 0);
      _scrollController = ScrollController(initialScrollOffset: 5);
      _scrollController.addListener(() {
        if (_scrollController.offset >=
                (_scrollController.position.maxScrollExtent - 100) &&
            !_scrollController.position.outOfRange) {
          setState(() {
            _future = _fetchClinicDirectory();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _clinicList.clear();
    _subcategoryList.clear();
    _categoryList.clear();
    _pageController.dispose();
    super.dispose();
  }

  void _performSearch({String? keyword}) {
    // Reset list
    if (keyword != null) {
      setState(() {
        _search = keyword;
        _page = 0;
        _pageCount = 1;
        _clinicList.clear();
      });
    } else {
      _search = "";
    }
    _future = _fetchClinicDirectory();
  }

  Future<void> _refreshDirectory() async {
    setState(() {
      _clinicList.clear();
      _page = 0;
      _pageCount = 1;
    });
    _future = _fetchClinicDirectory();
  }

  Future<void> _showMap() async {
    availableMaps = await MapLauncher.installedMaps;
    // [AvailableMap { mapName: Google Maps, mapType: google }, ...]
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Background-01.png"),
                fit: BoxFit.fill),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPersistentHeader(
                  delegate: CustomSliverAppBarDelegate(
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                      map: () {
                        setState(() {
                          map = !map;
                        });
                      },
                      mapShown: map,
                      expandedHeight: 75,
                      category: categoryName,
                      isCatalog: false,
                      search: (value) => _performSearch(
                            keyword: value,
                          ),
                      showPicker: _showPicker),
                  pinned: true,
                ),
                const SliverPadding(padding: EdgeInsets.all(10)),
                if (map == false && _clinicList.isNotEmpty) _clinicBuilder(),
                if (map == true && _clinicList.isNotEmpty) _clinicMap(),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(),
                ),
              ],
            ),
          )),
    );
  }

  Widget _categoryBuilder() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: FutureBuilder(
                future: _future2,
                builder: (context, snapshot) {
                  if ((snapshot.data != null)) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      width: double.infinity,
                      height: 195,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: (60 / 75),
                        ),
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController2,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _categoryList.length,
                        itemBuilder: (context, index) {
                          PocCategory category = _categoryList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 1, vertical: 5),
                            child: GestureDetector(
                              onTap: () async {
                                _selected = index;
                                setState(() {
                                  categoryIndex = index;
                                  categoryId.add(category.id);
                                  categoryName = category.name;
                                  _clinicList.clear();
                                });
                                _refreshDirectory();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: (index == _selected)
                                          ? const Color.fromARGB(
                                              255, 241, 241, 241)
                                          : Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 6),
                                      child: (category.image_url != null)
                                          ? Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image: category.image_url!,
                                                height: 35,
                                              ),
                                            )
                                          : const Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                Icons.local_hospital_rounded,
                                                size: 30,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 108,
                                    child: Text(
                                      category.name.tr,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: (index == _selected)
                                            ? CupertinoTheme.of(context)
                                                .primaryColor
                                            : const Color.fromARGB(
                                                255, 88, 88, 88),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: const Text(
                        "Fetching Category",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clinicMap() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
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
                      name: "Directory Map",
                      latitude: widget.latitude.toString(),
                      longitude: widget.longitude.toString(),
                      clinic: _clinicList,
                      showAdditional: _showAdditional,
                      categoryName: categoryName,
                    )
                  : (androidInfo!.manufacturer == "HUAWEI")
                      ? MapWidget(
                          name: "Directory Map",
                          latitude: widget.latitude.toString(),
                          longitude: widget.longitude.toString(),
                          clinic: _clinicList,
                          categoryName: categoryName,
                        )
                      : GoogleMapsWidget(
                          name: "Directory Map",
                          latitude: widget.latitude.toString(),
                          longitude: widget.longitude.toString(),
                          clinic: _clinicList,
                          categoryName: categoryName,
                        )
            ],
          ),
        ),
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
                    child: Text(
                      'Cancel'.tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'.tr),
                    onPressed: () {
                      _page = 0;
                      _pageCount = 1;
                      setState(() {
                        _selected = _pickerIndex;
                        categoryIndex = _pickerIndex;
                        categoryId.add(_categoryList[_pickerIndex].id);
                        categoryName = _categoryList[_pickerIndex].name;
                        _clinicList.clear();
                      });
                      _refreshDirectory();
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
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
                      session.name.tr,
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

  _showWhatsApp(BuildContext context, List<String> numbers) {
    Widget cancelButton = CupertinoButton(
      child: const Text(
        'Back',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Whatsapp",
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      content: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: SelectableText(
                          numbers[index],
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            _launchWhatsapp(numbers[index]);
                          },
                          child: Image.asset(
                            "assets/images/whatsapp.jpg",
                            height: 30,
                            width: 30,
                          ))
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(false), child: alert);
      },
    );
  }

  _showImage(BuildContext context, String url) {
    Widget cancelButton = CupertinoButton(
      child: const Text(
        'Back',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.all(0.0),
      content: SizedBox(
        height: 400,
        width: double.infinity,
        child: Image.network(
          url,
          fit: BoxFit.fill,
        ),
      ),
      actions: [
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () => Future.value(true), child: alert);
      },
    );
  }

  _showAdditional(PocDirectory directory, String stateName, String category) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        List<String> numbers = [];
        if (directory.other_phone_no != null) {
          var number = directory.other_phone_no!.replaceAll(
            '[',
            '',
          );
          number = number.replaceAll(
            '"',
            "",
          );
          number = number.replaceAll(
            ']',
            "",
          );
          numbers = number.split(',');
        }
        return Container(
          color: const Color.fromARGB(255, 245, 245, 245),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 175,
                    child: (directory.image_url == null)
                        ? const Icon(
                            Icons.local_hospital,
                            size: 100,
                          )
                        : FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: directory.image_url!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 25,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                padding: const EdgeInsets.only(left: 10),
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  directory.name,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 24, 112, 141)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(
                      height: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 30 / 100,
                              child: Text(
                                'Address: '.tr,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 24, 112, 141)),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(top: 15),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width *
                                    60 /
                                    100,
                                child: SelectableText(
                                    (directory.address != null)
                                        ? directory.unit_no! +
                                            ", " +
                                            directory.street_1 +
                                            ", " +
                                            directory.street_2! +
                                            ", " +
                                            directory.city +
                                            ", " +
                                            directory.postcode +
                                            ", " +
                                            stateName
                                        : "",
                                    maxLines: 5,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 104, 104, 104),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (directory.description != "")
                      Container(
                        padding: const EdgeInsets.only(left: 15),
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: [
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      30 /
                                      100,
                                  child: Text(
                                    "Description: ".tr,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 24, 112, 141)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      40 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      directory.description!,
                                      maxLines: 5,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (directory.images != null && directory.images!.isNotEmpty)
                Container(
                  color: Colors.white,
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        height: 1,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 30 / 100,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            "Images: ".tr,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 24, 112, 141)),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          height: 165,
                          child: PageView.builder(
                            padEnds: false,
                            clipBehavior: Clip.none,
                            controller: _pageController,
                            onPageChanged: (int index) {
                              setState(() {});
                            },
                            itemCount: directory.images!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: Opacity(
                                  opacity: 1.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      _showImage(
                                          context, directory.images![index]);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      width: 75,
                                      height: 165,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          directory.images![index],
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if (directory.packages != null)
                Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        height: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          "Packages:",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: CupertinoTheme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: directory.packages!.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 200,
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  directory.packages![index]
                                                      ['name'],
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            var list = await _fetchPocs(
                                                directory, index);
                                            if (list!.isNotEmpty) {
                                              Navigator.of(context).push(
                                                  CupertinoPageRoute(
                                                      builder: (context) {
                                                return EbookFormScreen(
                                                  poc: list[0],
                                                  type: directory
                                                      .packages![index]['name']
                                                      .toString(),
                                                );
                                              }));
                                            } else {}
                                          },
                                          child: const Card(
                                            color: Color.fromARGB(
                                                255, 24, 112, 141),
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                "Book",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              Container(
                color: Colors.white,
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Directions".tr,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.of(context).padding.bottom),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: availableMaps.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await availableMaps[index].showMarker(
                                        coords: Coords(
                                            double.parse(directory.latitude),
                                            double.parse(directory.longitude)),
                                        title: directory.name,
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Card(
                                          elevation: 5,
                                          child: SvgPicture.asset(
                                            availableMaps[index].icon,
                                            height: 40.0,
                                            width: 40.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Text(
                              "Contact".tr,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    var tel = directory.phone_no;
                                    _launchURL("tel:$tel");
                                  },
                                  child: const Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.phone,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                if (directory.other_phone_no != null &&
                                    directory.other_phone_no != "")
                                  GestureDetector(
                                    onTap: () {
                                      _showWhatsApp(context, numbers);
                                    },
                                    child: Card(
                                      elevation: 5,
                                      child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: SizedBox(
                                              height: 30,
                                              width: 30,
                                              child: Image.asset(
                                                "assets/images/whatsapp.jpg",
                                                fit: BoxFit.cover,
                                              ))),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Poc>?> _fetchPocs(PocDirectory directory, int index) async {
    final webService = WebService(context);
    _list.clear();
    isLoading = true;
    var id = directory.poc_id;
    _page2 = 0;
    webService.setEndpoint('screening/pocs/$id');
    Map<String, String> filter = {};
    filter
        .addAll({'test_type': directory.packages![index]['value'].toString()});
    filter.addAll({'mode': '0'});
    ProgressDialog.show(context, progressDialogKey);
    var response = await webService.setFilter(filter).send();
    ProgressDialog.hide(progressDialogKey);
    if (response == null) return null;
    if (response.status) {
      Poc poc = Poc.fromJson(jsonDecode(response.body.toString()));
      setState(() {
        _list.add(poc);
      });
    }
    isLoading = false;
    return _list;
  }

  void _launchWhatsapp(String number) async {
    String url = 'https://wa.me/$number?text=Helpdesk,New%20Message';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _clinicBuilder() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (_clinicList.isNotEmpty) {
            var clinic = _clinicList[index];
            String stateName = (stateList[clinic.state_code] != null)
                ? stateList[clinic.state_code]!
                : "";
            return GestureDetector(
              onTap: () async {
                _showAdditional(clinic, stateName, categoryName);
              },
              child: PocDirectoryAdapter(
                poc: clinic,
                color: Colors.white,
                availableMaps: availableMaps,
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                children: const [
                  Text(
                    "No Clinics Found",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            );
          }
        },
        childCount: (_clinicList.isNotEmpty) ? _clinicList.length : 1,
      ),
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
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      _categoryList = parseList
          .map<PocCategory>((json) => PocCategory.fromJson(json))
          .toList();
      widget.categoryName ??= _categoryList[0].name;
      setState(() {
        categoryName = _categoryList[0].name;
        categoryId.add(_categoryList[0].id);
      });
    }
    return _categoryList;
  }

  Future<List<PocDirectory>?> _fetchClinicDirectory() async {
    final webService = WebService(context);
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    }
    if (isLoading == false && (_page < _pageCount)) {
      setState(() {
        _page++;
        fetchLoading = true;
      });
      webService.setMethod('GET').setEndpoint('screening/poc-directories').setPage(_page);
      Map<String, String> filter = {};
      filter.addAll({'latitude': widget.latitude.toString()});
      filter.addAll({'longitude': widget.longitude.toString()});
      if (_search != "") {
        filter.addAll({'search': _search});
      }
      if (_search == "") {
        filter.addAll({'parent_category': (categoryId.length >1)?categoryId.toString():categoryId[0].toString()});
      }
      if (subcategoryId != 1) {
        filter.addAll({'category_id': subcategoryId.toString()});
      }
      isLoading = true;
      print(categoryId.toString());
      var response = await webService.setFilter(filter).send();
      print(response!.body);
      isLoading = false;
      if (response == null) return null;
      if (response.status) {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<PocDirectory> directory = parseList
            .map<PocDirectory>((json) => PocDirectory.fromJson(json))
            .toList();
        _clinicList.addAll(directory);
        setState(() {});
        fetchLoading = false;
        _pageCount = response.pagination!['pageCount']!;
        totalPage = response.pagination!['totalCount']!;
      }
    }
    return _clinicList;
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
}
