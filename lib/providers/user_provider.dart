import 'package:flutter/cupertino.dart';
import 'package:flutter_app/assets/constants.dart';
import 'package:flutter_app/domains/user.dart';
import 'package:flutter_app/services/network_service.dart';

class UserProvider extends ChangeNotifier {
  late final User _user;

  String get email => _user.email;
  int get id => _user.id;
  String get role => _user.role;

  void setUser(Map<String, dynamic> responseData) {
    _user = User.fromJson(responseData);
    notifyListeners();
  }

  Future<void> fetchTrainees() async {
    try {
      final response = await NetworkService().get(
          '$apiUrl/users/by-coach/$id'
      );

      print(response);

      notifyListeners();
    } catch(e) {
      print('fetchTrainees error $e');
    }
  }
}