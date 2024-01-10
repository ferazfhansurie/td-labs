// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import 'dart:convert';
import 'package:get/get.dart' as Get;

import '../../adapters/util/link.dart';

class LinkScreen extends StatefulWidget {
  const LinkScreen({Key? key}) : super(key: key);
  @override
  _LinkScreenState createState() => _LinkScreenState();
}
class _LinkScreenState extends State<LinkScreen> {
  List<dynamic> _companyList = [];
  bool inviteAvailable = false;
  Future<List<dynamic>?>? _future;
  ScrollController? _scrollController;
  //TAB
  int? _tabIndex = 0;
  bool _isLoading = false;
  int _page = 0;
  int _pageCount = 1;
  String? _tab;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    refreshList();
  }
  showAlertDialog(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = CupertinoButton(
      onPressed: () {},
      child: Container(),
    );
    // ignore: deprecated_member_use
    Widget continueButton = CupertinoButton(
      child: Text('Continue'.tr),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        'Info'.tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      content: Text('Link-info'.tr),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/Background-01.png"),
                fit: BoxFit.fill),
          ),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 140.0),
                    child: Text(
                      "Link Me".tr,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                child: _tabBar(),
              ),
              RefreshIndicator(
                onRefresh: refreshList,
                child: SizedBox(
                    height: MediaQuery.of(context).size.height - 130,
                    child: _linkBuilder()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBar() {
    return CupertinoSlidingSegmentedControl(
      backgroundColor: Colors.white,
      thumbColor: CupertinoTheme.of(context).primaryColor,
      children: {
        0: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Pending'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: (_tabIndex == 0)
                    ? Colors.white
                    : const Color.fromARGB(255, 88, 88, 88)),
          ),
        ),
        1: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Linked'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: (_tabIndex == 1)
                    ? Colors.white
                    : const Color.fromARGB(255, 88, 88, 88)),
          ),
        ),
      },
      groupValue: _tabIndex,
      onValueChanged: (value) {
        if (mounted) {
          setState(() {
            _tabIndex = value as int?;
            refreshList();
          });
        }
      },
    );
  }

  Widget _linkBuilder() {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if ((snapshot.data != null) && (_companyList.isNotEmpty)) {
            return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: (snapshot.data != null) ? _companyList.length : 0,
                itemBuilder: (context, index) {
                  return LinkAdapter(
                    companyName: _companyList[index]['company_name'],
                    id: _companyList[index]['id'],
                    status: _companyList[index]['status'],
                    currentTab: _tabIndex,
                  );
                });
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height -MediaQuery.of(context).padding.bottom -50,
                  child: Center(
                    child: Visibility(
                      visible: (snapshot.data != null),
                      replacement: IntrinsicHeight(
                          child: ConnectionError(onRefresh: refreshList)),
                      child: Text(
                        'Empty list, pull to refresh.'.tr,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          }
        });
  }

  Future<void> refreshList() async {
    setState(() {
      _companyList.clear();
    });
    _performSearch(tab: _tabIndex);
  }

  void _performSearch({int? tab}) {
    // Reset list
    _page = 0;
    _pageCount = 1;
    _isLoading = false;

    if (tab == 0) {
      _tab = tab.toString();
      _future = _fetchCompanyInvites();
    }
    if (tab == 1) {
      _tab = tab.toString();
      _future = _fetchCompanyLinked();
    }
  }

  Future<List<dynamic>?> _fetchCompanyLinked() async {
    final webService = WebService(context);

    if (!_isLoading && (_page < _pageCount)) {
      _page++;
      _isLoading = true;
      webService.setMethod('GET').setEndpoint('company/invites');
      Map<String, String> filterStatus = {};
      filterStatus.addAll({'status': '1'});
      if (_tab!.isNotEmpty) {
        filterStatus.addAll({'tab': _tab!});
      }
      var response = await webService.setFilter(filterStatus).send();

      if (response == null) return null;

      if (response.status) {
        _companyList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      }
    }
    _isLoading = false;
    return _companyList;
  }

  Future<List<dynamic>?> _fetchCompanyInvites() async {
    final webService = WebService(context);

    if (!_isLoading && (_page < _pageCount)) {
      _page++;
      _isLoading = true;
      webService.setMethod('GET').setEndpoint('company/invites');
      Map<String, String> filterStatus = {};
      filterStatus.addAll({'status': '0'});
      if (_tab!.isNotEmpty) {
        filterStatus.addAll({'tab': _tab!});
      }
      var response = await webService.setFilter(filterStatus).send();
      if (response == null) return null;

      if (response.status) {
        _companyList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      }
    }
    _isLoading = false;
    return _companyList;
  }
}
