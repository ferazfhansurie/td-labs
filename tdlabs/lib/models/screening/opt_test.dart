// ignore_for_file: body_might_complete_normally_nullable, constant_identifier_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../../utils/web_service.dart';

class OptTest {
  final int? id;
  final String? name;
  final String? description;
  final String? shortDescription;
  final String? image;
  bool? fromNetwork;

  OptTest(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.shortDescription,
      this.fromNetwork});

  factory OptTest.fromJson(Map<String, dynamic> json) {
    return OptTest(
      id: json['id'],
      name: json['name'],
      shortDescription:
          (json['short_description'] != '') ? json['short_description'] : '',
      description: (json['description'] != '') ? json['description'] : '',
      image: (json['image_url'] != null) ? json['image_url'] : '',
      fromNetwork: true,
    );
  }

  // ignore: missing_return
  static Future<List<OptTest>?> fetchSelfTest(BuildContext context) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('screening/brands');

    var response = await webService.send();
    if (response == null) return null;

    if (response.status) {
      var fetchBrand = jsonDecode(response.body.toString());
      List<OptTest> listSelf =
          fetchBrand.map<OptTest>((json) => OptTest.fromJson(json)).toList();
      return listSelf;
    }
  }

  static List<OptTest> fetchPocTest() {
    List<OptTest> optTests = [];

    //Populate real data
    optTests.add(OptTest(
        id: 1,
        name: 'RT-PCR',
        shortDescription: '',
        description: 'Polymerise Chain Reaction',
        image: "assets/images/PCR.jpg",
        fromNetwork: false));
    optTests.add(OptTest(
        id: 3,
        name: 'RTK Antigen',
        shortDescription: '',
        description: 'Lateral Flow Antigen',
        image: 'assets/images/antigen.jpg',
        fromNetwork: false));
    optTests.add(OptTest(
      id: 6,
      name: 'Neutralizing Antibody',
      shortDescription: '',
      description: 'Lateral Flow Antibody',
      image: 'assets/images/antibody.jpg',
      fromNetwork: false,
    ));
    optTests.add(OptTest(
        id: 5,
        name: 'Covid-19 Booster Vaccination',
        shortDescription: '',
        description: '',
        image: 'assets/images/booster_shot.jpg',
        fromNetwork: false));
    
    return optTests;
  }

  static List<OptTest> fetchPocTestWIP() {
    List<OptTest> optTests = [];
    return optTests;
  }

  static const TYPE_PCR = 1;
  static const TYPE_LFD = 2;
  static const TYPE_ANTIGEN = 3;
  static const TYPE_ANTIBODY = 4;
  static const TYPE_BOOSTER = 5;
  static const TYPE_PCR_WECHAT = 7;
  static const TYPE_PCR_AGENT = 8;
  static const TYPE_GENERAL = 10;
  static const TYPE_ANTIBODY_VALIDATION = 11;
  static const TYPE_ANTIGEN_VALIDATION_DEEPTHROATSALIVA = 12;
  static const TYPE_ANTIGEN_VALIDATION_ORALFLUID = 13;
  static const TYPE_ANTIGEN_VALIDATION_NASAL = 14;
  static const TYPE_ANTIGEN_VALIDATION_MIXNASALSALIVA = 15;

  static Map<int, String> typeEnum = {
    TYPE_PCR: 'RT-PCR',
    TYPE_GENERAL: 'General Booking',
    TYPE_LFD: 'LFD',
    TYPE_ANTIGEN: 'RTK Antigen',
    TYPE_ANTIBODY: 'Neutralizing Antibody',
    TYPE_BOOSTER: 'Covid-19 Booster Vaccination',
    TYPE_PCR_WECHAT:'PCR + Wechat',
    TYPE_PCR_AGENT:'PCR + Agent',
    TYPE_ANTIBODY_VALIDATION: 'Antibody Validation',
    TYPE_ANTIGEN_VALIDATION_DEEPTHROATSALIVA: 'RTK Antigen',
    TYPE_ANTIGEN_VALIDATION_ORALFLUID: 'RTK Antigen',
    TYPE_ANTIGEN_VALIDATION_NASAL: 'RTK Antigen',
    TYPE_ANTIGEN_VALIDATION_MIXNASALSALIVA: 'RTK Antigen',
  };

  static Map<int, String> specimenTypeEnum = {
    TYPE_PCR: 'RT-PCR',
    TYPE_LFD: 'LFD',
    TYPE_ANTIGEN: 'RTK Antigen',
    TYPE_ANTIBODY: 'Neutralizing Antibody',
    TYPE_BOOSTER: 'Covid-19 Booster Vaccination',
    TYPE_ANTIBODY_VALIDATION: 'Antibody Validation',
    TYPE_ANTIGEN_VALIDATION_DEEPTHROATSALIVA: 'Deep Throat Saliva',
    TYPE_ANTIGEN_VALIDATION_ORALFLUID: 'Oral Fluid',
    TYPE_ANTIGEN_VALIDATION_NASAL: 'Nasal',
    TYPE_ANTIGEN_VALIDATION_MIXNASALSALIVA: 'Mix Nasal & Saliva',
  };
}
