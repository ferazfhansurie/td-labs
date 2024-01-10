// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tdlabs/utils/web_service.dart';

class CatalogCart {
  final int? id;
  final String? name;
  List<Map<String, dynamic>>? items;
  int? in_stock;


  CatalogCart({this.id, this.name, this.items, this.in_stock});

  factory CatalogCart.fromJson(Map<String, dynamic> json) {
    return CatalogCart(
      id: json['id'],
      items: json['items'],
      in_stock: json['in_stock'],
    );
  }
  static Future<Response?> fetchCart(BuildContext context, int type) async {
    final webService = WebService(context);
    webService.setMethod('GET').setEndpoint('catalog/carts');
    Map<String, String> filter = {};
    filter.addAll({'cart_type': type.toString()});
    return await webService.setFilter(filter).send();
  }

  static Future<Response?> addItem(BuildContext context, List<Map<String, dynamic>> items) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('catalog/carts/add-to-cart');
    Map<String, String> data = {};
    data['items'] = jsonEncode(items);
    return await webService.setData(data).send();
  }

  static Future<Response?> addItemVM(BuildContext context, List<Map<String, dynamic>> items, int vmId) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('catalog/carts/add-to-cart');
    Map<String, String> data = {};
    data['items'] = jsonEncode(items);
    data['vm_id'] = vmId.toString();
    return await webService.setData(data).send();
  }

  static Future<Response?> removeItem(BuildContext context, List<Map<String, dynamic>> items,) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('catalog/carts/remove-from-cart');
    Map<String, String> data = {};
    data['items'] = jsonEncode(items);
    return await webService.setData(data).send();
  }
}
