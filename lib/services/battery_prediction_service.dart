import 'package:shared_preferences/shared_preferences.dart';
import 'login_service.dart';

// holds the result of a battery prediction run
class BatteryPredictionResult {
  final bool canPredict;
  final String insufficientDataMessage;
  final double currentExpectedCapacity;
  final double predicted1Month;
  final double predicted3Months;
  final double predicted6Months;
  final double predicted12Months;
  final int estimatedCycles;
  final String confidenceLabel;
  final String recommendation;

  const BatteryPredictionResult({
    required this.canPredict,
    required this.insufficientDataMessage,
    required this.currentExpectedCapacity,
    required this.predicted1Month,
    required this.predicted3Months,
    required this.predicted6Months,
    required this.predicted12Months,
    required this.estimatedCycles,
    required this.confidenceLabel,
    required this.recommendation,
  });
}

class BatteryPredictionService {

  // nasa linear regression coefficients from nasa Li-ion dataset
  static const double _nasaSlope = -0.00038;

  // intercept set to 1.0 so cycle 0 = 100%
  static const double _nasaIntercept = 1.0;

 //target cycle based on brand data and release year, default as 800 to meet EU legislation baseline for smart devices
  static int _getTargetCycles(String brand, int releaseYear) {
    switch (brand.toLowerCase()) {
      case 'apple':
        // iphone 15+ 2023+ at 1,000 cycles, iphone 14 and earlier at 500
        return releaseYear >= 2023 ? 1000 : 500;
      case 'google':
        // pixel 8a+ (2024+) at 1,000 cycles to 80%
        // pixel 3-8 pro (2018-2023) at 800 cycles
        // else no official data, falls back to li-ion baseline
        if (releaseYear >= 2024) return 1000;
        if (releaseYear >= 2018) return 800;
        return 500;
      case 'samsung':
        // galaxy s21 era (2021+) rated at 2,000 cycles per eu energy label data
        // pre-s21: falls back to general li-ion baseline
        return releaseYear >= 2021 ? 2000 : 500;
      default:
        // eu regulation minimum baseline
        return 800;
    }
  }

  // scales the nasa slope to the device's rated cycle life
  // formula: slope_adjusted = nasa_slope * (500 / target_cycles)
  static double _adjustedSlope(int targetCycles) {
    return _nasaSlope * (500 / targetCycles);
  }

  // main prediction method - reads namespaced keys for the current user
  static Future<BatteryPredictionResult> predict() async {
    final prefs = await SharedPreferences.getInstance();

    final phoneAgeKey      = await LoginService.key('phone_age');
    final chargingHabitKey = await LoginService.key('charging_habit');
    final brandKey         = await LoginService.key('phone_brand');

    final phoneAge      = prefs.getString(phoneAgeKey)      ?? '';
    final chargingHabit = prefs.getString(chargingHabitKey) ?? '';
    final brand         = prefs.getString(brandKey)         ?? 'Other';

    // check both settings are set
    if (phoneAge.isEmpty || chargingHabit.isEmpty) {
      return const BatteryPredictionResult(
        canPredict: false,
        insufficientDataMessage: 'Please set your phone age and charging habits in Settings to unlock battery predictions.',
        currentExpectedCapacity: 0,
        predicted1Month: 0,
        predicted3Months: 0,
        predicted6Months: 0,
        predicted12Months: 0,
        estimatedCycles: 0,
        confidenceLabel: 'None',
        recommendation: '',
      );
    }

    // parse phone age from '2y 3m' format
    final ageMatch = RegExp(r'(\d+)y (\d+)m').firstMatch(phoneAge);
    if (ageMatch == null) {
      return const BatteryPredictionResult(
        canPredict: false,
        insufficientDataMessage: 'Could not read phone age. Please update it in Settings.',
        currentExpectedCapacity: 0,
        predicted1Month: 0,
        predicted3Months: 0,
        predicted6Months: 0,
        predicted12Months: 0,
        estimatedCycles: 0,
        confidenceLabel: 'None',
        recommendation: '',
      );
    }

    // convert age to total days
    final years     = int.parse(ageMatch.group(1)!);
    final months    = int.parse(ageMatch.group(2)!);
    final totalDays = (years * 365) + (months * 30);

    // derive release year from phone age so we don't need a separate field
    final releaseYear = DateTime.now().year - years;

    // parse cycles per day from charging habit
    final cyclesPerDay = double.tryParse(chargingHabit) ?? 1.0;

    // estimate total cycles so far
    final estimatedCycles = (totalDays * cyclesPerDay).round();

    // get target cycles and adjusted slope for this device
    final targetCycles = _getTargetCycles(brand, releaseYear);
    final slope        = _adjustedSlope(targetCycles);

    // calculate current expected capacity
    final currentCapacity = _predictCapacity(estimatedCycles, slope);

    // project forward 1, 3, 6 and 12 months
    final futureCycles1  = estimatedCycles + (30  * cyclesPerDay).round();
    final futureCycles3  = estimatedCycles + (90  * cyclesPerDay).round();
    final futureCycles6  = estimatedCycles + (180 * cyclesPerDay).round();
    final futureCycles12 = estimatedCycles + (365 * cyclesPerDay).round();

    // calculated prediction using the linear regression equation
    final pred1  = _predictCapacity(futureCycles1,  slope);
    final pred3  = _predictCapacity(futureCycles3,  slope);
    final pred6  = _predictCapacity(futureCycles6,  slope);
    final pred12 = _predictCapacity(futureCycles12, slope);

    return BatteryPredictionResult(
      canPredict: true,
      insufficientDataMessage: '',
      currentExpectedCapacity: currentCapacity,
      predicted1Month: pred1,
      predicted3Months: pred3,
      predicted6Months: pred6,
      predicted12Months: pred12,
      estimatedCycles: estimatedCycles,
      confidenceLabel: _confidenceLabel(brand),
      recommendation: _buildRecommendation(
        currentCapacity: currentCapacity,
        pred12: pred12,
      ),
    );
  }

  // applies the linear regression equation and clamps to 0-100%
  static double _predictCapacity(int cycles, double slope) {
    return ((slope * cycles + _nasaIntercept) * 100).clamp(0.0, 100.0);
  }

  // confidence reflects quality of manufacturer battery cycle data available
  // high   = clean official tiers with no ambiguity (apple)
  // medium = official data exists but varies across models within the same era (samsung, google)
  // low    = unknown brand, falling back to eu ecodesign baseline estimate
  static String _confidenceLabel(String brand) {
    switch (brand.toLowerCase()) {
      case 'apple':
        return 'High';
      case 'samsung':
      case 'google':
        return 'Medium';
      default:
        return 'Low';
    }
  }

  // recommendation based on est* capacity
  static String _buildRecommendation({
    required double currentCapacity,
    required double pred12,
  }) {
    if (currentCapacity < 80) {
      return 'Your battery capacity is estimated below 80%. Consider a battery replacement to restore full performance.';
    }

    if (pred12 < 80) {
      return 'Your battery is projected to fall below 80% within 12 months. Plan for a replacement in the coming year.';
    }

    if (pred12 < 85) {
      return 'Your battery health looks stable but is declining. Avoid overnight charging and extreme temperatures to slow degradation.';
    }

    return 'Your battery health looks good. Keep running regular diagnostics to track changes over time.';
  }
}