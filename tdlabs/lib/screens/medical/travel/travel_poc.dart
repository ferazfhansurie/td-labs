// ignore_for_file: library_prefixes, prefer_final_fields, curly_braces_in_flow_control_structures, must_be_immutable

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as Get;
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:tdlabs/widgets/search/search_bar.dart';

import '../../../adapters/poc/poc3.dart';
import '../../../models/poc/poc.dart';
import '../screening/test_form.dart';

class TravelPocScreen extends StatefulWidget {
  String? name;
  TravelPocScreen({
    Key? key,
    this.name,
  }) : super(key: key);

  @override
  _TravelPocScreenState createState() => _TravelPocScreenState();
}

class _TravelPocScreenState extends State<TravelPocScreen> {
  int _page = 0;
  int? _pageCount = 1;
  bool _isLoading = false;
  late Future<List<Poc>?> _future;
  List<Poc> _list = [];
  ScrollController _scrollController = ScrollController();
  String _stateCode = '';

  bool ebook = false;
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
              padding: const EdgeInsets.all(8.0),
              child: SearchBarWidget(
                onSubmitted: (value) =>
                    _performSearch(keyword: value, stateCode: _stateCode),
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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 79 / 100,
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
                itemCount: 1,
                itemBuilder: (context, index) {
                  Poc poc = _list[index];
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {});

                        Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          return TestFormScreen(
                            optTestId: (widget.name == "Book PCR")
                                ? 10
                                : (widget.name == "Book PCR + Wechat")
                                    ? 7
                                    : 8,
                            optTestName: widget.name,
                            poc: poc,
                            price: (widget.name == "Book PCR")
                                ? 168
                                : (widget.name == "Book PCR + Wechat")
                                    ? 198
                                    : 599,
                            travel: true,
                          );
                        }));
                      },
                      child: PocAdapter3(
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
    if (keyword != null) if (stateCode != null) {
      _stateCode = stateCode;
    }
    setState(() {
      _list.clear();
      _future = _fetchPocs();
    });
  }

  Future<List<Poc>?> _fetchPocs() async {
    final webService = WebService(context);
    if (!_isLoading && (_page < _pageCount!)) {
      _page++;
      _isLoading = true;
      webService.setEndpoint('screening/pocs').setPage(_page);
      Map<String, String> filter = {};

      filter.addAll({'is_travel_report': '1'});
  
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
