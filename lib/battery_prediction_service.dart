import 'package:shared_preferences/shared_preferences.dart';

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

  // main prediction method - reads phone_age and charging_habit from SharedPreferences
  static Future<BatteryPredictionResult> predict() async {
    final prefs = await SharedPreferences.getInstance();

    final phoneAge = prefs.getString('phone_age') ?? '';
    final chargingHabit = prefs.getString('charging_habit') ?? '';

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
    final years = int.parse(ageMatch.group(1)!);
    final months = int.parse(ageMatch.group(2)!);
    final totalDays = (years * 365) + (months * 30);

    // parse cycles per day from charging habit
    final cyclesPerDay = double.tryParse(chargingHabit) ?? 1.0;

    // estimate total cycles so far
    final estimatedCycles = (totalDays * cyclesPerDay).round();

    // calculate current expected capacity
    final currentCapacity = _predictCapacity(estimatedCycles);

    // project forward 1, 3, 6 and 12 months
    final futureCycles1  = estimatedCycles + (30  * cyclesPerDay).round();
    final futureCycles3  = estimatedCycles + (90  * cyclesPerDay).round();
    final futureCycles6  = estimatedCycles + (180 * cyclesPerDay).round();
    final futureCycles12 = estimatedCycles + (365 * cyclesPerDay).round();

    // calculated prediction using the linear regression equation
    final pred1  = _predictCapacity(futureCycles1);
    final pred3  = _predictCapacity(futureCycles3);
    final pred6  = _predictCapacity(futureCycles6);
    final pred12 = _predictCapacity(futureCycles12);

    return BatteryPredictionResult(
      canPredict: true,
      insufficientDataMessage: '',
      currentExpectedCapacity: currentCapacity,
      predicted1Month: pred1,
      predicted3Months: pred3,
      predicted6Months: pred6,
      predicted12Months: pred12,
      estimatedCycles: estimatedCycles,
      confidenceLabel: _confidenceLabel(cyclesPerDay),
      recommendation: _buildRecommendation(
        currentCapacity: currentCapacity,
        pred12: pred12,
      ),
    );
  }

  // applies the linear regression equation and clamps to 0-100%
  static double _predictCapacity(int cycles) {
    return ((_nasaSlope * cycles + _nasaIntercept) * 100).clamp(0.0, 100.0);
  }

  // confidence is medium if cycles per day is a round number
  // high if user has entered cycles to a decimal
  static String _confidenceLabel(double cyclesPerDay) {
    if (cyclesPerDay == cyclesPerDay.roundToDouble()) return 'Medium';
    return 'High';
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