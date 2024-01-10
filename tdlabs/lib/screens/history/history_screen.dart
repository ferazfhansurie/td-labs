// ignore_for_file: must_be_immutable, unnecessary_null_comparison, unused_field, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:tdlabs/adapters/webview/inAppWebViewQiaolz.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/screening/qiaolz.dart';
import 'package:tdlabs/models/screening/test.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/screens/history/transfer_details.dart';
import 'package:tdlabs/screens/medical/screening/self_test_form.dart';
import 'package:tdlabs/screens/medical/screening/selftest_result_confirmation.dart';
import 'package:tdlabs/themes/app_colors.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';
import '../../adapters/test/test.dart';



class HistoryScreen extends StatefulWidget {
  int? tabIndex;
  bool? tab;
  HistoryScreen({Key? key, this.tabIndex, this.tab}) : super(key: key);
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _page = 0;
  int _pageCount = 1;
  bool _isLoading = true;
  Future<List<Test>?>? _future;
  final List<Test> _list = [];
  final ScrollController _scrollController = ScrollController();
  int? _tabIndex = 0;
  String? _tab;
  final String _filterByUser = 'true';
  int? isDismiss;
  DismissDirection direction = DismissDirection.endToStart;
  bool showListTest = false;
  String _lastTest = '';
  String formattedDate = '';

