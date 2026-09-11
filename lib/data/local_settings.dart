import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Per-device preferences (Ayarlar's three toggles) — not room state, so they
/// live in shared_preferences rather than Firebase.
class LocalSettings extends ChangeNotifier {
  static const _kVibration = 'set_vibration';
  static const _kShotCounter = 'set_shot_counter';
  static const _kKeepOn = 'set_keep_on';

  bool vibration = true;
  bool shotCounterVisible = true;
  bool keepScreenOn = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    vibration = prefs.getBool(_kVibration) ?? true;
    shotCounterVisible = prefs.getBool(_kShotCounter) ?? true;
    keepScreenOn = prefs.getBool(_kKeepOn) ?? false;
    if (keepScreenOn) _applyWakelock(true);
    notifyListeners();
  }

  Future<void> setVibration(bool value) async {
    vibration = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kVibration, value);
  }

  Future<void> setShotCounterVisible(bool value) async {
    shotCounterVisible = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kShotCounter, value);
  }

  Future<void> setKeepScreenOn(bool value) async {
    keepScreenOn = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kKeepOn, value);
    _applyWakelock(value);
  }

  // Screen Wake Lock support is inconsistent on older browsers — best-effort.
  void _applyWakelock(bool enable) {
    try {
      if (enable) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    } catch (_) {
      // ignore — not supported on this browser
    }
  }
}
