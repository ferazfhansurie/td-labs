// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../utils/web_service.dart';

class Product {
  String? name;
  String? phone_no;
  String? email;
  String? address_1;
  String? address_2;
  String? postcode;
  String? city;
  String? state_code;
  String? order_remark;
  List<Map<String, dynamic>>? items;
  int? voucher_id;
  int? voucher_child;
  int? payment_method;
  int? payment_method_id;
  String? shippingFees;
  String? original_shipping_price;
  String? shipping_discount;
  int? use_credit;
  int? pickup_type;
  int? delivery_provider;
  int? vm_id;
  String? price;
  String? latitude;
  String? longitude;
  String? quotation_id;
  Product(
      {this.name,
      this.phone_no,
      this.email,
      this.address_1,
      this.address_2,
      this.postcode,
      this.city,
      this.state_code,
      this.order_remark,
      this.items,
      this.voucher_child,
      this.voucher_id,
      this.payment_method,
      this.shippingFees,
      this.original_shipping_price,
      this.shipping_discount,
      this.payment_method_id,
      this.use_credit,
      this.pickup_type,
      this.delivery_provider,
      this.vm_id,
      this.price,
      this.latitude,
      this.longitude,
      this.quotation_id});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      phone_no: json['phone_no'],
      email: json['email'],
      address_1: json['address_1'],
      address_2: (json['address_2'] != null) ? json['address_2'] : '',
      postcode: json['postcode'],
      city: json['city'],
      state_code: json['state_code'],
      order_remark: json['order_remark'],
      items: json['items'],
      voucher_child: json['voucher_child'],
      voucher_id: json['voucher_id'],
      payment_method: json['payment_method'],
      payment_method_id: json['payment_method_id'],
      shippingFees: json['shipping_fee'],
      original_shipping_price: json['original_shipping_price'],
      shipping_discount: json['shipping_discount'],
      use_credit: json['use_credit'],
      pickup_type: json['pickup_type'],
      delivery_provider: json['delivery_provider'],
      vm_id: json['vm_id'],
      price: (json['price'] != null) ? json['price'] : '0',
      latitude: json['latitude'],
      longitude: json['longitude'],
      quotation_id: json['quotation_id'],
    );
  }

  static Future<Response?> create(BuildContext context, Product product) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('sales/orders');
    Map<String, dynamic> data = {};
    data['name'] = product.name.toString();
    data['phone_no'] = product.phone_no.toString();
    data['email'] = (product.email != null) ? product.email.toString() : '';
    data['address_1'] = product.address_1.toString();
    data['address_2'] = product.address_2.toString();
    data['postcode'] = product.postcode.toString();
    data['city'] = product.city.toString();
    data['state_code'] = product.state_code.toString();
    data['order_remark'] = product.order_remark.toString();
    data['items'] = jsonEncode(product.items);
    data['voucher_child'] = product.voucher_child;
    data['voucher_id'] = product.voucher_id;
    data['payment_method'] = product.payment_method;
    data['shipping_fee'] = product.shippingFees;
    data['original_shipping_price'] = product.original_shipping_price;
    data['shipping_discount'] = product.shipping_discount;
    data['payment_method_id'] = product.payment_method_id.toString();
    data['use_credit'] = product.use_credit.toString();
    data['vm_id'] = product.vm_id.toString();
    data['pickup_type'] = product.pickup_type.toString();
    data['delivery_provider'] = product.delivery_provider.toString();
    data['price'] = product.price;
    data['latitude'] = product.latitude;
    data['longitude'] = product.longitude;
    data['quotation_id'] = product.quotation_id;
    return await webService.setData(data).send();
  }

  static List<String> validate(Product selfTest,
      {String scenario = 'default'}) {
    List<String> errors = [];

    return errors;
  }
}
