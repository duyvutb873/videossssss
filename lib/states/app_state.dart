import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AppState extends ChangeNotifier {
  String? accessCode;
  String? password;
  String? campaignName;
  Map<String, dynamic>? deviceInfo;
  List<Media> _mediaList = [];
  String? _loginError;
  bool _isLoggedIn = false;
  bool _loadingAutoLogin = true;
  final ApiService _api = ApiService();

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoadingAutoLogin => _loadingAutoLogin;
  String? get loginError => _loginError;
  List<Media> get mediaList => _mediaList;
  String? get deviceName => deviceInfo?['name'];
  String? get campaign => campaignName;

  AppState() {
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    accessCode = prefs.getString('accessCode');
    password = prefs.getString('password');
    campaignName = prefs.getString('campaignName');
    final deviceJson = prefs.getString('deviceInfo');
    if (deviceJson != null) deviceInfo = jsonDecode(deviceJson);
    final mediaJson = prefs.getString('mediaList');
    if (mediaJson != null) {
      final l = jsonDecode(mediaJson) as List;
      _mediaList = l.map((e) => Media.fromJson(e)).toList();
    }
    // Nếu có accessCode+password thì auto-login lại để lấy media mới
    if (accessCode != null && password != null) {
      final ok = await attemptLoginFromSaved();
      if (!ok) {
        // Nếu lỗi API thì vẫn dùng mediaList cũ
        _isLoggedIn = _mediaList.isNotEmpty;
      }
    } else {
      _isLoggedIn = false;
    }
    _loadingAutoLogin = false;
    notifyListeners();
  }

  Future<bool> login(String code, String pass) async {
    _loadingAutoLogin = true;
    notifyListeners();
    final resp = await _api.loginAndFetchMedia(code, pass);
    _loadingAutoLogin = false;
    if (resp != null &&
        resp['device'] != null &&
        resp['content'] != null &&
        resp['content']['media'] != null) {
      accessCode = code;
      password = pass;
      deviceInfo = resp['device'] as Map<String, dynamic>;
      campaignName = resp['content']['campaignName'];
      final media = Media.fromJson(resp['content']['media']);
      _mediaList = [media];
      await _saveCurrentState();
      _isLoggedIn = true;
      _loginError = null;
      notifyListeners();
      return true;
    } else {
      _loginError =
          'Sai mã truy cập hoặc mật khẩu, hoặc server không phản hồi.';
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> attemptLoginFromSaved() async {
    if (accessCode == null || password == null) return false;
    final resp = await _api.loginAndFetchMedia(accessCode!, password!);
    if (resp != null &&
        resp['device'] != null &&
        resp['content'] != null &&
        resp['content']['media'] != null) {
      deviceInfo = resp['device'] as Map<String, dynamic>;
      campaignName = resp['content']['campaignName'];
      final media = Media.fromJson(resp['content']['media']);
      _mediaList = [media];
      await _saveCurrentState();
      _isLoggedIn = true;
      _loginError = null;
      return true;
    }
    // Dùng media đã lưu cục bộ nếu có, trạng thái vẫn là login thành công (nếu media đó còn)
    _isLoggedIn = _mediaList.isNotEmpty;
    return false;
  }

  Future<void> _saveCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessCode', accessCode ?? '');
    await prefs.setString('password', password ?? '');
    if (deviceInfo != null)
      await prefs.setString('deviceInfo', jsonEncode(deviceInfo));
    await prefs.setString('campaignName', campaignName ?? '');
    await prefs.setString(
      'mediaList',
      jsonEncode(_mediaList.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> logout() async {
    accessCode = null;
    password = null;
    deviceInfo = null;
    campaignName = null;
    _mediaList = [];
    _isLoggedIn = false;
    _loginError = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
