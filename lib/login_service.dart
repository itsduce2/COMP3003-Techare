import 'package:shared_preferences/shared_preferences.dart';

class LoginService {

  static const String _currentUser = '';

  // base key for user data  
  static Future<String> key(String baseKey) async {
    final user = await currentUser() ?? 'guest';
    return '${user}_$baseKey';
  }

  // synchronous version for use where async isn't possible
  // requires the email to be passed in
  static String keyFor(String email, String baseKey) {
    return '${email}_$baseKey';
  }

  // returns the currently logged in user's email
  static Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUser);
  }

  // returns the currently logged in user's name
  static Future<String> currentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString(_currentUser) ?? '';
    return prefs.getString('${user}_name') ?? 'User';
  }

  // logs in with email and password, returns true if successful
  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('${email}_password');
    if (stored == null || stored != password) return false;
    await prefs.setString(_currentUser, email);
    return true;
  }

  // registers a new account, returns false if email already exists
  static Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('${email}_password') != null) return false;
    await prefs.setString('${email}_password', password);
    await prefs.setString('${email}_name', name);
    await prefs.setString(_currentUser, email);
    return true;
  }

  // logs out the current user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUser);
  }

  // deletes the current user's account and all their data
  static Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString(_currentUser);
    if (user == null) return;
    // remove all keys belonging to this user
    final keys = prefs.getKeys().where((k) => k.startsWith('${user}_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    await prefs.remove(_currentUser);
  }

  // seeds amina's demo account with pre-loaded data on first run
  static Future<void> setDemoAccount() async {
    final prefs = await SharedPreferences.getInstance();
    const email = 'amina@demo.com';
    
    // only seed if account doesn't already exist
    if (prefs.getString('${email}_password') != null) return;

    // demo account with data
    await prefs.setString('${email}_password', 'demo123');
    await prefs.setString('${email}_name', 'Amina');
    await prefs.setString('${email}_phone_age', '2y 3m');
    await prefs.setString('${email}_phone_age_set_date', DateTime.now().toIso8601String());
    await prefs.setString('${email}_charging_habit', '1.0');
    await prefs.setString('${email}_phone_brand', 'Apple');
  }
}