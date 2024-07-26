import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class UserData extends ChangeNotifier {
  String? _token;
  String? _userID;
  String? _role;
  Timer? _tokenTimer;

  UserData() {
    _loadUserData();
  }

  String? get token => _token;
  String? get userID => _userID;
  String? get role => _role;
  bool get isTokenLoaded => _token != null;

  Future<void> setUserData(String token, String userID, String role) async {
    _token = token;
    _userID = userID;
    _role = role;
    notifyListeners();
    await _saveUserData();
    _startTokenVerification();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('userID', _userID!);
    await prefs.setString('role', _role!);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userID = prefs.getString('userID');
    _role = prefs.getString('role');

    if (_token != null) {
      final parts = _token!.split('.');
      if (parts.length == 3) {
        final payload = json.decode(utf8.decode(base64.decode(base64.normalize(parts[1]))));
        final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        if (expiry.isBefore(DateTime.now())) {
          _token = null;
          _userID = null;
          _role = null;
          await clearUserData();
        }
      }
    }
    notifyListeners();
    _startTokenVerification();
  }

  Future<void> _verifyToken() async {
    if (_token == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.1.4:3000/auth/token'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode != 200 || json.decode(response.body)['valid'] == false) {
      await clearUserData();
    }
  }

  void _startTokenVerification() {
    _tokenTimer?.cancel();
    _tokenTimer = Timer.periodic(const Duration(hours: 48), (timer) {
      _verifyToken();
    });
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userID');
    await prefs.remove('role');
    _token = null;
    _userID = null;
    _role = null;
    notifyListeners();
    _showTokenExpiredToast();
  }

  void _showTokenExpiredToast() {
    Fluttertoast.showToast(
      msg: "Your session has expired. Please log in again.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _tokenTimer?.cancel();
    super.dispose();
  }
}
