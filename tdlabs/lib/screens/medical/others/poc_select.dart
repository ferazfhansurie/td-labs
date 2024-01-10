// ignore_for_file: library_prefixes, prefer_final_fields

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlabs/models/util/country_state.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:get/get.dart' as Get;
import 'package:tdlabs/themes/app_colors.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'package:tdlabs/widgets/search/search_bar.dart';

import '../../../adapters/poc/poc.dart';

class PocSelectScreen extends StatefulWidget {
  final int? testType;
  final int? mode;
  final int? poc;
  final int? validationType;
  final bool? ebook;
  const PocSelectScreen(
      {Key? key,
      this.testType,
      this.mode,
      this.validationType,
      this.poc,
      this.ebook})
      : super(key: key);

  @override
  _PocSelectScreenState createState() => _PocSelectScreenState();
}

class _PocSelectScreenState extends State<PocSelectScreen> {
  int _page = 0;
  int? _pageCount = 1;
  bool _isLoading = false;
  bool _isLoadingCS = false;
  late Future<List<Poc>?> _future;
  List<Poc> _list = [];
  List<CountryState> _csList = [];
  ScrollController? _scrollController;
  int? _pocId;
  int _pickerIndex = 0;
  String _stateCode = '';
  String _stateName = 'All';
  String _search = '';
  bool ebook = false;
  @override
  void initState() {
    super.initState();
    _pocId = widget.poc;
    if (widget.ebook != null) {
      ebook = widget.ebook!;
    }
    _fetchCS(); // get list of state
    _future = _fetchPocs();
    _scrollController = ScrollController(initialScrollOffset: 5);
    _scrollController!.addListener(() {
      if (_scrollController!.offset >=
              (_scrollController!.position.maxScrollExtent - 500) &&
          !_scrollController!.position.outOfRange) {
        _future = _fetchPocs();
      }
    });
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Background-02.png"),
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
            _statePicker(),
            SearchBarWidget(
              onSubmitted: (value) =>_performSearch(keyword: value, stateCode: _stateCode),
            ),
            const Divider(color: CupertinoColors.separator, height: 1),
            _pocBuilder()
          ],
        ),
      ),
    );
  }

  _statePicker() {
    return GestureDetector(
      onTap: _showStatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 6.0),
          color: CupertinoTheme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                CupertinoIcons.chevron_down_square,
                color: Colors.white,
              ),
              RichText(
                  text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'States: '.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300),
                  ),
                  TextSpan(
                    text: _stateName,
                  ),
                ],
              )),
              const Opacity(
                opacity: 0.0,
                child: Icon(CupertinoIcons.down_arrow),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _pocBuilder() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 70 / 100,
      child: RefreshIndicator(
        onRefresh: _refreshList,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if ((snapshot.data != null)) {
              return ListView.builder(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: (snapshot.data != null) ? _list.length : 0,
                itemBuilder: (context, index) {
                  Poc poc = _list[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _pocId = poc.id;
                      });
                      Navigator.pop(context, poc);
                    },
                    child: PocAdapter(
                      ebook: ebook,
                      poc: poc,
                      color: (index % 2 == 0)
                          ? AppColors.oddFill
                          : AppColors.evenFill,
                      active: (poc.id == _pocId),
                    ),
                  );
                },
              );
            } else {
              if (snapshot.connectionState == ConnectionState.done) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height -MediaQuery.of(context).padding.top -44,
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
    if (keyword != null) _search = keyword;
    if (stateCode != null) _stateCode = stateCode;
    setState(() {
      _list.clear();
    });
    _future = _fetchPocs();
  }

  Future<List<Poc>?> _fetchPocs() async {
    final webService = WebService(context);
    if (!_isLoading && (_page < _pageCount!)) {
      _page++;
      _isLoading = true;
      webService.setEndpoint('screening/pocs').setPage(_page);
      Map<String, String> filter = {};
      if (widget.validationType == 0) {
        filter.addAll({'name': "General Validation"});
        filter.addAll({'test_type': widget.testType.toString()});
        filter.addAll({'mode': widget.mode.toString()});
      } else {
        filter.addAll({'test_type': widget.testType.toString()});
        filter.addAll({'mode': widget.mode.toString()});
      }
      if (_search.isNotEmpty) {
        filter.addAll({'search': _search});
      }
      if (_stateCode.isNotEmpty) {
        filter.addAll({'state_code': _stateCode});
      }
      var response = await webService.setFilter(filter).send();
      if (response == null) return null;
      if (response.status) {
        final parseList =jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<Poc> pocs =parseList.map<Poc>((json) => Poc.fromJson(json)).toList();
        if (widget.validationType == 0) {
          pocs.removeWhere((element) => element.reportType == 2);
        } else {
          pocs.removeWhere((element) => element.reportType == 1);
        }
        setState(() {
          _list.addAll(pocs);
        });
        _pageCount = response.pagination!['pageCount'];
      }
    }
    _isLoading = false;
    return _list;
  }

Future<List<CountryState>?> _fetchCS() async {
  _csList.clear();
  final webService = WebService(context);
  if (!_isLoadingCS) {
    setState(() {
      _isLoadingCS = true;
    });
    try {
      webService.setEndpoint('option/list/state');
      var response = await webService.send();
      if (response != null && response.status) {
        final parseList2 = jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<CountryState> states = parseList2.map<CountryState>((json) => CountryState.fromJson(json)).toList();
        _csList.addAll(states);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    setState(() {
      _isLoadingCS = false;
    });
  }
  return _csList;
}

  _showStatePicker() {
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
                    child: Text(
                      'Confirm'.tr,
                      style: TextStyle(
                          color: CupertinoTheme.of(context).primaryColor,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300),
                    ),
                    onPressed: () {
                      setState(() {
                        _stateCode = _csList[_pickerIndex].code;
                        _stateName = _csList[_pickerIndex].name;
                      });
                      _performSearch(keyword: _search, stateCode: _stateCode);
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
                  for (var state in _csList)
                    Text(
                      state.name,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300),
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
