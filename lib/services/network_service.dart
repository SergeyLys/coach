import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImFkbWluQG1haWwuY29tIiwiaWQiOjEsInJvbGVzIjpbXSwiaWF0IjoxNjMzMzU5MjI1LCJleHAiOjE2MzM0NDU2MjV9.5qtmpXcc4zLpMeAuIv8Vd3pP9k10jnOXPoXFN_j2LWw';

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
        .post(Uri.parse(url), body: body, headers: {
          'Authorization': 'Bearer $_token'
    });
    return _processResponse(response);
  }
}