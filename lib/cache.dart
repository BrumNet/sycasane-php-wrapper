import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  clear() async {
    if (_sharedPrefs != null) {
      _sharedPrefs?.clear();
    }
  }

  String? get user {
    return _sharedPrefs?.getString('user');
  }

  set user(String? value) {
    _sharedPrefs?.setString('user', value!);
  }

  String? get privilege {
    return _sharedPrefs?.getString('privilege');
  }

  set privilege(String? value) {
    _sharedPrefs?.setString('privilege', value!);
  }

  String? get fcmToken {
    return _sharedPrefs?.getString('fcmToken');
  }

  set fcmToken(String? value) {
    _sharedPrefs?.setString('fcmToken', value!);
  }

  bool? get setToken {
    return _sharedPrefs?.getBool('setToken');
  }

  set setToken(bool? value) {
    _sharedPrefs?.setBool('setToken', value!);
  }
}

final prefs = SharedPrefs();
