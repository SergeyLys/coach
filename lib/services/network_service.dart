import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkService {
  String _token = '';
  late BuildContext _context;

  NetworkService(this._context);

  dynamic _processResponse(response) {
    final res = jsonDecode(response.body) as Map<String, dynamic>;
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400) {
      if (statusCode == 401) {
        Navigator.pushReplacementNamed(_context, '/login');
      }

      if (res.containsKey('message')) {
        throw res['message'];
      } else {
        throw "Error while fetching data";
      }
    }

    if (res.containsKey('token')) {
      _token = res['token'];
    }

    return res;
  }

  Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': _token
    });

    return _processResponse(response);
  }

  Future<dynamic> post(String url, {body}) async {
    final response = await http
        .post(Uri.parse(url), body: body, headers: {
          'Authorization': _token
    });
    return _processResponse(response);
  }
}