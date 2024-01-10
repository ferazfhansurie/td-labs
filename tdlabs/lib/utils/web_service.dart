// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/main.dart';
import 'package:tdlabs/screens/user/next_screen.dart';

/// @copyright Copyright (c) 2021
/// @author David Cheang <davidcheang83@gmail.com>
/// @version 2.0.2 (null-safety)

class WebService {
  final request = Request();
  final response = Response();
  BuildContext context;
  Map<String, VoidCallback> events = {};

  WebService(this.context, {Map<String, VoidCallback>? events}) {
    if (events != null) this.events = events;
  }

  WebService setAuthType(String authType) {
    request.authType = authType;
    return this;
  }

  WebService setMethod(String method) {
    request.method = method;
    return this;
  }

  WebService setPage(int page) {
    request.page = page;
    return this;
  }

  WebService setEndpoint(String endpoint) {
    request.endpoint = endpoint;
    return this;
  }

  WebService setExpand(String expand) {
    request.expand = expand;
    return this;
  }

  WebService setFilter(Map<String, String> filter) {
    request.filter = filter;
    return this;
  }

  WebService setData(Map<String, dynamic> data) {
    request.data = data;
    return this;
  }

  Future<bool?> authenticate(String username, String password,
      {String? messagingToken}) async {
    var data = {'username': username, 'password': password};
    if (messagingToken != null) data['messaging_token'] = messagingToken;
    return _authenticate(data);
  }

  Future<bool?> authenticateRefresh(String refreshToken,
      {String? messagingToken}) async {
    var data = {'grant_type': 'refresh_token', 'refresh_token': refreshToken};
    if (messagingToken != null) data['messaging_token'] = messagingToken;
    return _authenticate(data);
  }

  Future<bool?> authenticateGoogle(String cred, String email) async {
    var data = {'grant_type': 'google', 'data': cred, 'refresh_token': ""};
    return _authenticateGoogle(data, email, cred);
  }

  Future<bool?> _authenticate(Map<String, String> data) async {
    if (data['grant_type'] == null) {
      data['grant_type'] = 'password';
    }
    Request request = Request();
    request.authType = 'Basic';
    request.method = 'POST';
    request.endpoint = 'identity/token';
    request.data = data;
    var response = await _execute(request);
    if (response == null) return null;
    if (response.status && response.body!.isNotEmpty) {
      var result = jsonDecode(response.body!);
      if (result['access_token'] != null) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('api.access_token', result['access_token']);

        sharedPreferences.setString(
            'api.refresh_token', result['refresh_token']);
        if (result['user_id'] != null) {
          sharedPreferences.setInt('api.user_id', result['user_id']);
        }
        if (result['user_role'] != null) {
          sharedPreferences.setString('api.user_role', result['user_role']);
        }

        return true;
      }
    }

