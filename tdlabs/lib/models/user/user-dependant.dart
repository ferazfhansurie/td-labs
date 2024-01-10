// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tdlabs/utils/web_service.dart';

class UserDependant {
  int? id;
  int? age;
  int? relation;
  String? name;
  String? idno;
  String? phone;
  String? email;

  UserDependant({
    this.id,
    this.name,
    this.idno,
    this.phone,
    this.email,
    this.age,
    this.relation,
  });

  factory UserDependant.fromJson(Map<String, dynamic> json) {
    return UserDependant(
      id: json['dependant_id'],
      name: json['name'],
      idno: json['id_no '],
      phone: json['phone_no '],
      email: json['email '],
      age: json['age'],
      relation: json['relation'],
    );
  }

  static Future<Response?> create(
      BuildContext context, UserDependant userDependant) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/user-dependants');

    Map<String, String> data = {};
    data['dependant_id'] = userDependant.id.toString();
    data['name'] = userDependant.name.toString();
    data['id_no'] = userDependant.idno.toString();
    data['phone_no'] = userDependant.phone.toString();
    data['email'] = userDependant.email.toString();
    data['age'] = userDependant.age.toString();
    data['relation'] = userDependant.relation.toString();

    return await webService.setData(data).send();
  }

  static Future<Response?> update(
      BuildContext context, int id, UserDependant userDependant) async {
    final webService = WebService(context);
    webService
        .setMethod('PUT')
        .setEndpoint('identity/user-dependants/update/$id');

    Map<String, String> data = {};
    if (userDependant.name != null) {
      data['name'] = userDependant.name.toString();
    }
    if (userDependant.email != null) {
      data['email'] = userDependant.email.toString();
    }
    if (userDependant.phone != null) {
      data['phone_no'] = userDependant.phone.toString();
    }
    if (userDependant.idno != null) {
      data['id_no'] = userDependant.idno.toString();
    }
    if (userDependant.age != null) data['age'] = userDependant.age.toString();
    if (userDependant.relation != null) {
      data['relation'] = userDependant.relation.toString();
    }

    return await webService.setData(data).send();
  }

  static Future<UserDependant?> fetch(BuildContext context) async {
    UserDependant? userDependant;
    final webService = WebService(context);
    var response =
        await webService.setEndpoint('identity/user-dependants').send();
    if (response == null) return null;

    if (response.status) {
      final parseList =
          jsonDecode(response.body.toString()).cast<Map<String, dynamic>>();
      List<UserDependant> userDependants = parseList
          .map<UserDependant>((json) => UserDependant.fromJson(json))
          .toList();

      if (userDependants.isNotEmpty) {
        userDependant = userDependants[0];
      }
    }

    return userDependant;
  }

  static List<String> validate(
    UserDependant userDependant,
  ) {
    List<String> errors = [];
    if (userDependant.name!.isEmpty) errors.add('Name field cannot be blank.');

    if (userDependant.idno!.isEmpty) {
      errors.add('IC/Passport field cannot be blank.');
    }
    if (userDependant.age == 0) {
      errors.add('Age cannot be blank.');
    }

    return errors;
  }
}
