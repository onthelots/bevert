
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _speechPositiveThresholdKey = 'speechPositiveThreshold';
  static const double _defaultSpeechPositiveThreshold = 0.5;

  Future<double> getSpeechPositiveThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_speechPositiveThresholdKey) ?? _defaultSpeechPositiveThreshold;
  }

  Future<void> setSpeechPositiveThreshold(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speechPositiveThresholdKey, value);
  }
}