    return false;
  }

  Future<bool?> _authenticateGoogle(
      Map<String, String> data, String email, String cred) async {
    if (data['grant_type'] == null) {
      data['grant_type'] = 'password';
    }
    Request request = Request();
    request.authType = 'Basic';
    request.method = 'POST';
    request.endpoint = 'identity/token';
    request.data = data;
    var response = await _execute(request);
    if (response == null) return null;

    if (response.status && response.body!.isNotEmpty) {
      var result = jsonDecode(response.body!);
      if (result['access_token'] != null) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('api.access_token', result['access_token']);
        sharedPreferences.setString(
            'api.refresh_token', result['refresh_token']);
        if (result['user_id'] != null) {
          sharedPreferences.setInt('api.user_id', result['user_id']);
        }
        if (result['user_role'] != null) {
          sharedPreferences.setString('api.user_role', result['user_role']);
        }
        if (result['next_screen'] == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return NextForm(email: email);
          }));
        }
        return true;
      }
    }

    return false;
  }

  Future<Response?> send() async {
    var response = await _execute(request);
    if (response == null) return null;

    // For expired token, attempt authenticate again (using refresh token)
    if (request.authType == 'Bearer') {
      if (this.response.statusCode == HttpStatus.unauthorized) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        String? refreshToken = sharedPreferences.getString('api.refresh_token');

        if (refreshToken != null) {
          bool? result = await authenticateRefresh(refreshToken);
          if ((result != null) && result) {
            response = await _execute(request);
          } else {
            // Clear shared preferences
            sharedPreferences.remove('api.access_token');
            sharedPreferences.remove('api.refresh_token');
            sharedPreferences.remove('api.user_id');
            sharedPreferences.remove('api.user_role');

            _onAuthFailed();
          }
        }
      }
    }

    return response;
  }

  Future<Response?> _execute(Request request) async {
    Map<String, String> params = {};
    if (request.page > 0) params['page'] = request.page.toString();
    if (request.expand != null) params['expand'] = request.expand!;
    if (request.filter.isNotEmpty) {
      request.filter.forEach((key, value) {
        params['filter[' + key + ']'] = Uri.encodeComponent(value);
      });
    }

    // Query builder
    String query = '';
    int queryCount = 0;
    params.forEach((key, value) {
      if (queryCount > 0) query += '&';
      query += key + '=' + value;
      queryCount++;
    });

    String url = MainConfig.appUrl + '/' + request.endpoint;
    if (params.isNotEmpty) url += '?' + query;
    request.url = Uri.parse(url);

    return _submitRequest(request);
  }

  Future<Response?> _submitRequest(Request request) async {
    try {
      this.response.status = false;

      var response = await _sendHttp(request);
      if (response == null) return null;

      this.response.pagination = {
        'pageCount': 1,
        'totalCount': 0,
        'perPage': 0,
        'currentPage': 1
      };
      if (response.headers['x-pagination-page-count'] != null) {
        this.response.pagination!['pageCount'] =
            int.parse(response.headers['x-pagination-page-count']!);
      }
      if (response.headers['x-pagination-total-count'] != null) {
        this.response.pagination!['totalCount'] =
            int.parse(response.headers['x-pagination-total-count']!);
      }
      if (response.headers['x-pagination-per-page'] != null) {
        this.response.pagination!['perPage'] =
            int.parse(response.headers['x-pagination-per-page']!);
      }
      if (response.headers['x-pagination-current-page'] != null) {
        this.response.pagination!['currentPage'] =
            int.parse(response.headers['x-pagination-current-page']!);
      }

      this.response.header = response.headers;
      this.response.statusCode = response.statusCode;
      this.response.body = response.body;

      if ([
        HttpStatus.ok,
        HttpStatus.created,
        HttpStatus.accepted,
        HttpStatus.noContent
      ].contains(response.statusCode)) {
        this.response.status = true;
      } else {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List<dynamic>) {
          for (dynamic error in jsonResponse) {
            this.response.error.addAll({error['field']: error['message']});
          }
        }
      }

      return this.response;
    } catch (e) {
      return null;
    }
  }

  Future<http.Response?> _sendHttp(Request request) async {
    // Process header
    request.header['Content-Type'] = 'application/json';
    request.header['Accept'] = 'application/json';

    if (request.authType == 'Basic') {
      var authStr = MainConfig.appId + ':' + MainConfig.appSecret;
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      String authEncoded = stringToBase64.encode(authStr);
      request.header['Authorization'] = 'Basic $authEncoded';
    } else {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? accessToken = sharedPreferences.getString('api.access_token');
      request.header['Authorization'] = 'Bearer $accessToken';
    }

    if (request.method == 'POST') {
      return await http.post(request.url,
          headers: request.header, body: jsonEncode(request.data));
    } else if (request.method == 'PUT') {
      return await http.put(request.url,
          headers: request.header, body: jsonEncode(request.data));
    } else if (request.method == 'DELETE') {
      return await http.delete(request.url, headers: request.header);
    } else {
      return await http.get(request.url, headers: request.header);
    }
  }

  // Handles authentication failed event
  void _onAuthFailed() {
    if (events['authFailed'] != null) {
      events['authFailed']!();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

class Request {
  String authType = 'Bearer';
  String method = 'GET';
  late Uri url;
  late String endpoint;
  String? expand;
  int page = 0;
  Map<String, String> filter = {};
  Map<String, String> header = {};
  Map<String, dynamic> data = {};
}

class Response {
  Map<String, String>? header;
  Map<String, int>? pagination;
  Map<String, String> error = {};
  bool status = false;
  int? statusCode;
  String? body;
}