  @override
  void initState() {
    super.initState();
    if (widget.tabIndex != null) {
      setState(() {
        _tabIndex = widget.tabIndex;
      });
    } else {
      _tabIndex = 2;
    }
    _refreshList();
    _future = _fetchTests();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showListTest = true;
      });
    });
  }

  Future<void> _fetchUser() async {
    User? user = await User.fetchOne(context); // get current user
    if (user!.latest_test_at != null) {
      setState(() {
        DateFormat inputFormat = DateFormat("dd, MMMM yyyy");
        _lastTest =
            user.latest_test_at!; // capitalize first letter of user name
        DateTime date = inputFormat.parse(_lastTest);
        DateFormat formatter = DateFormat("dd/MM/yyyy");
        formattedDate = formatter.format(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        key: const Key('history_screen'),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Background-01.png"),
                    fit: BoxFit.fill),
              ),
              padding: EdgeInsets.only(
               top:30,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (widget.tab == null)
                        ? Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Text(
                              "My Surveillance History".tr,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    "My Surveillance History".tr,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer()
                                ],
                              ),
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: _tabBar(),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        width: double.infinity,
                        child: Center(
                          child: Column(
                            children: [
                              _userInfo(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: (widget.tab == null)?MediaQuery.of(context).size.height *
                                    55 /
                                    100:MediaQuery.of(context).size.height *
                                    66 /
                                    100,
                                child: RefreshIndicator(
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  onRefresh: _refreshList,
                                  child: _historyBuilder(),
                                ),
                              ),
                              if (_list.isNotEmpty)
            Material(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: _page > 1 ? () => _changePage(_page - 1) : null,
                  ),
                  Text('Page $_page of $_pageCount'),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: _page < _pageCount ? () => _changePage(_page + 1) : null,
                  ),
                ],
              ),
            ),
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> _refreshList() async {
    _isLoading = true;
    _performSearch(tab: _tabIndex);
    _fetchUser();
  }

  Widget _tabBar() {
    return CupertinoSlidingSegmentedControl(
      backgroundColor: Colors.white,
      thumbColor: CupertinoTheme.of(context).primaryColor,
      // borderColor: Colors.white24,
      children: {
        0: Padding(
          key: const Key('history_tab1'),
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Booking'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: (_tabIndex == 0)
                    ? Colors.white
                    : const Color.fromARGB(255, 104, 104, 104)),
          ),
        ),
        1: Padding(
          key: const Key('history_tab2'),
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Report'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: (_tabIndex == 1)
                    ? Colors.white
                    : const Color.fromARGB(255, 104, 104, 104)),
          ),
        ),
        2: Padding(
          key: const Key('history_tab3'),
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Remark'.tr,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: (_tabIndex == 2)
                    ? Colors.white
                    : const Color.fromARGB(255, 104, 104, 104)),
          ),
        ),
      },
      groupValue: _tabIndex,
      onValueChanged: (value) {
        setState(() {
          _tabIndex = value as int;
          _performSearch(tab: _tabIndex);
        });
      },
    );
  }

  Widget _userInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(2),
            child: Text(
              "Last Tested:".tr,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2),
            child: Text(
              formattedDate,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(2),
              child: GestureDetector(
                  onTap: () {
                    _refreshList();
                  },
                  child: const Icon(
                    Icons.refresh,
                    size: 25,
                  ))),
        ],
      ),
    );
  }

  Widget _historyBuilder() {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if ((_list != null)) {
          return (showListTest)
              ? Scrollbar(
                  key: const Key('history_scroll'),
                  controller: _scrollController,
                  child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        Test test = _list[index];
                        int testId = test.id!.toInt();
                        Qiaolz? qiaolz_test;
                        if (test.report != null) {
                          final parseMap = jsonDecode(test.report.toString())
                              as Map<String, dynamic>;
                          qiaolz_test = Qiaolz.fromJson(parseMap);
                        }

                        return GestureDetector(
                          onTap: () {
                            if (!test.flow_complete! &&
                                test.poc_id == null &&
                                test.tac_code == null) {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return SelfTestForm(
                                  test: test,
                                  test_id: testId,
                                  method: 1,
                                  videoUrl:
                                      '${MainConfig.getUrl()}/api/v1/screening/video/self-test/$testId',
                                  qrCapture: test.qrCode,
                                  optTestId: test.brand_id,
                                  cont: true,
                                  validationType: 1,
                                );
                              })).then((value) {
                                if (value == true) {
                                  _refreshList();
                                }
                              });
                            } else if (test.type == 31) {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return WebViewQiaolzScreen(
                                  url: qiaolz_test!.url!,
                                  title: 'TD Doc',
                                );
                              }));
                            } else if (!test.flow_complete! &&
                                test.tac_code == null &&
                                test.poc_id != null) {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return SelfTestResultConfirmation(
                                  test: test,
                                  test_id: testId,
                                  imageUrl:
                                      '${MainConfig.getUrl()}/screening/image/self-test/$testId',
                                  fromHistory: true,
                                  ai_result: int.parse(test.ai_result!),
                                );
                              })).then((value) {
                                if (value == true) {
                                  _refreshList();
                                }
                              });
                            } else if (test.resultName! == "Appointment Set" &&
                                test.tac_code != null &&
                                test.is_paid == 1 &&
                                test.poc!.id == 3 &&
                                test.imageUrl == null) {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return SelfTestForm(
                                    tac: test.tac_code,
                                    test: test,
                                    method: 0,
                                    test_id: testId,
                                    cont: true,
                                    optTestId: test.brand_id,
                                    validationType: 0);
                              })).then((value) {
                                if (value == true) {
                                  _refreshList();
                                }
                              });
                            } else if (test.resultName! == "Appointment Set" &&
                                test.tac_code != null &&
                                test.is_paid == 1 &&
                                test.poc!.id != 3 &&
                                test.videoUrl == null) {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return SelfTestForm(
                                    videoUrl: test.videoUrl,
                                    tac: test.tac_code,
                                    test: test,
                                    method: 0,
                                    test_id: testId,
                                    cont: true,
                                    optTestId: test.brand_id,
                                    validationType: 1);
                              })).then((value) {
                                if (value == true) {
                                  _refreshList();
                                }
                              });
                            } else {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return TransferDetails(
                                  testID: testId,
                                );
                              }));
                            }
                          },
                          child: TestAdapter(
                            tab: _tabIndex,
                            key: Key("history_tap $index"),
                            test: test,
                            qiaolz_test: qiaolz_test,
                            color: (index % 2 == 0)
                                ? AppColors.oddFill
                                : AppColors.evenFill,
                          ),
                        );
                      }),
                )
              : const SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator()));
        } else {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.bottom -
                    100,
                child: Center(
                  child: Visibility(
                    visible: (snapshot.data != null),
                    replacement: IntrinsicHeight(
                        child: ConnectionError(onRefresh: _refreshList)),
                    child: Text('No result found, pull to refresh.'.tr),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      },
    );
  }

  void _performSearch({int? tab}) {
    // Reset list
    _page = 0;
    _pageCount = 1;
    if (tab != null) _tab = tab.toString();
    setState(() {
      _list.clear();
    });
    _future = _fetchTests();
  }

  Future<List<Test>?> _fetchTests() async {
    final webService = WebService(context);
    if (_page < _pageCount) {
      _page++;
      webService
          .setEndpoint('screening/tests')
          .setExpand('poc, user')
          .setPage(_page);
      Map<String, String> filterUser = {};
   filterUser.addAll({'user_id': _filterByUser});
      if (_tab!.isNotEmpty) {
        filterUser.addAll({'tab': _tab!});
      }
      var response = await webService.setFilter(filterUser).send();
      
      if (response == null) return null;
      if (response.status) {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<Test> tests =
            parseList.map<Test>((json) => Test.fromJson(json)).toList();
        setState(() {
          _list.addAll(tests);
        });
        _pageCount = response.pagination!['pageCount']!;
        print(_pageCount );
      }
    }
    _isLoading = false;

    return _list;
  }

  void _changePage(int newPage) {
    setState(() {
      _page = newPage-1;
      _list.clear();
      _fetchTests();
    });
  }

}
