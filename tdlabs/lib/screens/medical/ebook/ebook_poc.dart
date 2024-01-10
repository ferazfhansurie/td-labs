// ignore_for_file: library_prefixes, prefer_final_fields, curly_braces_in_flow_control_structures, non_constant_identifier_names, unused_field

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:get/get.dart' as Get;
import 'package:tdlabs/models/time_session.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:tdlabs/widgets/search/search_bar_ebook.dart';
import '../../../adapters/poc/poc2.dart';
import 'ebook_form.dart';


class EbookPocScreen extends StatefulWidget {
  const EbookPocScreen({
    Key? key,
  }) : super(key: key);
  @override
  _EbookPocScreenState createState() => _EbookPocScreenState();
}

class _EbookPocScreenState extends State<EbookPocScreen> {
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
                    SizedBox(
                      height: 30,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Select Point of Care".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.w300),
                    ),
                    const Spacer()
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  if (searching == false)
                    GestureDetector(
                      onTap: () {
                        _showPicker();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 160,
                                child: Text(
                                  type,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down)
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (searching == false)
                    const SizedBox(
                      width: 15,
                    ),
                  SearchBarEbook(
                    onChanged: (value) {
                      if (value != "") {
                        setState(() {
                          searching = true;
                        });
                      } else if (value == "") {
                        setState(() {
                          searching = false;
                        });
                      }
                    },
                    onClear: () {
                      setState(() {
                        _search = "";
                      });
                    },
                    onSubmitted: (value) =>
                        _performSearch(keyword: value, stateCode: _stateCode),
                  ),
                ],
              ),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
            _pocBuilder()
          ],
        ),
      ),
    );
  }

  _pocBuilder() {
    return Flexible(
      child: RefreshIndicator(
        onRefresh: _refreshList,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if ((snapshot.data != null)) {
              return ListView.builder(
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
                        setState(() {});
                        Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          return EbookFormScreen(
                            poc: poc,
                            type: type,
                          );
                        }));
                      },
                      child: PocAdapter2(
                        poc: poc,
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
                            child: ConnectionError(onRefresh: _refreshList)),
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
                      _isLoading = false;
                      setState(() {
                        type = _package[_pickerIndex].name!;
                        test_id = _package[_pickerIndex].id!;
                        _list.clear();
                        _future = _fetchPocs();
                      });
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
                  for (var session in _package)
                    Text(
                      session.name!.tr,
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
    if(test_id == 0){
        await  _fetchPackage();
    }
    if (!_isLoading && (_page < _pageCount!)) {
      _page++;
      _isLoading = true;
      webService.setEndpoint('screening/pocs').setPage(_page);
      Map<String, String> filter = {};
      filter.addAll({'test_type': test_id.toString()});
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
        });
        _pageCount = response.pagination!['pageCount'];
      }
    }
    _isLoading = false;
    return _list;
  }
}