import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../../utils/web_service.dart';

class BioData {
  String? height;
  String? weight;
  String? bmi;
  int? steps;
  String? calories;
  int? heartrate;

  BioData(
      { this.height,
       this.weight,
       this.bmi,
       this.steps,
       this.calories,
       this.heartrate});

  factory BioData.fromJson(Map<String, dynamic> json) {
    return BioData(
      height: json['height'],
      weight: json['weight'],
      bmi: json['bmi'],
      steps: json['steps'],
      calories: json['calories_burned'],
      heartrate: json['heart_rate'],
    );
  }

  static Future<Response?> create(BuildContext context, BioData model) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/user-biodatas/update');

    Map<String, String> data = {};
    data['height'] = model.height.toString();
    data['weight'] = model.weight.toString();
    data['bmi'] = model.bmi.toString();
    data['steps'] = model.steps.toString();
    data['calories_burned'] = model.calories.toString();
    data['heart_rate'] = model.heartrate.toString();
    return await webService.setData(data).send();
  }

  static Future<Response?> createBio(BuildContext context, BioData model) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/user-biodatas/update');

    Map<String, String> data = {};
    data['height'] = model.height.toString();
    data['weight'] = model.weight.toString();
    return await webService.setData(data).send();
  }

  static Future<Response?> createBMI(BuildContext context, BioData model) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/user-biodatas/update');

    Map<String, String> data = {};
    data['bmi'] = model.bmi.toString();
    data['steps'] = model.steps.toString();
    data['calories_burned'] = model.calories.toString();
    data['heart_rate'] = model.heartrate.toString();
    return await webService.setData(data).send();
  }

  static Future<Response?> createBMIHome(BuildContext context, BioData model) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/user-biodatas/update');

    Map<String, String> data = {};
    data['bmi'] = model.bmi.toString();
    return await webService.setData(data).send();
  }


  static Future<Response?> get(BuildContext context, BioData model) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/user-biodatas/update');

    Map<String, String> data = {};
    data['height'] = model.height.toString();
    data['weight'] = model.weight.toString();
    data['bmi'] = model.bmi.toString();
    data['steps'] = model.steps.toString();
    data['calories_burned'] = model.calories.toString();
    data['heart_rate'] = model.heartrate.toString();
    return await webService.setData(data).send();
  }

  static Future<BioData?> fetch(BuildContext context) async {
    final webService = WebService(context);
    BioData? bioData;
    webService.setEndpoint('identity/user-biodatas/get');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      bioData = BioData.fromJson(jsonDecode(response.body.toString()));
    } else {
      bioData = null;
    }
    return bioData;
  }

  static Future<BioData?> fetchOne(BuildContext context) async {
    final webService = WebService(context);
    BioData? bioData;
    var response =await webService.setEndpoint('identity/user-biodatas/get').send();
    if (response == null) return null;
    if (response.status) {
      final parseList = jsonDecode(response.body!).cast<Map<String, dynamic>>();
      List<BioData> bioDatas =
          parseList.map<BioData>((json) => BioData.fromJson(json)).toList();

      if (bioDatas.isNotEmpty) {
        bioData = bioDatas[0];
      }
    }

    return bioData;
  }
}
