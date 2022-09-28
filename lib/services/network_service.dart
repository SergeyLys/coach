import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkService {
  static String _token = '';

  dynamic _processResponse(url, response) {
    final res = jsonDecode(response.body);
    final int statusCode = response.statusCode;

    print('$url $statusCode');

    if (statusCode < 200 || statusCode > 400) {
      if (res is Map<String, dynamic> && res.containsKey('message')) {
        throw res['message'];
      } else {
        throw "Error while fetching data";
      }
    }

    if (res is Map<String, dynamic> && res.containsKey('token')) {
      _token = res['token'];
    }

    print(response.body);

    return jsonDecode(response.body);
  }

  Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $_token'
    });

    return _processResponse(url, response);
  }

  Future<dynamic> post(String url, {body}) async {
    final response = await http
        .post(Uri.parse(url), body: jsonEncode(body), headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $_token'
    });
    return _processResponse(url, response);
  }

  Future<dynamic> patch(String url, {body}) async {
    final response = await http
        .patch(Uri.parse(url), body: jsonEncode(body), headers: {
      "content-type": "application/json",
      'Authorization': 'Bearer $_token'
    });
    return _processResponse(url, response);
  }

  Future<dynamic> delete(String url) async {
    final response = await http
        .delete(Uri.parse(url), headers: {
      "content-type": "application/json",
      'Authorization': 'Bearer $_token'
    });
    return _processResponse(url, response);
  }
}