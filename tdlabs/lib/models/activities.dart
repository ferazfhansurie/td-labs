import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../utils/web_service.dart';

class Activity {
  String? name;
  String? code;
  double? energy_burned;
  String? energy_unit;
  double? distance;
  String? distance_unit;
  int? is_hidden;

  Activity(
      { this.name,
       this.code,
       this.energy_burned,
       this.energy_unit,
       this.distance,
       this.distance_unit,
       this.is_hidden
       
       });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'],
      code: json['code'],
      energy_burned:double.parse(json['energy_burned']) ,
      energy_unit: json['energy_unit'],
      distance: double.parse(json['distance']),
      distance_unit: json['distance_unit'],
      is_hidden: json['is_hidden'],
    );
  }

   static Future<Response?> create(BuildContext context, List<Map<String, dynamic>> activities) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/user-biodata-activities/update');

    Map<String, String> data = {};
    data['activities'] = jsonEncode(activities);
   return await webService.setData(data).send();
  }



  static Future<Response?> get(BuildContext context,) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('identity/user-biodata-activities');
    return await webService.send();
  }


  static Future<Activity?> fetchOne(BuildContext context,int id) async {
    final webService = WebService(context);
    Activity? bioData;
    var response = await webService.setEndpoint('identity/user-biodata-activities/$id').send();
    if (response == null) return null;
    if (response.status) {
      final parseList = jsonDecode(response.body!).cast<Map<String, dynamic>>();
      List<Activity> bioDatas = parseList.map<Activity>((json) => Activity.fromJson(json)).toList();
      if (bioDatas.isNotEmpty) {
        bioData = bioDatas[0];
      }
    }

    return bioData;
  }
}
