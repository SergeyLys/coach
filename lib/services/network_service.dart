import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkService {
  static String _token = '';

  dynamic _processResponse(url, response, method) {
    final res = jsonDecode(response.body);
    final int statusCode = response.statusCode;

    print('NetworkService $method $url $statusCode ${response.body}');

    if (statusCode < 200 || statusCode > 400) {
      if (res is Map<String, dynamic> && res.containsKey('message')) {
        throw res;
      } else {
        throw "Error while fetching data";
      }
    }

    if (res is Map<String, dynamic> && res.containsKey('token')) {
      _token = res['token'];
    }

    return jsonDecode(response.body);
  }

  Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $_token'
    });

    return _processResponse(url, response, 'GET');
  }

  Future<dynamic> post(String url, {body}) async {
    final response = await http
        .post(Uri.parse(url), body: jsonEncode(body), headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $_token'
    });
    return _processResponse(url, response, 'POST');
  }

  Future<dynamic> patch(String url, {body}) async {
    final response = await http
        .patch(Uri.parse(url), body: jsonEncode(body), headers: {
      "content-type": "application/json",
      'Authorization': 'Bearer $_token'
    });
    return _processResponse(url, response, 'PATCH');
  }

  Future<dynamic> delete(String url) async {
    final response = await http
        .delete(Uri.parse(url), headers: {
      "content-type": "application/json",
      'Authorization': 'Bearer $_token'
    });
    return _processResponse(url, response, 'DELETE');
  }
}