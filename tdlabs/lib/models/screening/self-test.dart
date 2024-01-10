// ignore_for_file: file_names, non_constant_identifier_names, prefer_typing_uninitialized_variables

import '../../utils/web_service.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

class SelfTest {
  int? id;
  int? poc_id;
  int? type;
  int? brand_id;
  String? qrCode;
  int? verify;
  String? price;
  String? kit_result;
  String? image;
  String? appCredit;
  int? voucher_id;
  String? voucher_code;
  String? voucher_child;
  int? payment_method;
  int? is_cancelled;
  String? originalPrice;
  String? name;
  String? email;
  String? address1;
  String? address2;
  String? postcode;
  String? city;
  String? state;
  String? country;
  int? question_id;
  int? answer_id;
  String? latitude;
  String? longitude;
  String? answer_description;
  bool? AI_skip;
  int? confirmed_result;
  int? specimen;
  String? video;
  int? dependant_id;
  int? use_credit;
  int? method;
  String? tac_code;
  int? question_id2;
  int? answer_id2;
  String? answer_description2;
  SelfTest(
      {this.id,
      this.poc_id,
      this.type,
      this.brand_id,
      this.qrCode,
      this.price,
      this.verify,
      this.image,
      this.use_credit,
      this.kit_result,
      this.voucher_id,
      this.voucher_code,
      this.voucher_child,
      this.payment_method,
      this.is_cancelled,
      this.latitude,
      this.longitude,
      this.appCredit,
      this.originalPrice,
      this.name,
      this.email,
      this.address1,
      this.address2,
      this.postcode,
      this.city,
      this.state,
      this.country,
      this.answer_description,
      this.AI_skip,
      this.confirmed_result,
      this.specimen,
      this.video,
      this.dependant_id,
      this.method,
      this.tac_code,
      this.question_id2,
      this.answer_id2,
      this.answer_description2});

  factory SelfTest.fromJson(Map<String, dynamic> json) {
    return SelfTest(
      id: (json['id'] != null) ? json['id'] : '',
      name: (json['name'] != null) ? json['name'] : '',
      answer_description: json['answer_description'],
      AI_skip: json['ai_skip'],
      confirmed_result: json['confirmed_result'],
      email: json['email'],
      poc_id: json['poc_id'],
      qrCode: json['code'],
      type: json['type'],
      brand_id: json['brand'],
      verify: json['request_verify'],
      video: json['video'],
      specimen: json['specimen'],
      price: json['price'],
      image: json['image_url'],
      kit_result: json['kit_result'],
      appCredit: json['credit'],
      voucher_id: json['voucher_id'],
      voucher_child: json['voucher_child'],
      voucher_code: json['voucher_code'],
      latitude: json['latitdue'],
      longitude: json['longitude'],
      is_cancelled: json['is_cancelled'],
      originalPrice: json['original_price'],
      address1: json['address_1'],
      address2: json['address_2'],
      postcode: json['postcode'],
      city: json['city'],
      state: json['state_code'],
      country: json['country_code'],
      dependant_id: json['dependant_id'],
      use_credit: json['use_credit'],
      method: json['method'],
      tac_code: json['tac_code'],
    );
  }
  static Future<Response?> preCreate(
      BuildContext context, SelfTest selfTest) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('screening/self-tests/pre-submit');

    Map<String, String> data = {};
    data['id'] = selfTest.id.toString();
    data['code'] = selfTest.qrCode.toString();
    data['brand'] = selfTest.brand_id.toString();
    data['video'] = selfTest.video.toString();

