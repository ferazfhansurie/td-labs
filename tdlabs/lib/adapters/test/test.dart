// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tdlabs/adapters/util/pdf_view.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/models/screening/qiaolz.dart';
import '../../models/screening/opt_test.dart';
import '../../models/screening/test.dart';
// ignore: library_prefixes
import 'package:get/get.dart' as Get;

class TestAdapter extends StatefulWidget {
  final Test? test;
  final Color? color;
  final int? tab;
  Qiaolz? qiaolz_test;
   TestAdapter({Key? key, this.test, this.color, this.tab,this.qiaolz_test})
      : super(key: key);

  @override
  _TestAdapterState createState() => _TestAdapterState();
}

class _TestAdapterState extends State<TestAdapter> {
  Widget? _resultWidget;
  Widget? _selfTest;
  Widget? completeAI;
  Widget? confirmation;
  String? reportName = "";
  List<String> modeList = ['Walk-In', 'Drive-Thru'];
  String _type = '';
  String _testPdf = '';
  @override
  void initState() {
    assignUrl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.test!.poc_id != null) {
      if (widget.test!.type == 31) {
        reportName = "TD Doc";
      } else if (widget.test!.is_e_report == 1) {
        reportName = "E Report";
      } else if (widget.test!.is_general_report == 1) {
        reportName = "General Report";
      } else if (widget.test!.type! < 10) {
        reportName = "SIMKA Report";
      } else {
        reportName = "E-Book Report";
      }
    }
    if (OptTest.typeEnum.containsKey(widget.test!.type)) {
      _type = OptTest.typeEnum[widget.test!.type!]!;
    }

    Color color = widget.color!;

    if (OptTest.typeEnum.containsKey(widget.test!.type)) {}

