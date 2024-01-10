// ignore_for_file: prefer_final_fields, must_be_immutable, avoid_unnecessary_containers, unnecessary_null_comparison, curly_braces_in_flow_control_structures, non_constant_identifier_names, unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:tdlabs/models/poc/poc.dart';
import 'package:tdlabs/models/time_session.dart';
import 'package:tdlabs/models/user/user-dependant.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:get/get.dart';
import 'package:transparent_image/transparent_image.dart';

class ConsultFormScreen extends StatefulWidget {
  Poc? poc;
  String? type;
  ConsultFormScreen({
    Key? key,
    this.poc,
    this.type,
  }) : super(key: key);
  @override
  _ConsultFormScreenState createState() => _ConsultFormScreenState();
}

class _ConsultFormScreenState extends State<ConsultFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  late Poc _poc;
  int? _optTestId;
  NumberFormat _formatter = NumberFormat(',##0.00');
  bool _isLoading = false;
  List<TimeSession> _list = [];
  int _pickerIndex = 0;
  int _pickerIndex2 = 0;
  int? _sessionId;
  String _sessionName = '';
  int testMode = 0;
  String? testModeName;
  DateTime? _selectedDate;
  String _selectedText = '';
  String dependName = "";
  List<UserDependant> _udList = [];
  bool depend = false;
  List<dynamic>? _dependantList;
  int dependant_id = 0;
  int _tabIndex = 0;
  int _tabIndex2 = 0;
  DateTime selectedDate = DateTime.now();
  final remarkController = TextEditingController();
  @override
  void initState() {
    _poc = Poc();
    super.initState();
    _fetchTS();
    testModeName = widget.type;
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _poc = widget.poc!;
    _optTestId = 10;
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
         
        ),
        child: Stack(
          children: [
            Container(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
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
                                width: MediaQuery.of(context).size.width *19 /100,
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: 75,
                                width: 190,
                                child: Text(
                                  widget.poc!.name!,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: (widget.poc!.image_url == null)
                            ? Container(
                                color: const Color.fromARGB(255, 224, 224, 224),
                                height: 100,
                                width: 100,
                                child: Image.asset(
                                  'assets/images/icons-colored-01.png',
                                  fit: BoxFit.scaleDown,
                                ))
                            : SizedBox(
                                height: 100,
                                width: 100,
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: widget.poc!.image_url!,
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.grey, size: 40),
                          Text(
                            widget.poc!.name!,
                            maxLines: 1,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (_tabIndex != 4)
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              gradient: (_tabIndex == 0)
                                                  ? const LinearGradient(
                                                      colors: [
                                                        Color.fromARGB(
                                                            255, 48, 186, 168),
                                                        Color.fromARGB(
                                                            255, 49, 53, 131),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    )
                                                  : const LinearGradient(
                                                      colors: [
                                                        Color.fromARGB(
                                                            255, 150, 150, 150),
                                                        Color.fromARGB(
                                                            255, 150, 150, 150),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text(
                                                'SERVICES'.tr,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white),
                                              ),
                                            )),
                                      ),
                                      const SizedBox(
                                        width: 5,
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
                                              borderRadius:BorderRadius.circular(100),
                                              gradient: (_tabIndex == 1)
                                                  ? const LinearGradient(
                                                      colors: [
                                                        Color.fromARGB( 255, 48, 186, 168),
                                                        Color.fromARGB(255, 49, 53, 131),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:Alignment.bottomRight,
                                                    )
                                                  : const LinearGradient(
                                                      colors: [
                                                        Color.fromARGB(255, 150, 150, 150),
                                                        Color.fromARGB(255, 150, 150, 150),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:Alignment.bottomRight,
                                                    ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text(
                                                'HOURS'.tr,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white),
                                              ),
                                            )),
                                      ),
                                      const SizedBox(
                                        width: 5,
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
                                              borderRadius:BorderRadius.circular(100),
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
                                                      end:Alignment.bottomRight,
                                                    ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text(
                                                'PHOTOS'.tr,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                  if (_tabIndex == 0)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 10),
                                      child: Container(
                                          height: 250,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            color: const Color.fromARGB(255, 201, 201, 201),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: const [
                                                Text(
                                                  "Services/Procedures",
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      fontWeight:FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  if (_tabIndex == 1)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 10),
                                      child: Container(
                                          height: 250,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:BorderRadius.circular(30),
                                            color: const Color.fromARGB(255, 201, 201, 201),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Column(
                                              crossAxisAlignment:CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: const [
                                                Text(
                                                  "Opening Hours",
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  if (_tabIndex == 2)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: SizedBox(
                                        height: 110,
                                        child: ListView.builder(
                                            itemCount: 3,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:const EdgeInsets.all(8.0),
                                                child: ClipRRect(
                                                  borderRadius:BorderRadius.circular(8),
                                                  child: (widget.poc!.image_url ==
                                                          null)
                                                      ? Container(
                                                          color: const Color.fromARGB(255,224,224,224),
                                                          height: 200,
                                                          width: 140,
                                                          child: Image.asset(
                                                            'assets/images/icons-colored-01.png',
                                                            fit: BoxFit.scaleDown,
                                                          ))
                                                      : FadeInImage
                                                          .memoryNetwork(
                                                          placeholder:kTransparentImage,
                                                          image: widget.poc!.image_url!,
                                                          fit: BoxFit.scaleDown,
                                                        ),
                                                ),
                                              );
                                            }),
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _tabIndex = 4;
                                      });
                                    },
                                    child: Container(
                                        width: 200,
                                        decoration: BoxDecoration(
                                            borderRadius:BorderRadius.circular(100),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color.fromARGB(255, 48, 186, 168),
                                                Color.fromARGB(255, 49, 53, 131),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            'CHECK AVAILABILITY'.tr,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                        )),
                                  ),
                                ],
                              )
                            : Column(children: [
                                const Text(
                                  "Dates Available",
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  height: 380,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      children: [
                                        CalendarCarousel(
                                          selectedDateTime: selectedDate,
                                          iconColor: Colors.black,
                                          headerTextStyle: const TextStyle(
                                              color:Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 18),
                                          weekDayFormat: WeekdayFormat.narrow,
                                          weekdayTextStyle: const TextStyle(
                                              color:Color.fromARGB(255, 2, 2, 2)),
                                          onDayPressed: (date, events) {
                                            setState(() {
                                                 selectedDate = date;
                                            });
                                          },
                                          weekendTextStyle: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          thisMonthDayBorderColor:
                                              const Color.fromARGB(255, 0, 0, 0),
                                          weekFormat: false,
                                          height: 350.0,
                                          showIconBehindDayText: false,
                                          customGridViewPhysics:
                                              const NeverScrollableScrollPhysics(),
                                          markedDateShowIcon: true,
                                          selectedDayTextStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          selectedDayButtonColor: const Color.fromARGB(255, 49, 42, 130),
                                          todayTextStyle: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          todayButtonColor: Colors.transparent,
                                          todayBorderColor:const Color.fromARGB(255, 49, 42, 130),
                                          markedDateMoreShowTotal: true,
                                        ),
                                        Row(
                                          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _tabIndex2 = 0;
                                                });
                                              },
                                              child: Container(
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:BorderRadius.circular(8),
                                                    gradient: (_tabIndex2 == 0)
                                                        ? const LinearGradient(
                                                            colors: [
                                                              Color.fromARGB(
                                                                  255,
                                                                  48,
                                                                  186,
                                                                  168),
                                                              Color.fromARGB(
                                                                  255,
                                                                  49,
                                                                  53,
                                                                  131),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          )
                                                        : const LinearGradient(
                                                            colors: [
                                                              Colors
                                                                  .transparent,
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: Text(
                                                      '9-10'.tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: (_tabIndex2 ==
                                                                  0)
                                                              ? Colors.white
                                                              : Colors.black),
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
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    gradient: (_tabIndex2 == 1)
                                                        ? const LinearGradient(
                                                            colors: [
                                                              Color.fromARGB(
                                                                  255,
                                                                  48,
                                                                  186,
                                                                  168),
                                                              Color.fromARGB(
                                                                  255,
                                                                  49,
                                                                  53,
                                                                  131),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          )
                                                        : const LinearGradient(
                                                            colors: [
                                                              Colors
                                                                  .transparent,
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: Text(
                                                      '11-12'.tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: (_tabIndex2 ==
                                                                  1)
                                                              ? Colors.white
                                                              : Colors.black),
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
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    gradient: (_tabIndex2 == 2)
                                                        ? const LinearGradient(
                                                            colors: [
                                                              Color.fromARGB(
                                                                  255,
                                                                  48,
                                                                  186,
                                                                  168),
                                                              Color.fromARGB(
                                                                  255,
                                                                  49,
                                                                  53,
                                                                  131),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          )
                                                        : const LinearGradient(
                                                            colors: [
                                                              Colors
                                                                  .transparent,
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: Text(
                                                      '13-14'.tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: (_tabIndex2 ==
                                                                  2)
                                                              ? Colors.white
                                                              : Colors.black),
                                                    ),
                                                  )),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _tabIndex2 = 3;
                                                });
                                              },
                                              child: Container(
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    gradient: (_tabIndex2 == 3)
                                                        ? const LinearGradient(
                                                            colors: [
                                                              Color.fromARGB(
                                                                  255,
                                                                  48,
                                                                  186,
                                                                  168),
                                                              Color.fromARGB(
                                                                  255,
                                                                  49,
                                                                  53,
                                                                  131),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          )
                                                        : const LinearGradient(
                                                            colors: [
                                                              Colors
                                                                  .transparent,
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: Text(
                                                      '15-16'.tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: (_tabIndex2 ==
                                                                  3)
                                                              ? Colors.white
                                                              : Colors.black),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _tabIndex = 4;
                                    });
                                  },
                                  child: Container(
                                      width: 200,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color.fromARGB(255, 48, 186, 168),
                                              Color.fromARGB(255, 49, 53, 131),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          'BOOK APPOINTMENT'.tr,
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }







  // list of time session
  Future<List<TimeSession>?> _fetchTS() async {
    final webService = WebService(context);
    if (!_isLoading) {
      _isLoading = true;
      webService.setEndpoint('option/list/time');
      var response = await webService.send();
      if (response == null) return null;
      if (response.status) {
        final parseList =
            jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
        List<TimeSession> states = parseList
            .map<TimeSession>((json) => TimeSession.fromJson(json))
            .toList();
        setState(() {
          _list.addAll(states);
        });
      }
    }
    _isLoading = false;
    return _list;
  }
}

class ListItem {
  int value;
  String name;
  ListItem(this.value, this.name);
}
