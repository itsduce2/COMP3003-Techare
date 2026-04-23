import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techare_application_comp3003/services/battery_prediction_service.dart';

const String _email = 'test@test.com';

// Builds the SharedPreferences map for a logged-in user with device profile.
Map<String, Object> _prefs({
  required String age,
  required String habit,
  required String brand,
}) =>
    {
      '': _email,
      '${_email}_phone_age': age,
      '${_email}_charging_habit': habit,
      '${_email}_phone_brand': brand,
    };

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── Insufficient data ────────────────────────────────────────────────────────

  group('predict() - insufficient data', () {
    test('returns canPredict=false when SharedPreferences is empty', () async {
      final result = await BatteryPredictionService.predict();
      expect(result.canPredict, isFalse);
      expect(result.insufficientDataMessage, isNotEmpty);
    });

    test('returns canPredict=false when phone_age is missing', () async {
      SharedPreferences.setMockInitialValues({
        '': _email,
        '${_email}_charging_habit': '1.0',
        '${_email}_phone_brand': 'Apple',
      });
      final result = await BatteryPredictionService.predict();
      expect(result.canPredict, isFalse);
    });

    test('returns canPredict=false when charging_habit is missing', () async {
      SharedPreferences.setMockInitialValues({
        '': _email,
        '${_email}_phone_age': '2y 0m',
        '${_email}_phone_brand': 'Apple',
      });
      final result = await BatteryPredictionService.predict();
      expect(result.canPredict, isFalse);
    });

    test('returns canPredict=false when phone_age format is invalid', () async {
      SharedPreferences.setMockInitialValues(
        _prefs(age: 'invalid-format', habit: '1.0', brand: 'Apple'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.canPredict, isFalse);
    });
  });

  // ── Apple ────────────────────────────────────────────────────────────────────
  // Apple 2024+ target: 1000 cycles → adjusted slope = -0.00038 * (500/1000) = -0.00019
  // 2y 0m at 1.0 cycles/day → 730 estimated cycles
  // currentCapacity = (1 - 0.00019 * 730) * 100 ≈ 86.13%
  // pred12 cycles = 730 + 365 = 1095 → capacity ≈ 79.20% (< 80%)

  group('predict() - Apple', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(
        _prefs(age: '2y 0m', habit: '1.0', brand: 'Apple'),
      );
    });

    test('returns canPredict=true', () async {
      final result = await BatteryPredictionService.predict();
      expect(result.canPredict, isTrue);
    });

    test('estimates 730 cycles for a 2-year-old phone at 1.0 cycles/day', () async {
      final result = await BatteryPredictionService.predict();
      expect(result.estimatedCycles, 730);
    });

    test('currentExpectedCapacity is ~86.1% (1000-cycle target, 730 cycles used)', () async {
      final result = await BatteryPredictionService.predict();
      expect(result.currentExpectedCapacity, closeTo(86.13, 0.1));
    });

    test('predicted12Months falls below 80%', () async {
      final result = await BatteryPredictionService.predict();
      expect(result.predicted12Months, closeTo(79.20, 0.1));
      expect(result.predicted12Months, lessThan(80.0));
    });

    test('predictions are ordered: current > 1mo > 3mo > 6mo > 12mo', () async {
      final r = await BatteryPredictionService.predict();
      expect(r.currentExpectedCapacity, greaterThan(r.predicted1Month));
      expect(r.predicted1Month, greaterThan(r.predicted3Months));
      expect(r.predicted3Months, greaterThan(r.predicted6Months));
      expect(r.predicted6Months, greaterThan(r.predicted12Months));
    });

    test('confidence label is High', () async {
      final result = await BatteryPredictionService.predict();
      expect(result.confidenceLabel, 'High');
    });

    test('recommendation references a 12-month decline', () async {
      final result = await BatteryPredictionService.predict();
      expect(result.recommendation, contains('12 months'));
    });
  });

  // ── Samsung ──────────────────────────────────────────────────────────────────
  // Samsung 2021+ target: 2000 cycles → slope = -0.00038 * (500/2000) = -0.000095
  // 4y 0m at 1.0 cycles/day → 1460 estimated cycles
  // currentCapacity ≈ 86.13%, pred12 (1825 cycles) ≈ 82.66% → stable but declining

  group('predict() - Samsung', () {
    test('confidence label is Medium', () async {
      SharedPreferences.setMockInitialValues(
        _prefs(age: '2y 0m', habit: '1.0', brand: 'Samsung'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.confidenceLabel, 'Medium');
    });

    test('4-year Samsung 2021+ has pred12 in the stable-declining range (80–85%)', () async {
      SharedPreferences.setMockInitialValues(
        _prefs(age: '4y 0m', habit: '1.0', brand: 'Samsung'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.predicted12Months, greaterThanOrEqualTo(80.0));
      expect(result.predicted12Months, lessThan(85.0));
      expect(result.recommendation, contains('declining'));
    });

    test('2-year Samsung with low usage returns a looks-good recommendation', () async {
      SharedPreferences.setMockInitialValues(
        _prefs(age: '2y 0m', habit: '0.5', brand: 'Samsung'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.predicted12Months, greaterThan(85.0));
      expect(result.recommendation, contains('looks good'));
    });
  });

  // ── Google ───────────────────────────────────────────────────────────────────

  group('predict() - Google', () {
    test('confidence label is Medium', () async {
      SharedPreferences.setMockInitialValues(
        _prefs(age: '2y 0m', habit: '1.0', brand: 'Google'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.confidenceLabel, 'Medium');
    });
  });

  // ── Other brand ──────────────────────────────────────────────────────────────

  group('predict() - Other brand', () {
    test('confidence label is Low', () async {
      SharedPreferences.setMockInitialValues(
        _prefs(age: '2y 0m', habit: '1.0', brand: 'Other'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.confidenceLabel, 'Low');
    });
  });

  // ── Recommendations ──────────────────────────────────────────────────────────

  group('predict() - recommendations', () {
    test('current capacity < 80% triggers replacement recommendation', () async {
      // Apple pre-2023 (5-year-old → released 2021 < 2023 → 500-cycle target)
      // slope = -0.00038, 1825 cycles → capacity ≈ 30.65%
      SharedPreferences.setMockInitialValues(
        _prefs(age: '5y 0m', habit: '1.0', brand: 'Apple'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.currentExpectedCapacity, lessThan(80.0));
      expect(result.recommendation, contains('replacement'));
    });
  });

  // ── Capacity clamping ────────────────────────────────────────────────────────

  group('predict() - capacity clamping', () {
    test('currentExpectedCapacity is clamped to 0% for extreme usage', () async {
      // Other brand, 10y 0m, 5.0 cycles/day → ~18250 cycles → raw value ≈ -334%
      SharedPreferences.setMockInitialValues(
        _prefs(age: '10y 0m', habit: '5.0', brand: 'Other'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.currentExpectedCapacity, equals(0.0));
    });

    test('all predicted values stay within 0–100%', () async {
      SharedPreferences.setMockInitialValues(
        _prefs(age: '10y 0m', habit: '5.0', brand: 'Other'),
      );
      final r = await BatteryPredictionService.predict();
      for (final v in [
        r.currentExpectedCapacity,
        r.predicted1Month,
        r.predicted3Months,
        r.predicted6Months,
        r.predicted12Months,
      ]) {
        expect(v, greaterThanOrEqualTo(0.0));
        expect(v, lessThanOrEqualTo(100.0));
      }
    });

    test('brand-new phone (0y 0m) starts at or near 100%', () async {
      SharedPreferences.setMockInitialValues(
        _prefs(age: '0y 0m', habit: '1.0', brand: 'Samsung'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.currentExpectedCapacity, closeTo(100.0, 0.1));
    });
  });

  // ── Cycle estimation ─────────────────────────────────────────────────────────

  group('predict() - cycle estimation', () {
    test('converts years, months and cycles/day to total estimated cycles', () async {
      // 3y 6m at 2.0 cycles/day → totalDays = 3*365 + 6*30 = 1275 → 1275 * 2 = 2550
      SharedPreferences.setMockInitialValues(
        _prefs(age: '3y 6m', habit: '2.0', brand: 'Other'),
      );
      final result = await BatteryPredictionService.predict();
      expect(result.estimatedCycles, 2550);
    });
  });
}
