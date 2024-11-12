import 'dart:async';

import 'package:BubbleBee/helpers/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';

import '../get_it.dart';

class GameAdTracker extends ChangeNotifier {
  // Counts for different game types
  late int gamesUntilAd;

  final ValueNotifier<bool> _initialized = ValueNotifier(false);

  LazyBox<String> get box => getIt.get<LazyBox<String>>();

  // Constructor
  GameAdTracker() {
    loadFromLocalStorage();
  }

  @override
  dispose() {
    _initialized.dispose();
    super.dispose();
  }

  // Load stored data from local storage
  Future<void> loadFromLocalStorage() async {
    final data = await box.get(adTrackerPath);
    gamesUntilAd = int.tryParse(data ?? '3') ?? 3;
    _initialized.value = true;
  }

  Future<bool> isInitialized() async {
    if (_initialized.value) return true;

    Completer<bool> completer = Completer();
    _initialized.addListener(() async {
      completer.complete(_initialized.value);
    });
    return completer.future;
  }

  // Save current data to local storage
  Future<void> saveToLocalStorage() async {
    await box.put(adTrackerPath, gamesUntilAd.toString());
  }

  updateGamesUntilAd(int value) {
    gamesUntilAd += value;

    return shouldShowAd();
  }

  bool shouldShowAd() {
    if (gamesUntilAd <= 0) {
      gamesUntilAd = 5;
      notifyListeners();
      saveToLocalStorage();
      return true;
    } else {
      notifyListeners();
      saveToLocalStorage();
      return false;
    }
  }
}
