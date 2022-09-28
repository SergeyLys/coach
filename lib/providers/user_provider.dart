import 'package:flutter/cupertino.dart';
import 'package:flutter_app/domains/user.dart';

class UserProvider extends ChangeNotifier {
  late final User _user;

  String get email => _user.email;
  int get id => _user.id;
  String get role => _user.role;

  void setUser(Map<String, dynamic> responseData) {
    _user = User.fromJson(responseData);
    notifyListeners();
  }
}