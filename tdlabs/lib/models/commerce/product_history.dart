// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'order_address.dart';
import '../../utils/web_service.dart';

class ProductHistory {
  int? id;
  int? userId;
  int? paymentMethod;
  String? referenceNo;
  String? amount;
  String? discount;
  String? credit;
  String? statusLabel;
  String? shippingFee;
  int? status;
  int? type;
  String? phoneNo;
  String? total;
  List<dynamic>? items;
  DateTime? createdAt;
  String? hash;
  String? receiptUrl;
  OrderAddress? orderAddress;
  String? qr_code;
  String? qr_expiry_date;
  int? vm_id;
  int? collection_status;
  String? delivery_company;
  String? tracking_number;
  String? tracking_link;
  String? shipping_discount;
  ProductHistory({
    this.id,
    this.userId,
    this.paymentMethod,
    this.referenceNo,
    this.amount,
    this.discount,
    this.credit,
    this.status,
    this.type,
    this.total,
    this.items,
    this.createdAt,
    this.statusLabel,
    this.shippingFee,
    this.hash,
    this.phoneNo,
    this.receiptUrl,
    this.orderAddress,
    this.qr_code,
    this.qr_expiry_date,
    this.vm_id,
    this.tracking_link,
    this.delivery_company,
    this.tracking_number,
    this.collection_status,
    this.shipping_discount
  });

  factory ProductHistory.fromJson(Map<String, dynamic> json) {
    return ProductHistory(
      id: json['id'],
      userId: json['user_id'],
      paymentMethod: json['payment_method'],
      referenceNo: json['reference_no'],
      amount: json['amount'],
      discount: json['discount'],
      phoneNo: json['phone_no'],
      credit: json['credit'],
      status: json['status'],
      receiptUrl: json['receipt_url'],
      hash: json['hash'],
      shippingFee: json['shipping_fee'],
      type: json['type'],
      total: json['total'],
      statusLabel: json['status_label'],
      items: json['items'],
      createdAt: (json['created_at'] != null)
          ? (DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000))
          : null,
      orderAddress: (json['order_address'] != null)
          ? OrderAddress.fromJson(json['order_address'])
          : null,
      qr_code: json['qr_code'],
      qr_expiry_date: json['qr_expiry_date'],
      vm_id: json['vm_id'],
      tracking_link: json['tracking_link'],
      delivery_company: json['delivery_company'],
      tracking_number: json['tracking_number'],
      collection_status: json['collection_status'],
      shipping_discount: json['shipping_discount'],
    );
  }

  static Future<Response?> fetchHistory(BuildContext context) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('sales/orders');
    Map<String, String> filter = {};
    filter.addAll({'user_id': 'true'});
    filter.addAll({'type': '1'});

    return await webService.setFilter(filter).send();
  }

  static Future<Response?> fetchHistory2(BuildContext context, int id) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('sales/orders/$id');
    Map<String, String> filter = {};
    filter.addAll({'type': '1'});
    return await webService.setFilter(filter).send();
  }

  static Future<Response?> fetchRedeemHistory(BuildContext context) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('sales/orders');
    Map<String, String> filter = {};
    filter.addAll({'user_id': 'true'});
    filter.addAll({'type': '2'});

    return await webService.setFilter(filter).send();
  }
}
