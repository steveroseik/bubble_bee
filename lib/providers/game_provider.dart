import 'dart:convert';
import 'dart:math';

import 'package:BubbleBee/Models/game_statistics.dart';
import 'package:BubbleBee/Models/level_data.dart';
import 'package:BubbleBee/helpers/constants.dart';
import 'package:BubbleBee/providers/ads/ads_provider.dart';
import 'package:BubbleBee/providers/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shortuid/shortuid.dart';

final gameProvider =
    ChangeNotifierProvider<GameProvider>((ref) => GameProvider(ref));

class GameProvider extends ChangeNotifier {
  late GameStatistics currentUser;
  ValueNotifier<GameState> state = ValueNotifier(GameState.idle);
  final Random _random = Random();
  final int gridExpansionInterval = 30; // Configurable grid expansion interval
  int gridWidth = 5;
  int gridHeight = 7;
  LevelData currentLevelData = LevelData.empty();
  LevelState? currentLevelState;

  final ChangeNotifierProviderRef<GameProvider> ref;

  GameProvider(this.ref);

  LazyBox<String> get box => getIt.get<LazyBox<String>>();
  AdsController get adsController => ref.read(adsProvider);

  int get currentLevel => currentUser.currentLevel;

  initializeGameData() async {
    currentUser = await loadUserData();
  }

  loadUserData() async {
    final data = await box.get(currentUserPath);
    if (data != null) {
      return GameStatistics.fromMap(jsonDecode(data));
    } else {
      final shortId = ShortUid.create();
      return GameStatistics(
          id: shortId,
          name: 'Player (${shortId.substring(shortId.length - 3)})',
          currentLevel: 1,
          totalFalls: [],
          levels: [],
          totalNumberOfTaps: 0);
    }
  }

  /// Generates the level data for the current level.
  LevelData generateLevelData() {
    updateGameState(GameState.idle);
    // Determine grid size based on the current level

    int baseGridWidth = 5;
    gridWidth = baseGridWidth + (currentLevel ~/ gridExpansionInterval);
    gridHeight =
        (gridWidth * 1.5).ceil(); // Make grid height 1.5 times the width

    int numberOfTaps = _calculateNumberOfTaps();

    // Generate smart random cells to tap
    List<(int, int)> tapCells =
        _generateSmartRandomCells(gridWidth, gridHeight, numberOfTaps);

    // Add 'do not tap' cells to increase complexity
    List<(int, int)> doNotTapCells = [];
    int numberOfDoNotTapCells =
        _calculateNumberOfNoTaps(); // Increase with level
    doNotTapCells = _generateSmartRandomCells(
        gridWidth, gridHeight, numberOfDoNotTapCells,
        exclude: tapCells.toSet());

    // Calculate the time limit based on the level and grid size
    double timeLimit = _calculateTimeLimit(gridWidth, gridHeight, numberOfTaps);

    // Return level data as a map
    currentLevelState = LevelState(
      level: currentLevel,
      levelDifference: 0,
      timeSaved: 0,
      numberOfTaps: 0,
    );
    currentLevelData = LevelData.fromMap({
      "level": currentLevel,
      "gridWidth": gridWidth,
      "gridHeight": gridHeight,
      "tapCells": tapCells,
      "doNotTapCells": doNotTapCells,
      "timeLimit": timeLimit,
    });
    return currentLevelData;
  }

