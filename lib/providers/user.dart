import 'package:flutter/material.dart';
import 'package:resep_obat_400/models/user.dart';

class UserProvider with ChangeNotifier {
  UserModel _user = UserModel.empty();
  UserModel get user => _user;
  set user(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
