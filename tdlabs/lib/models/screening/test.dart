// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import '../user/user.dart';
import '../poc/poc.dart';
import '../../utils/web_service.dart';

class Test {
  final int? id;
  int? poc_id;
  int? type;
  int? timeSession;
  String? price;
  String? originalPrice;
  String? appCredit;
  DateTime? appointmentAt;
  int? mode;
  int? voucher_id;
  String? voucher_code;
  String? voucher_child;
  DateTime? validated_at;
  int? payment_method;
  int? is_cancelled;
  String? latitude;
  String? longitude;
  final int? createdAt;
  final Poc? poc;
  final User? user;
  final String? result;
  final String? refNo;
  final String? session_name;
  final String? resultName;
  final String? createdAtText;
  final String? fileUrl;
  final String? imageUrl;
  Map<String, dynamic>? test_address;
  bool? flow_complete;
  String? ai_result;
  String? hash;
  int? order_id;
  String? qrCode;
  int? brand_id;
  String? videoUrl;
  int? is_general_report;
  int? use_credit;
  int? dependant_id;
  String? dependant_name;
  String? tac_code;
  String? other_remark;
  int? is_e_report;
  int? is_paid;
  String? link;
  String? user_remark;
  int? doctor_id;
  int? consult_type_id;
  String? report;
  Test(
      {this.id,
      this.poc_id,
      this.type,
      this.timeSession,
      this.result,
      this.price,
      this.appointmentAt,
      this.createdAt,
      this.poc,
      this.user,
      this.refNo,
      this.session_name,
      this.resultName,
      this.createdAtText,
      this.fileUrl,
      this.imageUrl,
      this.mode,
      this.latitude,
      this.longitude,
      this.voucher_id,
      this.voucher_code,
      this.voucher_child,
      this.payment_method,
      this.originalPrice,
      this.appCredit,
      this.is_cancelled,
      this.validated_at,
      this.test_address,
      this.flow_complete,
      this.ai_result,
      this.order_id,
      this.hash,
      this.qrCode,
      this.brand_id,
      this.videoUrl,
      this.is_general_report,
      this.is_e_report,
      this.use_credit,
      this.dependant_id,
      this.dependant_name,
      this.tac_code,
      this.is_paid,
      this.user_remark,
      this.other_remark,
      this.link,
      this.doctor_id,
      this.consult_type_id,this.report});

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      poc_id: json['poc_id'],
      doctor_id: json['doctor_id'],
      type: json['type'],
      ai_result: json['ai_result'],
      timeSession: json['time_session'],
      result: json['result'],
      price: json['price'],
      appointmentAt: (json['appointment_at'] != null)
          ? (DateTime.parse(json['appointment_at']))
          : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      createdAt: json['created_at'],
      poc: (json['poc'] != null) ? (Poc.fromJson(json['poc'])) : null,
      user: User.fromJson(json['user']),
      refNo: json['ref_no'],
      session_name: json['session_name'],
      resultName: (json['result_name'] != null) ? json['result_name'] : 'Test',
      createdAtText: json['created_at_text'],
      fileUrl: (json['file_url'] != null) ? json['file_url'] : null,
      flow_complete:
          (json['flow_complete'] != null) ? json['flow_complete'] : true,
      imageUrl: json['image_url'],
      mode: json['mode'],
      originalPrice: json['original_price'],
      appCredit: json['credit'],
      voucher_id: json['voucher_id'],
      voucher_child: json['voucher_child'],
      voucher_code: json['voucher_code'],
      validated_at: (json['validated_at'] != null)
          ? (DateTime.parse(json['validated_at']))
          : null,
      is_cancelled: json['is_cancelled'],
      is_paid: json['is_paid'],
      test_address: json['test_address'],
      hash: json['hash'],
      order_id: json['order_id'],
      payment_method: json['payment_method'],
      brand_id: json['brand_id'],
      qrCode: json['qr_string'],
      is_general_report: json['is_general_report'],
      is_e_report: json['is_e_report'],
      use_credit: json['use_credit'],
      dependant_id: json['dependant_id'],
      dependant_name: json['dependant_name'],
      tac_code: json['tac_code'],
      other_remark: json['other_remark'],
      videoUrl: json['video_url'],
      user_remark: json['user_remark'],
      link: json['link'],
      consult_type_id: json['consult_type_id'],
      report: json['report'],
    );
  }

  static Future<Response?> create(BuildContext context, Test test) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('screening/tests');
    Map<String, String> data = {};
    data['poc_id'] = test.poc_id.toString();
    data['type'] = test.type.toString();
    data['time_session'] = test.timeSession.toString();
    data['price'] = test.price.toString();
    data['original_price'] = test.originalPrice.toString();
    data['appointment_at'] = test.appointmentAt.toString();
    data['mode'] = test.mode.toString();
    data['voucher_id'] = test.voucher_id.toString();
    data['voucher_child'] = test.voucher_child.toString();
    data['voucher_code'] = test.voucher_code.toString();
    data['payment_method'] = test.payment_method.toString();
    data['use_credit'] = test.use_credit.toString();
    data['dependant_id'] = test.dependant_id.toString();
    data['user_remark'] = test.user_remark.toString();
    if(test.doctor_id != null){
         data['doctor_id'] = test.doctor_id.toString();
    }
   if(test.consult_type_id != null){
       data['consult_type_id'] = test.consult_type_id.toString();
    }
    
    return await webService.setData(data).send();
  }

  static Future<Response?> cancel(BuildContext context, int testId) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('screening/tests/cancel/$testId');

    return await webService.send();
  }

  static List<String> validate(Test test, {String scenario = 'default'}) {
    List<String> errors = [];
    if (test.poc_id == null) errors.add('Point of Care field cannot be blank.');
    if (test.type == null) errors.add('Please pick type of booking');
    if (test.appointmentAt == null) {
      errors.add('Appointment field cannot be blank.');
    }
    if (test.timeSession == null) errors.add('Session field cannot be blank.');

    return errors;
  }
}
