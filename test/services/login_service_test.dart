import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techare_application_comp3003/services/login_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('keyFor', () {
    test('generates a namespaced key from email and base key', () {
      expect(
        LoginService.keyFor('user@test.com', 'phone_age'),
        'user@test.com_phone_age',
      );
    });

    test('works with any base key string', () {
      expect(
        LoginService.keyFor('a@b.com', 'charging_habit'),
        'a@b.com_charging_habit',
      );
    });
  });

  group('key()', () {
    test('uses guest prefix when nobody is logged in', () async {
      final k = await LoginService.key('phone_age');
      expect(k, 'guest_phone_age');
    });

    test('uses the logged-in email as prefix', () async {
      SharedPreferences.setMockInitialValues({'': 'user@test.com'});
      final k = await LoginService.key('phone_age');
      expect(k, 'user@test.com_phone_age');
    });
  });

  group('currentUser()', () {
    test('returns null when nobody is logged in', () async {
      expect(await LoginService.currentUser(), isNull);
    });

    test('returns the logged-in email', () async {
      SharedPreferences.setMockInitialValues({'': 'user@test.com'});
      expect(await LoginService.currentUser(), 'user@test.com');
    });
  });

  group('currentUserName()', () {
    test('returns User when nobody is logged in', () async {
      expect(await LoginService.currentUserName(), 'User');
    });

    test('returns stored name for the logged-in user', () async {
      SharedPreferences.setMockInitialValues({
        '': 'user@test.com',
        'user@test.com_name': 'Alice',
      });
      expect(await LoginService.currentUserName(), 'Alice');
    });

    test('returns User when name key is missing for current user', () async {
      SharedPreferences.setMockInitialValues({'': 'user@test.com'});
      expect(await LoginService.currentUserName(), 'User');
    });
  });

  group('register()', () {
    test('returns true and creates account', () async {
      final success = await LoginService.register(
        email: 'new@test.com',
        password: 'pass123',
        name: 'New User',
      );
      expect(success, isTrue);
    });

    test('saves password and name to SharedPreferences', () async {
      await LoginService.register(
        email: 'new@test.com',
        password: 'pass123',
        name: 'New User',
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('new@test.com_password'), 'pass123');
      expect(prefs.getString('new@test.com_name'), 'New User');
    });

    test('sets the current user after registration', () async {
      await LoginService.register(
        email: 'new@test.com',
        password: 'pass123',
        name: 'New User',
      );
      expect(await LoginService.currentUser(), 'new@test.com');
    });

    test('returns false if email already exists', () async {
      SharedPreferences.setMockInitialValues({
        'existing@test.com_password': 'oldpass',
      });
      final success = await LoginService.register(
        email: 'existing@test.com',
        password: 'newpass',
        name: 'Duplicate',
      );
      expect(success, isFalse);
    });

    test('does not overwrite existing account data on duplicate email', () async {
      SharedPreferences.setMockInitialValues({
        'existing@test.com_password': 'oldpass',
        'existing@test.com_name': 'Original',
      });
      await LoginService.register(
        email: 'existing@test.com',
        password: 'newpass',
        name: 'Duplicate',
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('existing@test.com_password'), 'oldpass');
      expect(prefs.getString('existing@test.com_name'), 'Original');
    });
  });

  group('login()', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'user@test.com_password': 'correct123',
      });
    });

    test('returns true with correct credentials', () async {
      expect(await LoginService.login('user@test.com', 'correct123'), isTrue);
    });

    test('sets current user on successful login', () async {
      await LoginService.login('user@test.com', 'correct123');
      expect(await LoginService.currentUser(), 'user@test.com');
    });

    test('returns false with wrong password', () async {
      expect(await LoginService.login('user@test.com', 'wrongpass'), isFalse);
    });

    test('returns false for unknown email', () async {
      expect(await LoginService.login('nobody@test.com', 'pass'), isFalse);
    });

    test('does not set current user on failed login', () async {
      await LoginService.login('user@test.com', 'wrongpass');
      expect(await LoginService.currentUser(), isNull);
    });
  });

  group('logout()', () {
    test('clears the current user', () async {
      SharedPreferences.setMockInitialValues({'': 'user@test.com'});
      await LoginService.logout();
      expect(await LoginService.currentUser(), isNull);
    });

    test('is a no-op when nobody is logged in', () async {
      await expectLater(LoginService.logout(), completes);
    });
  });

  group('deleteAccount()', () {
    test('removes all keys belonging to the current user', () async {
      SharedPreferences.setMockInitialValues({
        '': 'user@test.com',
        'user@test.com_password': 'pass',
        'user@test.com_name': 'User',
        'user@test.com_phone_age': '2y 0m',
        'user@test.com_phone_brand': 'Apple',
      });
      await LoginService.deleteAccount();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user@test.com_password'), isNull);
      expect(prefs.getString('user@test.com_name'), isNull);
      expect(prefs.getString('user@test.com_phone_age'), isNull);
      expect(prefs.getString('user@test.com_phone_brand'), isNull);
    });

    test('logs out the user', () async {
      SharedPreferences.setMockInitialValues({
        '': 'user@test.com',
        'user@test.com_password': 'pass',
      });
      await LoginService.deleteAccount();
      expect(await LoginService.currentUser(), isNull);
    });

    test('does not remove data belonging to other users', () async {
      SharedPreferences.setMockInitialValues({
        '': 'user@test.com',
        'user@test.com_password': 'pass',
        'other@test.com_password': 'otherpass',
        'other@test.com_name': 'Other',
      });
      await LoginService.deleteAccount();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('other@test.com_password'), 'otherpass');
      expect(prefs.getString('other@test.com_name'), 'Other');
    });

    test('is a no-op when nobody is logged in', () async {
      await expectLater(LoginService.deleteAccount(), completes);
    });
  });

  group('setDemoAccount()', () {
    test('creates demo account with correct credentials', () async {
      await LoginService.setDemoAccount();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('amina@demo.com_password'), 'demo123');
      expect(prefs.getString('amina@demo.com_name'), 'Amina');
    });

    test('seeds phone profile data for the demo account', () async {
      await LoginService.setDemoAccount();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('amina@demo.com_phone_age'), '2y 3m');
      expect(prefs.getString('amina@demo.com_charging_habit'), '1.0');
      expect(prefs.getString('amina@demo.com_phone_brand'), 'Apple');
    });

    test('does not overwrite existing demo account data', () async {
      SharedPreferences.setMockInitialValues({
        'amina@demo.com_password': 'custompass',
        'amina@demo.com_name': 'Custom Amina',
      });
      await LoginService.setDemoAccount();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('amina@demo.com_password'), 'custompass');
      expect(prefs.getString('amina@demo.com_name'), 'Custom Amina');
    });
  });
}
