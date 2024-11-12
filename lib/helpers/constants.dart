import 'dart:ui';

const localStoragePath = 'local_storage';
const currentUserPath = 'current_user';
const adTrackerPath = 'ad_tracker';

const Color kNeonBlue = Color(0xFF4DD8F9);
const Color kVibrantPink = Color(0xFFFF66C4);
const Color kBrightYellow = Color(0xFFFFD700);
const Color kEnergeticOrange = Color(0xFFFF8C00);
const Color kLimeGreen = Color(0xFFA4DE02);

enum AdStatus {
  loading,
  loaded,
  failed,
}

enum GameState { idle, playing, won, lost, paused }
