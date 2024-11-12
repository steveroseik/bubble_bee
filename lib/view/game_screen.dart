import 'package:BubbleBee/Models/level_data.dart';
import 'package:BubbleBee/helpers/extensions.dart';
import 'package:BubbleBee/providers/audio/audio_provider.dart';
import 'package:BubbleBee/view/3d_button.dart';
import 'package:BubbleBee/view/dialogs/menu_dialog.dart';
import 'package:BubbleBee/view/dialogs/tutorial_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexagon/hexagon.dart';
import 'package:sizer/sizer.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../helpers/constants.dart';
import '../providers/game_provider.dart';
import '../providers/get_it.dart';
import '../providers/vibration_provider.dart';
import 'dialogs/level_complete_dialog.dart';
import 'dialogs/times_up_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late LevelData levelData;
  late int timeRemaining;
  Duration? gameDuration;
  GameProvider get staticGameProvider => ref.read(gameProvider);
  Key counterKey = Key('initialKey');

  GameState lastState = GameState.idle;

  List<Widget> currentCells = [];

  bool firstRun = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await showTutorialDialog(context);
      firstRun = false;
      _initializeGame();
    });
  }

  VibrationProvider get vibration => getIt.get<VibrationProvider>();
  AudioProvider get audio => getIt.get<AudioProvider>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: staticGameProvider.state,
          builder: (context, state, child) {
            listenToGameEvents(staticGameProvider);
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, 0.0),
                      radius: 1.6,
                      colors: [
                        Colors.purpleAccent.withOpacity(0.9),
                        Colors.deepPurple.withOpacity(0.9),
                        Colors.deepPurple.withOpacity(0.9),
                        Colors.purple.withOpacity(0.9),
                        Colors.deepPurple.withOpacity(0.9),
                      ],
                      stops: [0.1, 0.2, 0.25, 0.3, 0.5],
                    ),
                  ),
                ),
                if (state == GameState.idle)
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                if (state != GameState.idle) ...[
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 5.h,
                        ),
                        // TODO: fix ui, change the hexagon grid to staggered grid
                        HexagonOffsetGrid.evenPointy(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          columns: levelData.gridWidth,
                          rows: levelData.gridHeight,
                          buildTile: (row, col) => HexagonWidgetBuilder(
                              padding: 1, cornerRadius: 3, elevation: 5),
                          buildChild: (col, row) {
                            return ThreeDButton(at: (row, col));
                          },
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SafeArea(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // _nextLevel();
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Level ${levelData.currentLevel}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                              ),
                            ),
                          ),
                          Consumer(builder: (context, ref, child) {
                            final game = ref.watch(gameProvider);
                            return game.state.value == GameState.playing
                                ? SlideCountdown(
                                    key: counterKey,
                                    padding: EdgeInsets.all(10),
                                    duration: gameDuration!,
                                    countUp: false,
                                    onChanged: (value) async {
                                      if (firstRun) return;

                                      timeRemaining = value.inSeconds - 1;
                                      gameDuration = value;
                                      if (value.inSeconds == 0 &&
                                          game.state.value ==
                                              GameState.playing) {
                                        timeRemaining = 0;
                                        game.updateGameState(GameState.lost);
                                      }
                                    },
                                  )
                                : game.state.value != GameState.won
                                    ? Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: Text(
                                          timeRemaining > 0
                                              ? timeRemaining
                                                  .addZeroIfLessThanTen()
                                              : 'Time\'s up!',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : game.state.value == GameState.paused
                                        ? Container()
                                        : Container();
                          }),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(2.h),
                        child: IconButton(
                          onPressed: () async {
                            ref
                                .read(gameProvider)
                                .updateGameState(GameState.paused);
                            final response =
                                await showMenuDialog(context, onPressed: () {});
                            if (response is bool && response) {
                              ref
                                  .read(gameProvider)
                                  .updateGameState(GameState.playing);
                            } else {
                              ref
                                  .read(gameProvider)
                                  .updateGameState(GameState.idle);
                            }
                          },
                          icon: Icon(Icons.settings,
                              color: Colors.white, size: 23.sp),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            );
          }),
    );
  }

  void _initializeGame() async {
    levelData = staticGameProvider.generateLevelData();
    timeRemaining = levelData.timeLimit.toInt();
    gameDuration = Duration(seconds: timeRemaining.ceil());
    counterKey = Key('${DateTime.now().millisecondsSinceEpoch}');
    staticGameProvider.updateGameState(GameState.playing);
  }

  void _nextLevel() {
    staticGameProvider.updateGameState(GameState.won);
    staticGameProvider.currentLevelState?.levelDifference += 10;
    staticGameProvider.continuePlaying();
  }

  listenToGameEvents(GameProvider provider) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      if (lastState == provider.state.value) return;
      final wasPaused = lastState == GameState.paused;
      lastState = provider.state.value;
      switch (provider.state.value) {
        case GameState.playing:
          if (!wasPaused) {
            levelData = provider.currentLevelData;
            timeRemaining = levelData.timeLimit.toInt();

            gameDuration = Duration(seconds: timeRemaining.ceil());
            counterKey = Key('${DateTime.now().millisecondsSinceEpoch}');
            setState(() {});
          }
          break;
        case GameState.won:
          showLevelCompleteDialog(context, onPressed: () {
            staticGameProvider.continuePlaying();
          });
          break;
        case GameState.lost:
          if (timeRemaining == 0) {
            _showTimesUpDialog();
          } else {
            showGameFailed();
          }
          break;
        case GameState.paused:
          break;
        default:
          break;
      }
    });
  }

  void _showTimesUpDialog() {
    showGameFailDialog(context,
        title: 'Time\'s up!',
        subtitle: 'You ran out of time. Do you want to retry?');
  }

  void showGameFailed() {
    showGameFailDialog(context,
        title: 'Game Over',
        subtitle: 'You tapped the wrong cell. Do you want to retry?');
  }
}