    _selfTest = Card(
      color: CupertinoTheme.of(context).primaryColor,
      child: Container(
        alignment: Alignment.center,
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
        child: Text(
          'Self Test'.tr,
          style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
              color: Colors.white,
              fontSize: 10),
        ),
      ),
    );

    completeAI = Container(
      alignment: Alignment.center,
      child: Card(
        color: Colors.red,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
          child: Text(
            'Need Confirmation'.tr,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontSize: 9),
          ),
        ),
      ),
    );
    confirmation = Container(
      alignment: Alignment.center,
      child: Card(
        color: Colors.red,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
          child: Text(
            (widget.test!.videoUrl == null &&
                    widget.test!.is_paid == 1 &&
                    reportName == "SIMKA Report")
                ? 'Pending Video'.tr
                : "Pending Submission",
            style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontSize: 9),
          ),
        ),
      ),
    );

    //Result Widget Default
    String result = '';
    Color? resultColor;
    String name = widget.test!.user!.name![0].toUpperCase() +
        widget.test!.user!.name!.substring(1);
    switch (widget.test!.resultName) {
      case 'Completed':
        result = widget.test!.resultName!;
        resultColor = CupertinoColors.activeGreen;
        break;
      case 'Pending':
        result = widget.test!.resultName!;
        resultColor = Colors.amber.shade700;
        break;
      case 'Pending Submission':
        result = widget.test!.resultName!.tr;
        resultColor = Colors.amber.shade700;
        break;
      case 'Appointment Set':
        var remark = "";
        if (widget.test!.other_remark != null) {
          remark = widget.test!.other_remark!;
        }

        result = (widget.test!.type! < 10)
            ? widget.test!.resultName!.tr
            : (remark == "")
                ? 'Verifying'.tr
                : "Active";
        resultColor = Colors.blue.shade700;
        break;
      case 'Negative':
        result = widget.test!.resultName!.tr;
        resultColor = CupertinoColors.activeGreen;
        break;
      case 'Positive':
        result = widget.test!.resultName!.tr;
        resultColor = CupertinoColors.destructiveRed;
        break;
      case '':
        result = 'Invalid';
        resultColor = Colors.blueGrey.shade700;
        break;
      default:
    }

    _resultWidget = Visibility(
      visible: (widget.test!.resultName != null),
      replacement: Container(),
      child: Card(
        color: resultColor,
        child: Container(
          width: 70,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          child: Text(
            result.tr,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontSize: 10),
          ),
        ),
      ),
    );
    return (widget.tab == 0)
        ? Container(
            color: color,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: (widget.test!.flow_complete == false ||
                                widget.test!.imageUrl == null &&
                                    widget.test!.type! > 10 &&
                                    widget.test!.type! <= 20),
                            child: Row(
                              children: [
                                completeAI!,
                                confirmation!,
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(widget.test!.refNo!,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w300,
                                    fontSize: 8,
                                    color: CupertinoColors.secondaryLabel)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: (widget.test!.poc != null),
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
                                      (widget.test!.poc != null)
                                          ? widget.test!.poc!.name!.tr
                                          : '',
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _resultWidget!,
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: (widget.test!.appointmentAt != null),
                            replacement: Container(
                              padding: const EdgeInsets.only(top: 2),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text('Submitted date: '.tr),
                                  Text(
                                    widget.test!.createdAtText!,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor),
                                  ),
                                  
                                ]    
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(top: 4),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text('Appointment Date: '.tr),
                                  Text(
                                    (widget.test!.appointmentAt != null)
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(widget.test!.appointmentAt!)
                                        : '',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                          
                          Visibility(
                              visible: (widget.test!.type! > 10),
                              replacement: Container(),
                              child: _selfTest!),
                        ],
                      ),
                      
                      Visibility(
                        visible: (widget.test!.timeSession != null),
                        replacement: Container(
                          padding: const EdgeInsets.only(top: 6),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Validated date: '.tr,
                                  ),
                                  (widget.test!.validated_at != null)
                                      ? Text(
                                          (widget.test!.validated_at != null)
                                              ? DateFormat('dd/MM/yyyy').format(
                                                  widget.test!.validated_at!)
                                              : '',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w300,
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor),
                                        )
                                      : const Text(
                                          'N/A',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w300,
                                              color: Colors.red),
                                        ),
                                ],
                              ),
                              Flexible(
                                child: Card(
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 70,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1, horizontal: 5),
                                    child: Text(
                                      (widget.test!.dependant_id != null &&
                                              widget.test!.dependant_name !=
                                                  null)
                                          ? widget.test!.dependant_name!
                                          : name,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                          fontSize: 10),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(top: 6),
                          alignment: Alignment.centerLeft,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (widget.test!.type! < 10),
                        replacement: Container(
                          padding: const EdgeInsets.only(top: 6),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(children: [
                                Text(
                                  'Type Of Report: '.tr,
                                ),
                                Text(
                                  reportName!.tr,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w300,
                                      color: CupertinoTheme.of(context)
                                          .primaryColor),
                                ),
                              ]),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(top: 6),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                'Appointment By: '.tr,
                              ),
                              Text(
                                (widget.test!.type! < 10)
                                    ? modeList[widget.test!.mode!]
                                    : 'null',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w300,
                                    color: CupertinoTheme.of(context)
                                        .primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (widget.test!.type! < 10),
                        child: Container(
                          padding: const EdgeInsets.only(top: 6),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(children: [
                                Text(
                                  'Service Type: '.tr,
                                ),
                                Text(
                                  _type,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w300,
                                      color: CupertinoTheme.of(context)
                                          .primaryColor),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: CupertinoColors.separator, height: 1),
              ],
            ),
          )
        : (widget.tab == 1)
            ? Container(
                color: color,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Visibility(
                                visible: (widget.test!.flow_complete == false ||
                                    widget.test!.imageUrl == null &&
                                        widget.test!.type! > 10 &&
                                        widget.test!.type! <= 20),
                                child: Row(
                                  children: [
                                    completeAI!,
                                    confirmation!,
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Text(widget.test!.refNo!,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        fontSize: 8,
                                        color: CupertinoColors.secondaryLabel)),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: (widget.test!.poc != null),
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                40 /
                                                100,
                                        constraints: const BoxConstraints(),
                                        child: Text(
                                          (widget.test!.poc != null)
                                              ? widget.test!.poc!.name!.tr
                                              : '',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w300,
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _resultWidget!,
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: (widget.test!.appointmentAt != null),
                                replacement: Container(
                                  padding: const EdgeInsets.only(top: 2),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text('Submitted date: '.tr),
                                      Text(
                                        widget.test!.createdAtText!,
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
                                  padding: const EdgeInsets.only(top: 4),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text('Appointment Date: '.tr),
                                      Text(
                                        (widget.test!.appointmentAt != null)
                                            ? DateFormat('dd/MM/yyyy').format(
                                                widget.test!.appointmentAt!)
                                            : '',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w300,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 45,),
                              if (widget.test!.type == 31) 
                                  Card(
        color: CupertinoTheme.of(context).primaryColor,
        child: Container(
          width: 70,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          child: const Text(
            'TD Doc',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontSize: 10),
          ),
        ),
      )      ,
                              Visibility(
                                  visible: (widget.test!.type! > 10 &&
                                      widget.test!.type! != 31),
                                  replacement: Container(),
                                  child: _selfTest!),
                            ],
                          ),
                           if(widget.test!.type != 31)
                          Visibility(
                            visible: (widget.test!.timeSession != null),
                            replacement: Container(
                              padding: const EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Validated date: '.tr,
                                      ),
                                      (widget.test!.validated_at != null)
                                          ? Text(
                                              (widget.test!.validated_at !=
                                                      null)
                                                  ? DateFormat('dd/MM/yyyy')
                                                      .format(widget
                                                          .test!.validated_at!)
                                                  : '',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w300,
                                                  color:
                                                      CupertinoTheme.of(context)
                                                          .primaryColor),
                                            )
                                          : const Text(
                                              'N/A',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.red),
                                            ),
                                    ],
                                  ),
                                  Flexible(
                                    child: Card(
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 70,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 5),
                                        child: Text(
                                          (widget.test!.dependant_id != null &&
                                                  widget.test!.dependant_name !=
                                                      null)
                                              ? widget.test!.dependant_name!
                                              : name,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: (widget.test!.type! < 10),
                            replacement: Container(
                              padding: const EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(children: [
                                    Text(
                                      'Type Of Report: '.tr,
                                    ),
                                    Text(
                                      reportName!.tr,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'Appointment By: '.tr,
                                  ),
                                  Text(
                                    (widget.test!.type! < 10)
                                        ? modeList[widget.test!.mode!]
                                        : 'null',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.qiaolz_test != null)
                           Visibility(
                            visible: (widget.qiaolz_test != null),
                            replacement: Container(),
                            child: Container(
                              padding: const EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'Total Health Score: '.tr,
                                  ),
                                  Text(
                                   widget.qiaolz_test!.score2.toString(),
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (widget.qiaolz_test != null)
                          Visibility(
                            visible: (widget.qiaolz_test != null),
                            replacement: Container(),
                            child: Container(
                              padding: const EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'Immunity Score: '.tr,
                                  ),
                                  Text(
                                   widget.qiaolz_test!.score1.toString(),
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                               
                          Visibility(
                            visible: (widget.test!.type! < 10),
                            child: Container(
                              padding: const EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(children: [
                                    Text(
                                      'Service Type: '.tr,
                                    ),
                                    Text(
                                      _type,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: CupertinoColors.separator, height: 1),
                  ],
                ),
              )
            : Container(
                color: color,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Visibility(
                                visible: (widget.test!.flow_complete == false ||
                                    widget.test!.imageUrl == null &&
                                        widget.test!.type! > 10 &&
                                        widget.test!.type! <= 20),
                                child: Row(
                                  children: [
                                    completeAI!,
                                    confirmation!,
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Text(widget.test!.refNo!,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w300,
                                        fontSize: 8,
                                        color: CupertinoColors.secondaryLabel)),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: (widget.test!.poc != null),
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                40 /
                                                100,
                                        constraints: const BoxConstraints(),
                                        child: Text(
                                          (widget.test!.poc != null)
                                              ? widget.test!.poc!.name!.tr
                                              : '',
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w300,
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _resultWidget!,
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: (widget.test!.appointmentAt != null),
                                replacement: Container(
                                  padding: const EdgeInsets.only(top: 2),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text('Submitted date: '.tr),
                                      Text(
                                        widget.test!.createdAtText!,
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
                                  padding: const EdgeInsets.only(top: 4),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text('Appointment Date: '.tr),
                                      Text(
                                        (widget.test!.appointmentAt != null)
                                            ? DateFormat('dd/MM/yyyy').format(
                                                widget.test!.appointmentAt!)
                                            : '',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w300,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                         
                          Visibility(
                            visible: (widget.test!.timeSession != null),
                            replacement: Container(
                              padding: const EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Validated date: '.tr,
                                      ),
                                      (widget.test!.validated_at != null)
                                          ? Text(
                                              (widget.test!.validated_at !=
                                                      null)
                                                  ? DateFormat('dd/MM/yyyy')
                                                      .format(widget
                                                          .test!.validated_at!)
                                                  : '',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w300,
                                                  color:
                                                      CupertinoTheme.of(context)
                                                          .primaryColor),
                                            )
                                          : const Text(
                                              'N/A',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.red),
                                            ),
                                    ],
                                  ),
                                  Flexible(
                                    child: Card(
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 70,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 5),
                                        child: Text(
                                          (widget.test!.dependant_id != null &&
                                                  widget.test!.dependant_name !=
                                                      null)
                                              ? widget.test!.dependant_name!
                                              : name,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(top: 6),
                              alignment: Alignment.centerLeft,
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return PDFView(
                                  pdfUrl: _testPdf,
                                  testId: widget.test!.id.toString(),
                                );
                              }));
                            },
                            child: Visibility(
                              visible: (widget.test!.type! < 10),
                              replacement: Container(
                                padding: const EdgeInsets.only(top: 6),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(children: [
                                      Text(
                                        'PDF: '.tr,
                                      ),
                                      Text(
                                        reportName!.tr,
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w300,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(top: 6),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Appointment By: '.tr,
                                    ),
                                    Text(
                                      (widget.test!.type! < 10)
                                          ? modeList[widget.test!.mode!]
                                          : 'null',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w300,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: CupertinoColors.separator, height: 1),
                  ],
                ),
              );
  }

  void assignUrl() {
    setState(() {
      _testPdf = (widget.test!.type! <= 10)
          ? '${MainConfig.appUrl}/screening/file/test/${widget.test!.id}'
          : '${MainConfig.appUrl}/screening/file/self-test/${widget.test!.id}';
    });
  }
}
