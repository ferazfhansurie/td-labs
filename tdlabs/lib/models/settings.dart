import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../global.dart' as global;
import '../utils/web_service.dart';

class Settings {
  final String currency;
  final List<String>? countryList;

  Settings({this.currency = 'RM', this.countryList});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      currency: json['currency'],
      countryList: (json['country_list'] != null)
          ? List<String>.from(json['country_list'])
          : null,
    );
  }

  static Future<void> fetchServerSettings(BuildContext context) async {
    final webService = WebService(context);
    webService
        .setAuthType('Basic')
        .setMethod('POST')
        .setEndpoint('identity/server');
    var response = await webService.send();
    if ((response != null) && response.status && response.body!.isNotEmpty) {
      var result = jsonDecode(response.body!);

      // Load settings
      if (result['settings'] != null) {
        global.settings = Settings.fromJson(result['settings']);
      }
    }
  }
}
