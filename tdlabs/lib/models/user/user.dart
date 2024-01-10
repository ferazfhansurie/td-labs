// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison, avoid_print, curly_braces_in_flow_control_structures, prefer_typing_uninitialized_variables, empty_catches

import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/web_service.dart';

class User {
  int? id;
  final int? healthStatus;
  String? name;
  int? gender;
  int? nationality;
  String? phoneNo;
  String? email;
  String? password;
  String? id_no;
  String? dob;
  String? address1;
  String? address2;
  String? postcode;
  String? city;
  String? state;
  String? country;
  String? referrerReference;
  int? usernameType;
  int? policyAccepted;
  String? latest_test_at;
  String? device_token;
  int? id_no_verified;
  String? credit;
  String? credit_cash;
  String? stat_lock;
  int? language;
  var latest_app_ver;
  String? avatar_url;
  List<dynamic>? oauth_social;
  int? redeem_gift_status;
  int? gift_vouchers_used;
  Map<String, dynamic>? health_stat_locked;
  User(
      {this.id,
      this.name,
      this.gender,
      this.nationality,
      this.phoneNo,
      this.email,
      this.healthStatus,
      this.id_no,
      this.dob,
      this.address1,
      this.address2,
      this.postcode,
      this.city,
      this.state,
      this.country,
      this.referrerReference,
      this.usernameType,
      this.policyAccepted,
      this.latest_test_at,
      this.device_token,
      this.id_no_verified,
      this.credit,
      this.credit_cash,
      this.stat_lock,
      this.language,
      this.latest_app_ver,
      this.avatar_url,
      this.redeem_gift_status,
      this.gift_vouchers_used,
      this.oauth_social,
      this.health_stat_locked});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: (json['name'] != null) ? json['name'] : '',
      id_no: json['id_no'],
      id_no_verified: json['id_no_verified'],
      gender: json['gender'],
      nationality: json['nationality'],
      phoneNo: json['phone_no'],
      email: json['email'],
      healthStatus: json['health_status'],
      dob: json['dob'],
      address1: json['address_1'],
      address2: json['address_2'],
      postcode: json['postcode'],
      city: json['city'],
      state: json['state_code'],
      country: json['country_code'],
      referrerReference: json['reference'],
      usernameType: json['username_type'],
      policyAccepted: json['policy_accepted'],
      latest_test_at: json['latest_test_at'],
      device_token: json['fcm_token'],
      credit: json['credit'],
      credit_cash: json['credit_cash'],
      stat_lock: json['stat_lock_until'],
      language: json['language'],
      latest_app_ver: json['latest_app_ver'],
      avatar_url: json['avatar_url'],
      oauth_social: json['oauth_social'],
      redeem_gift_status: json['redeem_gift_status'],
      gift_vouchers_used: json['gift_vouchers_used'],
      health_stat_locked: json['health_stat_locked'],
    );
  }

  static Future<User?> fetchOne(BuildContext context) async {
    final webService = WebService(context);
    User? user;
    var response = await webService.setEndpoint('identity/users').send();
    if (response == null) return null;
    if (response.status) {
      final parseList = jsonDecode(response.body!).cast<Map<String, dynamic>>();
      List<User> users = parseList.map<User>((json) => User.fromJson(json)).toList();
      if (users.isNotEmpty) {
        user = users[0];
      }
    }
    return user;
  }

  static Future<Response?> create(BuildContext context, User user) async {
    final webService = WebService(context);
    webService.setAuthType('Basic').setMethod('POST').setEndpoint('identity/signup');
    Map<String, String> data = {};
    data['phone_no'] = user.phoneNo!;
    data['password'] = user.password!;
    data['name'] = user.name!;
    if (user.referrerReference != null) {
      data['referrer_reference'] = user.referrerReference!;
    }
    if (user.email != null) data['email'] = user.email!;
    return await webService.setData(data).send();
  }

  static Future<Response?> verify(BuildContext context, String phoneNo,String pin, String email, int usernameType) async {
    final webService = WebService(context);
    webService.setAuthType('Basic').setMethod('POST').setEndpoint('identity/signup/verify');
    Map<String, String> data = {
      'phone_no': phoneNo,
      'pin': pin,
      'email': email,
      'username_type': usernameType.toString()
    };
    return await webService.setData(data).send();
  }

  static Future<Response?> verify2(BuildContext context, String phoneNo,String pin, String email, int usernameType) async {
    final webService = WebService(context);
    webService.setAuthType('Basic').setMethod('POST').setEndpoint('identity/users/verify');
    Map<String, String> data = {
      'phone_no': phoneNo,
      'pin': pin,
      'email': email,
      'username_type': usernameType.toString()
    };
    return await webService.setData(data).send();
  }

  static Future<Response?> update(BuildContext context, int id, User user) async {
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('identity/users/' + id.toString());
    Map<String, String> data = {};
    if (user.name != null) data['name'] = user.name!;
    if (user.email != null) data['email'] = user.email!;
    if (user.gender != null) data['gender'] = user.gender.toString();
    if (user.nationality != null) {
      data['nationality'] = user.nationality.toString();
    }
    if (user.id_no != null) data['id_no'] = user.id_no!;
    if (user.dob != null) data['dob'] = user.dob!;
    if (user.address1 != null) data['address_1'] = user.address1!;
    if (user.address2 != null) data['address_2'] = user.address2!;
    if (user.postcode != null) data['postcode'] = user.postcode!;
    if (user.city != null) data['city'] = user.city!;
    if (user.state != null) data['state_code'] = user.state!;
    if (user.country != null) data['country_code'] = user.country!;
    if (data.isNotEmpty) {
      return await webService.setData(data).send();
    }
    return null;
  }

  static Future<Response?> updateLanguage(BuildContext context, int id, int language) async {
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('identity/users/' + id.toString());
    Map<String, String> data = {};
    if (language != null) data['language'] = language.toString();
    try {
      return await webService.setData(data).send();
    } catch (e) {}

    return null;
  }

  static Future<Response?> uploadAvatar(BuildContext context, String image) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/users/upload-avatar');
    Map<String, String> data = {};
    if (image != null) data['image'] = image.toString();
    try {
      return await webService.setData(data).send();
    } catch (e) {}

    return null;
  }

  static Future<Response?> deletedAvatar(BuildContext context) async {
    final webService = WebService(context);
    webService.setMethod('PUT').setEndpoint('identity/users/remove-avatar');
    try {
      return await webService.send();
    } catch (e) {}
    return null;
  }

  // ignore: missing_return
  static Future<Response?> updateDeviceToken(BuildContext context, String deviceToken) async {
    final webService = WebService((context));
    webService.setMethod('PUT').setEndpoint('identity/users/fcm-token');
    Map<String, String> data = {};
    data['fcm_token'] = deviceToken;
    try {
      return await webService.setData(data).send();
    } catch (e) {}
    return null;
  }
