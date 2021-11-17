import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImFkbWluIiwiaWQiOjEsImlhdCI6MTYzNzA3MzY5MywiZXhwIjoxNjM3MTYwMDkzfQ.qLGuoL0hIOrLa-Y3Nj1T8ECyWHhQngeAWmHm-p40e_8';

class NetworkService {
  static String _token = token;

  dynamic _processResponse(response) {
    final res = jsonDecode(response.body);
    final int statusCode = response.statusCode;

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

    return response.body;
  }

  Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $_token'
    });

    return _processResponse(response);
  }

  Future<dynamic> post(String url, {body}) async {
    final response = await http
        .post(Uri.parse(url), body: jsonEncode(body), headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $_token'
    });
    return _processResponse(response);
  }

  Future<dynamic> patch(String url, {body}) async {
    final response = await http
        .patch(Uri.parse(url), body: jsonEncode(body), headers: {
      "content-type": "application/json",
      'Authorization': 'Bearer $_token'
    });
    return _processResponse(response);
  }

  Future<dynamic> delete(String url) async {
    final response = await http
        .delete(Uri.parse(url), headers: {
      "content-type": "application/json",
      'Authorization': 'Bearer $_token'
    });
    return _processResponse(response);
  }
}