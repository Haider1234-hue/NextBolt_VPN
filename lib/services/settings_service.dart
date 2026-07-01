import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const _keyKillSwitch = 'kill_switch';
  static const _keyAutoConnect = 'auto_connect';
  static const _keyLanguage = 'language';
  static const _keyProtocol = 'protocol';

  bool _killSwitch = false;
  bool _autoConnect = false;
  String _language = 'English';
  String _protocol = 'WireGuard';
  bool _loaded = false;

  bool get killSwitch => _killSwitch;
  bool get autoConnect => _autoConnect;
  String get language => _language;
  String get protocol => _protocol;
  bool get loaded => _loaded;

  static const Map<String, Locale> _localeMap = {
    'English': Locale('en'),
    'Español': Locale('es'),
    'Deutsch': Locale('de'),
    'Français': Locale('fr'),
  };

  Locale get locale => _localeMap[_language] ?? const Locale('en');

  SettingsService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _killSwitch = prefs.getBool(_keyKillSwitch) ?? false;
    _autoConnect = prefs.getBool(_keyAutoConnect) ?? false;
    _language = prefs.getString(_keyLanguage) ?? 'English';
    _protocol = prefs.getString(_keyProtocol) ?? 'WireGuard';
    _loaded = true;
    notifyListeners();
  }

  Future<void> setKillSwitch(bool value) async {
    _killSwitch = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKillSwitch, value);
  }

  Future<void> setAutoConnect(bool value) async {
    _autoConnect = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoConnect, value);
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }

  Future<void> setProtocol(String value) async {
    _protocol = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProtocol, value);
  }
}
