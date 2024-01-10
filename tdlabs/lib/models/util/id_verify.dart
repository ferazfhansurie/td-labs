import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../utils/web_service.dart';
import '../user/user.dart';

class IdVerify {
  final User? user;
  final int? id;
  String? image;
  int? declaration;
  int? status;
  IdVerify({this.user, this.id, this.image, this.declaration, this.status});

  factory IdVerify.fromJson(Map<String, dynamic> json) {
    return IdVerify(
      id: json['id'],
      user: (json['user'] != null) ? User.fromJson(json['user']) : null,
      image: json['file'],
      declaration: json['declaration'],
      status: json['status'],
    );
  }

  static Future<Response?> submit(BuildContext context, IdVerify idVerify) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/user-verifications');
    Map<String, String> data = {};
    data['file'] = idVerify.image!;
    data['declaration'] = idVerify.declaration.toString();

    return await webService.setData(data).send();
  }

  static Future<dynamic> fetch(BuildContext context) async {
    final webService = WebService(context);
    // ignore: prefer_typing_uninitialized_variables
    var parseList;
    webService.setEndpoint('identity/user-verifications/status');
    var response = await webService.send();
    if (response == null) return null;

    if (response.status) {
      parseList = jsonDecode(response.body.toString());
    }
    return parseList;
  }

  static List<String> validate(IdVerify idVerify,
      {String scenario = 'default'}) {
    List<String> errors = [];
    return errors;
  }
}
