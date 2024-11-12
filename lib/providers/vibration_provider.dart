import 'package:vibration/vibration.dart';

class VibrationProvider {
  bool? _canVibrate;

  initialize() async {
    _canVibrate = await Vibration.hasVibrator();
  }

  bool? get canVibrate => _canVibrate;

  void vibrate({
    int duration = 500,
    List<int> pattern = const [],
    int repeat = -1,
    List<int> intensities = const [],
    int amplitude = -1,
  }) {
    if (_canVibrate!) {
      Vibration.vibrate(
        duration: duration,
        pattern: pattern,
        repeat: repeat,
        intensities: intensities,
        amplitude: amplitude,
      );
    }
  }
}
