import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../utils/web_service.dart';

class OptCountry {
  final String code;
  final String name;

  OptCountry({required this.code, required this.name});

  factory OptCountry.fromJson(Map<String, dynamic> json) {
    return OptCountry(
      code: json['code'],
      name: json['name'],
    );
  }

  static Future<List<OptCountry>?> fetchAll(BuildContext context) async {
    final webService = WebService(context);
    webService.setEndpoint('option/countries');
    var response = await webService.send();
    if (response == null) return null;

    List<OptCountry>? optCountries;
    if (response.status) {
      final parseList = jsonDecode(response.body!).cast<Map<String, dynamic>>();
      optCountries = parseList.map<OptCountry>((json) => OptCountry.fromJson(json)).toList();
    }

    return optCountries;
  }
}
