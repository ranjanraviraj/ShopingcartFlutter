import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';
import '../const/constant.dart';
import '../const/pref_const.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAn6WyY3w2pmNUGkUCYv9AF6VtRHT_8D5k';
    try {
      final response = await http.post(url,
          body: json.encode({
            Constant.EMAIL: email,
            Constant.PASSWORD: password,
            Constant.RETURN_SECURE_TOKEN: true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData[Constant.TOKEN];
      _userId = responseData[Constant.USER_ID];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData[Constant.EXPIRES_IN]),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        Constant.TOKEN: _token,
        Constant.USER_ID: _userId,
        Constant.EXPIRES_IN: _expireDate.toIso8601String(),
      });
      prefs.setString(PrefConst.USER_DATA, userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(PrefConst.USER_DATA)) {
      return false;
    }
    final userData = json.decode(prefs.getString(PrefConst.USER_DATA))
        as Map<String, Object>;
    final expireDate = DateTime.parse(userData[Constant.EXPIRES_IN]);
    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = userData[Constant.TOKEN];
    _userId = userData[Constant.USER_ID];
    _expireDate = expireDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(PrefConst.USER_DATA);
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final expireeDifference = _expireDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expireeDifference), logout);
  }
}
