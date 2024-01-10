// ignore_for_file: must_be_immutable, unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/screening/test.dart';
import 'package:tdlabs/models/user/user.dart';
import 'package:tdlabs/screens/history/transfer_details.dart';
import 'package:tdlabs/screens/medical/screening/self_test_form.dart';
import 'package:tdlabs/screens/medical/screening/selftest_result_confirmation.dart';
import 'package:tdlabs/themes/app_colors.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:tdlabs/widgets/connection_error.dart';

import '../../../adapters/test/test.dart';

class MedicalLedgerScreen extends StatefulWidget {
  const MedicalLedgerScreen({Key? key}) : super(key: key);
  @override
  _MedicalLedgerScreenState createState() => _MedicalLedgerScreenState();
}

class _MedicalLedgerScreenState extends State<MedicalLedgerScreen> {
  int _page = 0;
  int _pageCount = 1;
  // ignore: unused_field
  bool _isLoading = true;
  Future<List<Test>?>? _future;
  final List<Test> _list = [];
  final ScrollController _scrollController = ScrollController();
  int? _tabIndex = 0;
  int? _tabIndex2 = 0;
  String? _tab;
  final String _filterByUser = 'true';
  int? isDismiss;
  DismissDirection direction = DismissDirection.endToStart;
  bool showListTest = false;
  String _lastTest = '';
  @override
  void initState() {
    super.initState();
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
        _lastTest =
            user.latest_test_at!; // capitalize first letter of user name
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          width: double.infinity,
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
                          "Health Ledger".tr,
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
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _tabIndex = 0;
                            });
                          },
                          child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient:  (_tabIndex == 0)
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 150, 150, 150),
                                          Color.fromARGB(255, 150, 150, 150),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  'Bookings'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                        GestureDetector(
                           onTap: () {
                            setState(() {
                              _tabIndex = 1;
                            });
                          },
                          child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: (_tabIndex == 1)
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 150, 150, 150),
                                          Color.fromARGB(255, 150, 150, 150),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  'Reports'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                        GestureDetector(
                           onTap: () {
                            setState(() {
                              _tabIndex = 2;
                            });
                          },
                          child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: (_tabIndex == 2)
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 150, 150, 150),
                                          Color.fromARGB(255, 150, 150, 150),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  'Remarks'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                      ]),
                ),
              ),
              if(_tabIndex ==0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255,223,223,223)
                    ),
                    width: double.infinity,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 70/100,
                      child: Column(
                        children: [
                          Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    'My appointments'.tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
 ),
                                  ),
                                ),
  Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _tabIndex2 = 0;
                            });
                          },
                          child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient:  (_tabIndex2 == 0)
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 150, 150, 150),
                                          Color.fromARGB(255, 150, 150, 150),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  'Upcoming'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                        GestureDetector(
                           onTap: () {
                            setState(() {
                              _tabIndex2 = 1;
                            });
                          },
                          child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: (_tabIndex2 == 1)
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 150, 150, 150),
                                          Color.fromARGB(255, 150, 150, 150),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  'Completed'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                        GestureDetector(
                           onTap: () {
                            setState(() {
                              _tabIndex2 = 2;
                            });
                          },
                          child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: (_tabIndex2 == 2)
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 150, 150, 150),
                                          Color.fromARGB(255, 150, 150, 150),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  'Canceled'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                      ]),
                ),
                ),
                          Flexible(
                            child: RefreshIndicator(
                              color: CupertinoTheme.of(context).primaryColor,
                              onRefresh: _refreshList,
                              child: _bookingBuilder(),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              if(_tabIndex ==1)
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255,223,223,223)
                    ),
                    width: double.infinity,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 75/100,
                      child: Column(
                        children: [
                        
  Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _tabIndex2 = 0;
                            });
                          },
                          child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient:  (_tabIndex2 == 0)
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 150, 150, 150),
                                          Color.fromARGB(255, 150, 150, 150),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  'Pending'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                        GestureDetector(
                           onTap: () {
                            setState(() {
                              _tabIndex2 = 1;
                            });
                          },
                          child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: (_tabIndex2 == 1)
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 150, 150, 150),
                                          Color.fromARGB(255, 150, 150, 150),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  'Active'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                        GestureDetector(
                           onTap: () {
                            setState(() {
                              _tabIndex2 = 2;
                            });
                          },
                          child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: (_tabIndex2 == 2)
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 150, 150, 150),
                                          Color.fromARGB(255, 150, 150, 150),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  'Completed'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                      ]),
                ),
                ),
                          Flexible(
                            child: RefreshIndicator(
                              color: CupertinoTheme.of(context).primaryColor,
                              onRefresh: _refreshList,
                              child: SizedBox(
                                        height:  MediaQuery.of(context).size.height,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                            
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: Column(
                                      children: [
                                        _userInfo() ,
                                        _historyBuilder(),
                                      ],
                                    )),
                                )),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              if(_tabIndex == 2)
                Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255,223,223,223)
                    ),
                    width: double.infinity,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 75/100,
                      child: Column(
                        children: [
                          Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 255, 255, 255)
                    ),
                    width: double.infinity,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 25/100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                             const Padding(
                               padding: EdgeInsets.all(8.0),
                               child: Text('Certified E-Medical Certificate (E-MC)',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Colors.black),),
                             ),
                              const Padding(
                               padding: EdgeInsets.symmetric(horizontal:8.0,vertical: 2),
                               child: Text('Upon completing your consultation, if our doctor finds that you\nare unfit for duty,an E-MC will be issued and provided in-app.\nRefer to the history section to download your E-MC',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 9,
                                                color: Colors.black),),
                             ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(children: const [
                                      Icon(Icons.shield_moon,size:40),
                                      Text('Medical Certificate is issued by a Registered Medical Practioner \nupon performing an appropriate ',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 8,
                                                      color: Colors.black),),
                                    ],),
                                    const SizedBox(height: 10,),
                                     Row(children: [
                                       const Icon(Icons.shield_moon,size:40),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Medical certificate verification can be done via ',
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          fontFamily: 'Montserrat',
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 8,
                                                          color: Colors.black),),
                                                            Text('Medical Certification Validation',
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          fontFamily: 'Montserrat',
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 9,
                                                          color: Colors.blue),),
                                        ],
                                      ),
                                    ],),
                                  ],
                                ),
                              ),
                          
                        ])))),
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: Column(
                              children: [
                                _userInfo(),
                                _remarkBuilder(),
                              ],
                            )),
                         )
]))))
            ],
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

  Widget title() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              "Health Ledger".tr,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer()
          ],
        ),
      ),
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
              _lastTest,
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
   Widget _remarkBuilder() {
    return Flexible(
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if ((_list != null)) {
            return (showListTest)
                ? Scrollbar(
                    controller: _scrollController,
                    child: ListView.builder(
                      shrinkWrap: true,
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          Test test = _list[index];
                          int testId = test.id!.toInt();
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
                                    videoUrl: MainConfig.getUrl() +
                                        '/api/v1/screening/video/self-test/' +
                                        testId.toString(),
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
                              } else if (!test.flow_complete! &&
                                  test.tac_code == null &&
                                  test.poc_id != null) {
                                Navigator.of(context)
                                    .push(CupertinoPageRoute(builder: (context) {
                                  return SelfTestResultConfirmation(
                                    test: test,
                                    test_id: testId,
                                    imageUrl: MainConfig.getUrl() +
                                        '/screening/image/self-test/' +
                                        testId.toString(),
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
                            child: Container(
                              height: 100,
                                color: (index % 2 == 0)
                                  ? AppColors.oddFill
                                  : AppColors.evenFill,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(children: [
                                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: (test.poc != null),
                              replacement: Container(
                                padding: const EdgeInsets.only(top: 2),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                    children: [
                                      Text('Point of Care: '.tr),
                                      Text(
                                        'N/A',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w300,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor),
                                      ),
                                    ],
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(top: 2),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                    children: [
                                      Text('Point of Care: '.tr),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            40 /
                                            100,
                                        constraints: const BoxConstraints(),
                                        child: Text(
                                          (test.poc != null)
                                              ? test.poc!.name!.tr
                                              : '',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w300,
                                              color: CupertinoTheme.of(context).primaryColor),
                                        ),
                                      ),
                                    ],
                                ),
                              ),
                            ),
                         
                          ],
                        ),
                           Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: (test.validated_at != null),
                              replacement: Container(
                                padding: const EdgeInsets.only(top: 2),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                    children: [
                                      Text('Validity: '.tr),
                                      Text(
                                        'N/A',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w300,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor),
                                      ),
                                    ],
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(top: 2),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                    children: [
                                      Text('Validity: '.tr),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            40 /
                                            100,
                                        constraints: const BoxConstraints(),
                                        child: Text(
                                          (test.validated_at != null)
                                                ? DateFormat('dd/MM/yyyy').format(
                                                    test.validated_at!)
                                              : '',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w300,
                                              color: CupertinoTheme.of(context).primaryColor),
                                        ),
                                      ),
                                    ],
                                ),
                              ),
                            ),
                         Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                              gradient: const LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 48, 186, 168),
                                            Color.fromARGB(255, 49, 53, 131),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                          ),
                          child:  Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    'Patient 1'.tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                         )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(top: 2),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                    children: [
                                      Text('Type of Report: '.tr),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            40 /
                                            100,
                                        constraints: const BoxConstraints(),
                                        child: Text('E-MC',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w300,
                                              color: CupertinoTheme.of(context).primaryColor),
                                        ),
                                      ),
                                    ],
                                ),
                              ),
                         
                          ],
                        ),
                                    ]),
                                  ),
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
      ),
    );
  }
 Widget _bookingBuilder() {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if ((_list != null)) {
          return (showListTest)
              ? Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        Test test = _list[index];
                        int testId = test.id!.toInt();
                        return GestureDetector(
                          onTap: () {
                     
                          },
                          child:  Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 255, 255, 255)
                    ),
                    width: double.infinity,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 30/100,
                      child: Column(
                        children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 65,
                                        width: 65,
                                        decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                          borderRadius: BorderRadius.circular(100)
                                        ),
                                        child: const Icon(Icons.medical_information,color: Colors.white,),
                                      ),
                                      Text(test.poc!.name.toString(),
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                        color: Colors.black),),
                                 
                                    ],
                                  ),
                                  Column(children: [
                                   
                                   Container(
                                   
                                    width: 100,
                                    decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 48, 186, 168),
                                          Color.fromARGB(255, 49, 53, 131),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Text('15 May 2023',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),),
                              ),
                                  ),
                                    Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: const [
                                    Text('Monday',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(255, 182, 182, 182)),),
                                             Text(' 11 AM',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(255, 0, 0, 0)),),
                                  ],
                                ),
                              ),
                               Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: const [
                                    Icon(Icons.check_circle_outline,size: 20,color: Colors.green,),
                                    Text('Confirmed',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(255, 182, 182, 182)),),
                                        
                                  ],
                                ),
                              ),
                                  ],)
                                
                                ],),
                              ),
                              const Divider(color: Colors.black,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal:8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Booked for',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          color: Color.fromARGB(255, 179, 179, 179)),),
                                          Text(test.user!.name.toString(),
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black),),
                                        ],
                                      ),
                                         Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Booking ID',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          color: Color.fromARGB(255, 179, 179, 179)),),
                                          Text(test.refNo!,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black),),
                                        ],
                                      ),
                                ],),
                              ),
                               const Divider(color: Colors.black,),
                                Padding(
                                padding: const EdgeInsets.symmetric(horizontal:8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(test.poc!.name!,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          color: Color.fromARGB(255, 179, 179, 179)),),
                                          Text("+"+test.poc!.phoneNo.toString(),
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black),),
                                        ],
                                      ),
                                         Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                        Container(
                                   
                                    width: 65,
                                    decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                               color:Colors.grey,
                                    
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Text('Cancel',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.white),),
                              ),
                                  ),
                                  const SizedBox(width: 5,),
                                  Container(
                                   
                                    width: 85,
                                    decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                               color:Colors.grey,
                                    
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Text('Reschedule',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                            fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),),
                              ),
                                  ),
                                        ],
                                      ),
                                ],),
                              ),
                        ])))),
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

  Widget _historyBuilder() {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if ((_list != null)) {
          return (showListTest)
              ? Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    shrinkWrap: true,
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        Test test = _list[index];
                        int testId = test.id!.toInt();
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
                                  videoUrl: MainConfig.getUrl() +
                                      '/api/v1/screening/video/self-test/' +
                                      testId.toString(),
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
                            } else if (!test.flow_complete! &&
                                test.tac_code == null &&
                                test.poc_id != null) {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return SelfTestResultConfirmation(
                                  test: test,
                                  test_id: testId,
                                  imageUrl: MainConfig.getUrl() +
                                      '/screening/image/self-test/' +
                                      testId.toString(),
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
                            test: test,
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
    if (tab != null) {
      if (tab == 0) {
        _tab = "2";
      } else {
        _tab = "1";
      }
    }
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
      }
    }
    _isLoading = false;
    return _list;
  }
}
