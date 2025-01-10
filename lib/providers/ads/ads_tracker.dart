import 'dart:async';

import 'package:BubbleBee/helpers/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

import '../get_it.dart';
import '../remote_config_provider.dart';

const adCountMax = 1;

class GameAdTracker extends ChangeNotifier {
  // Counts for different game types
  late int gamesUntilAd;

  final ValueNotifier<bool> _initialized = ValueNotifier(false);

  int get adState => getIt.get<RemoteConfigProvider>().adState;

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
    gamesUntilAd = int.tryParse(data ?? '$adCountMax') ?? adCountMax;
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

    print('Games until ad: $gamesUntilAd');

    return shouldShowAd();
  }

  bool shouldShowAd() {
    if (kDebugMode && false) return false;

    if (gamesUntilAd <= 0) {
      notifyListeners();
      saveToLocalStorage();
      return true;
    } else {
      notifyListeners();
      saveToLocalStorage();
      return false;
    }
  }

  reset() {
    gamesUntilAd = adCountMax;
  }
}
