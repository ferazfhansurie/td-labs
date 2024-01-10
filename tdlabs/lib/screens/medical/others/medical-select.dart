// ignore_for_file: prefer_typing_uninitialized_variables, file_names, must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:tdlabs/config/main.dart';
import 'package:tdlabs/widgets/button/medicalbutton.dart';
import '../screening/steps.dart';
import '../screening/test_select_screen.dart';

class MedicalScreen extends StatefulWidget {
  String? latitude;
  String? longitude;
  String? accessToken;
  MedicalScreen({Key? key, this.latitude, this.longitude,this.accessToken}) : super(key: key);

  @override
  _MedicalScreenState createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  bool? enabledDirectory = false;
  bool? enabledAskDoctor = false;
  bool? enabledBooking = false;
  bool? enabledPeriodTracker = false;
  bool? enabledMedicalLedger = false;
 
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CupertinoPageScaffold(
            child: SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Container(
        child: (Column(children: [
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
                                     Container(
                              height: 30,
                              padding: const EdgeInsets.only(left:20),
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
            SizedBox(width:MediaQuery.of(context).size.width * 25/100 ,),
                                      Container(
                                        alignment: Alignment.center,
                                        height: 175,
                                        child:Column(
                                          children: [
                                            const SizedBox(height: 30,),
                                            SizedBox(
                                             height: 140,
                                              child: Column(
                                                children: [
                                                  Image.asset('assets/images/icons-medical-white-03.png', fit: BoxFit.cover, ),
                                                    Text(
              "Medical".tr,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                               color: Colors.white,
                          fontWeight: FontWeight.w300),
            ),
                                                ],
                                              )),
                                            
                                          ],
                                        ) ,
                                      ),
                                    ],
                                  )),
          Padding(padding: const EdgeInsets.all(5), child: _medicalButton())
        ])),
      ),
    )));
  }

  Widget _medicalButton() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 105,
        crossAxisCount: 3,
        crossAxisSpacing: 5.0,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        int number = index + 1;
        return MedicalButton(
          latitude: widget.latitude,
          longitude: widget.longitude,
          url: (!MainConfig.modeLive)
              ? 'http://dev.tdlabs.co/telecon/register?token=' + widget.accessToken!
              : 'http://cloud.tdlabs.co/telecon/register?token=' + widget.accessToken!,
          home: true,
          index: index,
          image: 'assets/images/icons-colored-0' + number.toString() + '.png',
          image2: 'assets/images/icons-medical-white-0' +number.toString() +'.png',
          label: (index == 0)
              ? 'Directory'.tr
              : (index == 1)
                  ? 'Covid-19 Screening'.tr
                  : (index == 2)
                      ? 'Health Screening'.tr
                      : (index == 3)
                          ? 'Period Tracker'.tr
                          : (index == 4)
                              ? 'E-Booking'.tr
                              : (index == 5)
                                  ? 'Health Ledger'.tr
                                   : (index == 6)
                                  ? 'Wellness Scan'.tr
                                  : ''.tr,
        );
      },
    );
  }


  showPickValidationType(BuildContext context) {
    // set up the AlertDialog
    Widget alert = Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        children: [
          AlertDialog(
            title: Text(
              'Choose Your Validation'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return TestSelectScreen(
                          validationType: 0,
                        );
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'General Validation(Free)'.tr,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return Steps();
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SIMKA(Fees Apply)'.tr,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