static Future<Response?> updateGoal(BuildContext context, String steps) async {
    final webService = WebService((context));
    webService.setMethod('POST').setEndpoint('identity/user-biodatas/update');
    Map<String, String> data = {};
    data['steps'] = steps;
    try {
      return await webService.setData(data).send();
    } catch (e) {}
    return null;
  }
  static List<String> validate(User user, {String scenario = 'default'}) {
    List<String> errors = [];
    if (user.name!.isEmpty) errors.add('Name field cannot be blank.');
    if (user.email!.isNotEmpty) if (!EmailValidator.validate(user.email!)) {
      errors.add('Invalid email address.');
    }
    if (scenario == 'create') {
      if (user.phoneNo!.isEmpty) {
        errors.add('Phone No. field cannot be blank.');
      } else if (user.phoneNo!.length < 10) {
        errors.add('Phone No. should contain at least 10 characters.');
      }
      if (user.password!.isEmpty) {
        errors.add('Password field cannot be blank.');
      } else if (user.password!.length < 6) {
        errors.add('Password should contain at least 6 characters.');
      }
    }
    return errors;
  }

  static List<String> validate2(User user, {String scenario = 'default'}) {
    List<String> errors = [];

    if (scenario == 'create') {
      if (user.phoneNo!.isEmpty) {
        errors.add('Phone No. field cannot be blank.');
      } else if (user.phoneNo!.length < 10) {
        errors.add('Phone No. should contain at least 10 characters.');
      }

      if (user.password!.isEmpty) {
        errors.add('Password field cannot be blank.');
      } else if (user.password!.length < 6) {
        errors.add('Password should contain at least 6 characters.');
      }
    }
    return errors;
  }

  static List<String> checkProceedTest(User user) {
    List<String> errors = [];
    if (user.dob == null) {
      errors.add('Birthday');
    }
    if (user.address1 == '') {
      errors.add('Address');
    }
    if (user.id_no == '') {
      errors.add('IC');
    }
    return errors;
  }

  static List<String> checkProceedSimka(User user) {
    List<String> errors = [];
    if (user.id_no_verified == 0) {
      errors.add('Not Verified');
    }
    return errors;
  }
}