  /// Smartly generates a set of unique random cells that should be tapped.
  List<(int, int)> _generateSmartRandomCells(
      int gridWidth, int gridHeight, int count,
      {Set<(int, int)> exclude = const {}}) {
    // Create a list of all possible cells in the grid
    List<(int, int)> availableCells = [];

    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        if (!exclude.contains((row, col))) {
          availableCells.add((row, col));
        }
      }
    }

    // Shuffle the available cells list for randomness
    availableCells.shuffle(_random);

    // Select the first `count` cells from the shuffled list
    return availableCells.take(count).toList();
  }

  /// Calculate the time limit for each level.
  double _calculateTimeLimit(int gridWidth, int gridHeight, int numberOfTaps) {
    // Average time needed for a player to tap one cell is 0.5 seconds
    double averageTapTime = 0.6 -
        (0.3 *
            ((currentLevel % gridExpansionInterval) / gridExpansionInterval));

    // Base time formula focuses more on the number of taps needed
    double baseTime = numberOfTaps * averageTapTime;

    // Adjust time hardness as level progresses
    int levelInCurrentGridSize = currentLevel % gridExpansionInterval;

    // Difficulty modifier: make the time reduction more gradual
    double difficultyModifier = (levelInCurrentGridSize /
        gridExpansionInterval); // Less aggressive reduction

    // A minimum time increment to keep the game challenging but fair
    double minimumTimeIncrement = 2.0 -
        (levelInCurrentGridSize /
            gridExpansionInterval); // Slower decrease in the minimum increment
// Calculate final time with a less steep reduction curve
    double finalTime =
        (baseTime + minimumTimeIncrement) - (difficultyModifier * 2);

    // Ensure time is at least 3.5 seconds to allow room for errors
    finalTime = finalTime < 3.5 ? 3.5 : finalTime;

    return finalTime;
  }

  int _calculateNumberOfTaps() {
    // Determine the grid size
    int baseMaxTiles = gridWidth * gridHeight;

    // Base number of taps
    int levelTiles = (baseMaxTiles * 0.25).ceil();

    int base = levelTiles;

    // Generate addition taps based on the level

    // Calculate the level factor
    double levelFactor =
        (currentLevel % gridExpansionInterval) / gridExpansionInterval;
    // Maximum number of tiles to tap
    int maxLevelTiles = (baseMaxTiles * 0.55).ceil();
    // Additional taps based on the level factor
    int additionalTaps = (levelFactor * maxLevelTiles).ceil();

    // Total number of taps
    int numberOfTaps = base + additionalTaps;

    return numberOfTaps;
  }

  int _calculateNumberOfNoTaps() {
    int baseMaxTiles = gridWidth * gridHeight;
    int levelTiles = (baseMaxTiles * 0.15).ceil();

    double levelFactor =
        (currentLevel % gridExpansionInterval) / gridExpansionInterval;
    double numberOfNoTaps = levelTiles * levelFactor;

    return numberOfNoTaps.ceil();
  }

  updateLevel(LevelState? levelState) async {
    if (levelState == null) return;
    final newData = currentUser.updateCurrentLevel(levelState);
    await box.put(currentUserPath, jsonEncode(newData));
  }

  retryLevel() async {
    currentLevelState?.levelDifference = 0;
    updateLevel(currentLevelState);
    generateLevelData();
    updateGameState(GameState.playing);
  }

  continuePlaying() {
    updateLevel(currentLevelState);
    generateLevelData();
    updateGameState(GameState.playing);
  }

  updateGameState(GameState newState, {bool notify = true}) {
    if (state.value == newState) return;
    state.value = newState;
    switch (state.value) {
      case GameState.idle:
        break;
      case GameState.playing:
        break;
      case GameState.won:
        currentLevelState?.levelDifference = 1;
        break;
      case GameState.lost:
        currentLevelState?.levelDifference =
            -((currentLevelState?.level ?? 1) ~/ 2);

      case GameState.paused:
        break;
    }

    if (notify) {
      notifyListeners();
    }
  }

  tapCell((int, int) at) {
    currentLevelData.grid[at.$1][at.$2].isTapped = true;
    notifyListeners();
    if (checkLevelCompleted()) {
      /// todo: fetch time save from game_screen
      // currentLevelState.timeSaved = timeRemaining.toInt();

      updateGameState(GameState.won);
    }
  }

  checkLevelCompleted() {
    if (currentLevelData.grid.any((sub) =>
        sub.any((cell) => cell.type == CellType.tap && !cell.isTapped))) {
      return false;
    }
    return true;
  }
}
