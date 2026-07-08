import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _kToken = 'auth_token';
  static const _kPhone = 'user_phone';
  static const _kName = 'user_name';

  Future<String?> get token async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kToken);
    return (t == null || t.trim().isEmpty) ? null : t;
  }

  Future<String?> get phone async {
    final sp = await SharedPreferences.getInstance();
    final p = sp.getString(_kPhone);
    return (p == null || p.trim().isEmpty) ? null : p;
  }

  Future<String?> get name async {
    final sp = await SharedPreferences.getInstance();
    final n = sp.getString(_kName);
    return (n == null || n.trim().isEmpty) ? null : n;
  }

  Future<void> save({
    required String token,
    required String phone,
    String? name,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    await sp.setString(_kPhone, phone);
    if (name != null) {
      await sp.setString(_kName, name);
    }
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kPhone);
    await sp.remove(_kName);
  }
}