    return await webService.setData(data).send();
  }

  static Future<Response?> preCreateCode(
      BuildContext context, SelfTest selfTest) async {
    final webService = WebService(context);
    webService
        .setMethod('POST')
        .setEndpoint('screening/self-tests/pre-submit-code');

    Map<String, String> data = {};
    data['id'] = selfTest.id.toString();
    data['poc_id'] = selfTest.poc_id.toString();
    data['brand'] = selfTest.brand_id.toString();
    data['payment_method'] = selfTest.payment_method.toString();
    data['original_price'] = selfTest.originalPrice.toString();
    data['price'] = selfTest.price.toString();
    data['voucher_id'] = selfTest.voucher_id.toString();
    data['voucher_child'] = selfTest.voucher_child.toString();
    data['voucher_code'] = selfTest.voucher_code.toString();
    data['use_credit'] = selfTest.use_credit.toString();
    data['video'] = selfTest.video.toString();

    return await webService.setData(data).send();
  }

  static Future<Response?> create(
      BuildContext context, SelfTest selfTest) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('screening/self-tests/submit');

    Map<String, String> data = {};
    data['id'] = selfTest.id.toString();
    data['poc_id'] = selfTest.poc_id.toString();
    data['code'] = selfTest.qrCode.toString();
    data['type'] = selfTest.type.toString();
    data['brand'] = selfTest.brand_id.toString();
    data['request_verify'] = selfTest.verify.toString();
    data['price'] = selfTest.price.toString();
    data['specimen'] = selfTest.specimen.toString();
    data['image'] = selfTest.image.toString();
    data['kit_result'] = selfTest.kit_result.toString();
    data['voucher_id'] = selfTest.voucher_id.toString();
    data['voucher_child'] = selfTest.voucher_child.toString();
    data['voucher_code'] = selfTest.voucher_code.toString();
    data['payment_method'] = selfTest.payment_method.toString();
    data['original_price'] = selfTest.originalPrice.toString();
    data['name'] = selfTest.name.toString();
    data['email'] = selfTest.email.toString();
    data['address_1'] = selfTest.address1.toString();
    data['address_2'] = selfTest.address2.toString();
    data['postcode'] = selfTest.postcode.toString();
    data['city'] = selfTest.city.toString();
    data['state_code'] = selfTest.state.toString();
    data['country_code'] = selfTest.country.toString();
    data['question_id'] = selfTest.question_id.toString();
    data['answer_id'] = selfTest.answer_id.toString();
    data['answer_description'] = selfTest.answer_description.toString();
    data['question_id2'] = selfTest.question_id2.toString();
    data['answer_id2'] = selfTest.answer_id2.toString();
    data['latitude'] = selfTest.latitude.toString();
    data['longitude'] = selfTest.longitude.toString();
    data['ai_skip'] = selfTest.AI_skip.toString();
    data['specimen'] = selfTest.specimen.toString();
    data['use_credit'] = selfTest.use_credit.toString();
    data['dependant_id'] = selfTest.dependant_id.toString();

    return await webService.setData(data).send();
  }

  static Future<Response?> submitForm(
      BuildContext context, SelfTest selfTest, int testId) async {
    final webService = WebService(context);
    webService
        .setMethod('PUT')
        .setEndpoint('screening/self-tests/confirm-result/$testId');

    Map<String, String> data = {};
    // data['poc_id'] = selfTest.poc_id.toString();
    // data['code'] = selfTest.qrCode;
    // data['type'] = selfTest.type.toString();
    // data['brand'] = selfTest.brand_id.toString();
    // data['request_verify'] = selfTest.verify.toString();
    // data['price'] = selfTest.price;
    // data['image'] = selfTest.image;
    // data['kit_result'] = selfTest.kit_result;
    // data['voucher_id'] = selfTest.voucher_id.toString();
    // data['voucher_child'] = selfTest.voucher_child.toString();
    // data['voucher_code'] = selfTest.voucher_code;
    // data['payment_method'] = selfTest.payment_method.toString();
    // data['original_price'] = selfTest.originalPrice.toString();
    // data['name'] = selfTest.name.toString();
    // data['email'] = selfTest.email.toString();
    // data['address_1'] = selfTest.address1.toString();
    // data['address_2'] = selfTest.address2.toString();
    // data['postcode'] = selfTest.postcode.toString();
    // data['city'] = selfTest.city.toString();
    // data['state_code'] = selfTest.state.toString();
    // data['country_code'] = selfTest.country.toString();
    // data['question_id'] = selfTest.answer_id.toString();
    // data['answer_id'] = selfTest.answer_id.toString();
    // data['answer_description'] = selfTest.answer_description.toString();
    // data['latitude'] = selfTest.latitude;
    // data['longitude'] = selfTest.longitude;
    // data['ai_skip'] = selfTest.AI_skip.toString();
    data['confirmed_result'] = selfTest.confirmed_result.toString();

    return await webService.setData(data).send();
  }

  static Future<SelfTest?> fetchOne(BuildContext context, int id) async {
    final webService = WebService(context);
    late SelfTest qrCode;
    webService.setEndpoint('screening/qr/' + id.toString()).setExpand('code');
    var response = await webService.send();
    if (response == null) return null;

    if (response.status) {
      qrCode = SelfTest.fromJson(jsonDecode(response.body.toString()));
    }

    return qrCode;
  }

  static Future<dynamic> fetchAnswers(BuildContext context, int refNo) async {
    final webService = WebService(context);

    var answers;
    webService.setMethod('GET').setEndpoint('survey/questions/$refNo');
    var response = await webService.send();
    if (response == null) return null;
    if (response.status) {
      answers = jsonDecode(response.body.toString());
    }
    return answers;
  }

  static List<String> validate(SelfTest selfTest, int validationType,
      {String scenario = 'default'}) {
    List<String> errors = [];
    if (selfTest.poc_id == null) errors.add('Please select preferred POC');
    if (selfTest.image == '') errors.add('Please upload test result image');
    if (selfTest.name == '') errors.add('Please state your name (Full Name)');
    if (selfTest.email == '') errors.add('Please state your email');
    if (selfTest.address1 == '') errors.add('Please complete you address');
    if (selfTest.postcode == '') errors.add('Please complete you address');
    if (selfTest.city == '') errors.add('Please complete you address');
    if (selfTest.state == '') errors.add('Please complete you address');

    if (selfTest.email == '' || selfTest.email == null) {
      errors.add('Email cannot be blank');
    }

    return errors;
  }

  static List<String> preValidate(SelfTest selfTest, int validationType,
      {String scenario = 'default'}) {
    List<String> errors = [];
    // ignore: curly_braces_in_flow_control_structures
    if (validationType == 1) if (selfTest.video == '' ||
        selfTest.video == null) {
      errors.add('Upload your test video');
    }
    return errors;
  }
}
