import 'package:flutter/material.dart';

class LevelData {
  final List<(int, int)> tapCells;
  final double timeLimit;
  final int currentLevel;
  final int gridWidth;
  final int gridHeight;
  final List<(int, int)> doNotTapCells;
  final List<List<Cell>> grid;

  LevelData({
    required this.tapCells,
    required this.timeLimit,
    required this.currentLevel,
    required this.gridWidth,
    required this.gridHeight,
    required this.doNotTapCells,
    required this.grid,
  });

  factory LevelData.fromMap(Map<String, dynamic> map) => LevelData(
        tapCells: List<(int, int)>.from(map['tapCells']),
        timeLimit: map['timeLimit'],
        currentLevel: map['level'],
        gridWidth: map['gridWidth'],
        gridHeight: map['gridHeight'],
        doNotTapCells: List<(int, int)>.from(map['doNotTapCells']),
        grid: generateGrid(map['gridHeight'], map['gridWidth'], map['tapCells'],
            map['doNotTapCells']),
      );

  factory LevelData.empty() => LevelData(
        tapCells: [],
        timeLimit: 0,
        currentLevel: 0,
        gridWidth: 0,
        gridHeight: 0,
        doNotTapCells: [],
        grid: [
          [Cell(type: CellType.empty)]
        ],
      );

  Map<String, dynamic> toMap() => {
        "level": currentLevel,
        "gridWidth": gridWidth,
        "gridHeight": gridHeight,
        "tapCells": tapCells,
        "doNotTapCells": doNotTapCells,
        "timeLimit": timeLimit,
      };

  static generateGrid(int width, int height, List<(int, int)> tapCells,
      List<(int, int)> doNotTapCells) {
    List<List<Cell>> grid = [];
    for (int i = 0; i < width; i++) {
      List<Cell> row = [];
      for (int j = 0; j < height; j++) {
        CellType type = CellType.empty;
        if (tapCells.contains((i, j))) {
          type = CellType.tap;
        } else if (doNotTapCells.contains((i, j))) {
          type = CellType.doNotTap;
        }
        row.add(Cell(type: type));
      }
      grid.add(row);
    }
    return grid;
  }
}

enum CellType { tap, doNotTap, empty }

class Cell {
  CellType type;
  bool isTapped;
  Cell({required this.type, this.isTapped = false});

  Color get color {
    switch (type) {
      case CellType.tap:
        return !isTapped ? Colors.white : Colors.amber;
      case CellType.doNotTap:
        return Colors.red;
      default:
        return Colors.amber;
    }
  }
}
