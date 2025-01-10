class GameStatistics {
  /// States the player's unique id
  late String _id;

  /// States the player's name
  late String _name;

  /// States the games current level
  late int _currentLevel;

  /// States the number of falls and the depth of the falls
  /// length represents the number of falls
  /// the value at each index represents the depth of the fall
  late List<int> _totalFalls;

  /// States all levels played, repeated, passed, failed, and there time saved
  late List<LevelState> _levels;

  /// States the number of taps
  late int _totalNumberOfTaps;

  /// States the total number of seconds saved
  late int _totalSecondsSaved;

  GameStatistics(
      {required String id,
      required String name,
      int? currentLevel,
      List<int>? totalFalls,
      List<LevelState>? levels,
      int? totalNumberOfTaps,
      int? totalSecondsSaved}) {
    _id = id;
    _name = name;
    _currentLevel = currentLevel ?? 1;
    _totalFalls = totalFalls ?? [];
    _levels = levels ?? [];
    _totalNumberOfTaps = totalNumberOfTaps ?? 0;
    _totalSecondsSaved = totalSecondsSaved ?? 0;
  }

  factory GameStatistics.fromMap(Map<String, dynamic> map) => GameStatistics(
      id: map['id'],
      name: map['name'],
      currentLevel: map['currentLevel'] < 1 ? 1 : map['currentLevel'],
      totalFalls: List<int>.from(map['totalFalls']),
      levels: List<LevelState>.from(
          map['levels'].map((x) => LevelState.fromMap(x))),
      totalNumberOfTaps: map['totalNumberOfTaps'],
      totalSecondsSaved: map['totalSecondsSaved']);

  GameStatistics copyWith({
    String? id,
    String? name,
    int? currentLevel,
    List<int>? totalFalls,
    List<LevelState>? levels,
    int? totalNumberOfTaps,
    int? totalSecondsSaved,
  }) {
    return GameStatistics(
      id: id ?? _id,
      name: name ?? _name,
      currentLevel: currentLevel ?? _currentLevel,
      totalFalls: totalFalls ?? _totalFalls,
      levels: levels ?? _levels,
      totalNumberOfTaps: totalNumberOfTaps ?? _totalNumberOfTaps,
      totalSecondsSaved: totalSecondsSaved ?? _totalSecondsSaved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'currentLevel': _currentLevel,
      'totalFalls': _totalFalls,
      'levels': _levels.map((x) => x.toMap()).toList(),
      'totalNumberOfTap': _totalNumberOfTaps,
      'totalSecondsSaved': _totalSecondsSaved
    };
  }

  /// Returns the player's unique id
  String get id => _id;

  /// Returns the player's name
  String get name => _name;

  /// Returns the games current level
  int get currentLevel => _currentLevel;

  /// Returns the number of falls and the depth of the falls
  List<int> get totalFalls => _totalFalls;

  /// Returns all levels played, repeated, passed, failed, and there time saved
  List<LevelState> get levels => _levels;

  /// Returns the number of taps
  int get totalNumberOfTaps => _totalNumberOfTaps;

  /// Returns the total number of seconds saved
  int get totalSecondsSaved => _totalSecondsSaved;

  /// Updates the player's name
  void updateName(String name) {
    _name = name;
  }

  /// Updates the games current level
  Map<String, dynamic> updateCurrentLevel(LevelState levelState) {
    _levels.add(levelState);
    _totalNumberOfTaps += levelState.numberOfTaps;
    _totalSecondsSaved += levelState.timeSaved;
    if (levelState.levelDifference < 0) {
      _totalFalls.add(levelState.levelDifference.abs());
    }
    _currentLevel += levelState.levelDifference;

    return toMap();
  }
}

class LevelState {
  int levelDifference;
  int timeSaved;
  int numberOfTaps;
  int level;

  LevelState(
      {required this.levelDifference,
      required this.timeSaved,
      required this.level,
      required this.numberOfTaps});

  factory LevelState.fromMap(Map<String, dynamic> map) => LevelState(
      levelDifference: map['levelDifference'],
      timeSaved: map['timeSaved'],
      level: map['level'],
      numberOfTaps: map['numberOfTaps']);

  Map<String, dynamic> toMap() {
    return {
      'levelDifference': levelDifference,
      'timeSaved': timeSaved,
      'level': level,
      'numberOfTaps': numberOfTaps
    };
  }
}
