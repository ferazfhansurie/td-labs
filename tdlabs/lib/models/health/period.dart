// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/web_service.dart';

class UserMenstrual {
  String? start_date;
  int? cycle;
  int? menstruation_days;
  String? end_date;
  String? start_ovulation;
  String? end_ovulation;
  List<dynamic>? menstrualCycles;
  String? peak_ovulation;
  String? test_pregnancy_date;
  UserMenstrual({
    this.start_date,
    this.cycle,
    this.menstruation_days,
    this.end_date,
    this.start_ovulation,
    this.end_ovulation,
    this.menstrualCycles,
    this.peak_ovulation,
    this.test_pregnancy_date,
  });

  factory UserMenstrual.fromJson(Map<String, dynamic> json) {
    return UserMenstrual(
      start_date: json['start_date'],
      cycle: json['cycle'],
      menstruation_days: json['menstruation_days'],
      end_date: json['end_date'],
      start_ovulation: json['start_ovulation'],
      end_ovulation: json['end_ovulation'],
      menstrualCycles: json['menstrual_cycles'],
    );
  }
  static Future<Response?> create(
      BuildContext context, UserMenstrual userMenstrual) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/user-menstruals');

    Map<String, String> data = {};
    data['start_date'] = userMenstrual.start_date.toString();
    data['cycle'] = userMenstrual.cycle.toString();
    data['menstruation_days'] = userMenstrual.menstruation_days.toString();

    return await webService.setData(data).send();
  }

  static Future<UserMenstrual?> fetch(BuildContext context) async {
    final webService = WebService(context);
    UserMenstrual? userMenstrual;
    webService.setEndpoint('identity/user-menstruals/get');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      userMenstrual =
          UserMenstrual.fromJson(jsonDecode(response.body.toString()));
    } else {
      userMenstrual = null;
    }
    return userMenstrual;
  }

  static Future<Response?> update(
      BuildContext context, UserMenstrual userMenstrual) async {
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('identity/user-menstruals/update');
    Map<String, String> data = {};
    data['start_date'] = userMenstrual.start_date.toString();
    data['cycle'] = userMenstrual.cycle.toString();
    data['menstruation_days'] = userMenstrual.menstruation_days.toString();
    return await webService.setData(data).send();
  }

  static Future<Response?> delete(
    BuildContext context,
  ) async {
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('identity/user-menstruals/delete');
    return await webService.send();
  }

  static Future<List<dynamic>> fetchCycle(BuildContext context) async {
    final webService = WebService(context);
    var cycle;
    webService.setMethod('GET').setEndpoint('option/list/menstrual-cycle');
    var response = await webService.send();
    if (response!.status) {
      cycle = jsonDecode(response.body.toString());
    }
    return cycle;
  }
}
