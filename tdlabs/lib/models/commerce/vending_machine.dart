// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tdlabs/utils/web_service.dart';

class VendingMachine {
  final int? id;
  final String? name;
  final String? code;
  List<Map<String, dynamic>>? items;
  String? imageUrl;
  String? longitude;
  String? latitude;
  // ignore: non_constant_identifier_names
  final String? area_name;
  int? vm_id;
  String? vm_name;
  String? vm_code;
  String? vm_area_name;
  String? vm_image_url;
  String? distance;
  List<dynamic>? product_list;
  VendingMachine({
    this.id,
    this.name,
    this.code,
    this.area_name,
    this.items,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.vm_id,
    this.vm_name,
    this.vm_code,
    this.vm_area_name,
    this.vm_image_url,
    this.distance,
    this.product_list,
    // ignore: non_constant_identifier_names
  });

  factory VendingMachine.fromJson(Map<String, dynamic> json) {
    return VendingMachine(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      area_name: json['area_name'],
      items: json['items'],
      imageUrl: json['image_url'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      vm_id: json['vm_id'],
      vm_name: json['vm_name'],
      vm_code: json['vm_code'],
      vm_area_name: json['vm_area_name'],
      vm_image_url: json['vm_image_url'],
      distance:json['distance'].toString(),
      product_list: json['product_list'],
    );
  }

  static Future<Response?> checkItems(
      BuildContext context, int vm_id, VendingMachine vm, int page) async {
    final webService = WebService(context);

    webService
        .setMethod('POST')
        .setEndpoint('vm/vending-machines/check-items')
        .setPage(page);
    Map<String, String> data = {};
    data['vm_id'] = vm_id.toString();
    data['items'] = jsonEncode(vm.items);
    return await webService.setData(data).send();
  }
}
