// ignore_for_file: library_prefixes, prefer_final_fields, curly_braces_in_flow_control_structures, non_constant_identifier_names, unused_field

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:get/get.dart' as Get;
import 'package:tdlabs/models/time_session.dart';
import 'package:tdlabs/screens/medical/e-consult/consult_form.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:transparent_image/transparent_image.dart';

class ConsultPocScreen extends StatefulWidget {
  const ConsultPocScreen({
    Key? key,
  }) : super(key: key);
  @override
  _ConsultPocScreenState createState() => _ConsultPocScreenState();
}

class _ConsultPocScreenState extends State<ConsultPocScreen> {
  int _page = 0;
  int? _pageCount = 1;
  bool _isLoading = false;
  late Future<List<Poc>?> _future;
  List<Poc> _list = [];
  List<TimeSession> _package = [];
  ScrollController _scrollController = ScrollController();
  String _stateCode = '';
  int test_id = 0;
  bool ebook = false;
  String type = "";
  int _pickerIndex = 0;
  String _search = "";
  bool searching = false;
  Poc? selectPoc;
  int selected = 0;
  @override
  void initState() {
    super.initState();

    _future = _fetchPocs();
    _scrollController = ScrollController(initialScrollOffset: 5);
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              (_scrollController.position.maxScrollExtent - 500) &&
          !_scrollController.position.outOfRange) {
        setState(() {
          _future = _fetchPocs();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
         
        ),
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
                      height: 30,
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
                      width: MediaQuery.of(context).size.width * 19 / 100,
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 75,
                      child: Text(
                        "E-Consultation".tr,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w300),
                      ),
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
                            "Search by name",
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
                      onTap: () {},
                      child: Container(
                          alignment: Alignment.center,
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: const Color.fromARGB(255, 49, 53, 131)),
                          child: const Icon(Icons.search,
                              color: Colors.white, size: 30)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: RefreshIndicator(
                onRefresh: _refreshList,
                child: FutureBuilder(
                  future: _future,
                  builder: (context, snapshot) {
                    if ((snapshot.data != null)) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(10),
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: (snapshot.data != null) ? _list.length : 0,
                        itemBuilder: (context, index) {
                          Poc poc = _list[index];
                          return Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selected = index;
                                  selectPoc = poc;
                                });
                              },
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: (poc.image_url == null)
                                        ? Container(
                                            color: const Color.fromARGB(
                                                255, 224, 224, 224),
                                            height: 200,
                                            width: 140,
                                            child: Image.asset(
                                              'assets/images/icons-colored-01.png',
                                              fit: BoxFit.scaleDown,
                                            ))
                                        : SizedBox(
                                            height: 200,
                                            width: 140,
                                            child: FadeInImage.memoryNetwork(
                                              placeholder: kTransparentImage,
                                              image: poc.image_url!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                  ),
                                  if (selected == index)
                                    Container(
                                      height: 200,
                                      width: 140,
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 0, 0, 0)
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  Positioned(
                                      top: 145,
                                      child: Container(
                                          width: 150,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            poc.name!,
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: Colors.white),
                                          )))
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                44,
                            child: Center(
                              child: Visibility(
                                visible: (snapshot.data != null),
                                replacement: IntrinsicHeight(
                                    child: ConnectionError(
                                        onRefresh: _refreshList)),
                                child: Text('No result found.'.tr),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }
                  },
                ),
              ),
            ),
            if (selectPoc != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 370,
                  alignment: Alignment.bottomLeft,
                  child: Stack(
                    children: [
                      Scrollbar(
                        thumbVisibility: true,
                        thickness: 15,
                        controller: _scrollController,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Text(
                              selectPoc!.name!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'Dr Anne Renner is a Dentist in Kuala Kangar,Malaysia',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'She is current practicing at ' +
                                  selectPoc!.name!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Education',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'National University of Ireland',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Credentials',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'MBBCh BaO',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 140,
                        child: GestureDetector(
                          onTap: (){
                              Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          return ConsultFormScreen(
                            poc: selectPoc,
                            type: type,
                          );
                        }));
                          },
                          child: Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 48, 186, 168),
                                    Color.fromARGB(255, 49, 42, 130),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 35,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }


  Future<void> _refreshList() async {
    _performSearch();
  }

  void _performSearch({String? keyword, String? stateCode}) {
    // Reset list
    _page = 0;
    _pageCount = 1;
    _isLoading = false;
    if (keyword != null) {
      _search = keyword;
    }
    if (stateCode != null) {
      _stateCode = stateCode;
    }
    setState(() {
      _list.clear();
      _future = _fetchPocs();
    });
  }


  Future<List<TimeSession>?> _fetchPackage() async {
    final webService = WebService(context);
    webService.setEndpoint('option/test/packages');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<TimeSession> package = parseList
          .map<TimeSession>((json) => TimeSession.fromJson(json))
          .toList();
      setState(() {
        _package.addAll(package);
        type = _package[0].name!;
        test_id = _package[0].id!;
      });
    }
    return _package;
  }

  Future<List<Poc>?> _fetchPocs() async {
    final webService = WebService(context);
    if (test_id == 0) {
      await _fetchPackage();
    }
    if (!_isLoading && (_page < _pageCount!)) {
      _page++;
      _isLoading = true;
      webService.setEndpoint('screening/pocs').setPage(_page);
      Map<String, String> filter = {};

      filter.addAll({'mode': '0'});
      if (_search.isNotEmpty) {
        filter.addAll({'search': _search});
      }
      if (_stateCode.isNotEmpty) {
        filter.addAll({'state_code': _stateCode});
      }
      var response = await webService.setFilter(filter).send();
      if (response == null) return null;
      if (response.status) {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<Poc> pocs =
            parseList.map<Poc>((json) => Poc.fromJson(json)).toList();
        setState(() {
          if (_list.isNotEmpty) {
            for (int i = 0; i < _list.length; i++) {
              pocs.removeWhere((element) => element.name == _list[i].name);
            }
          }
          _list.addAll(pocs);
          selectPoc = _list[0];
        });
        _pageCount = response.pagination!['pageCount'];
      }
    }
    _isLoading = false;
    return _list;
  }
}
