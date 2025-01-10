import 'package:BubbleBee/providers/audio/audio_provider.dart';
import 'package:BubbleBee/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexagon/hexagon.dart';

import '../Models/level_data.dart';
import '../helpers/constants.dart';
import '../providers/ads/ads_provider.dart';
import '../providers/get_it.dart';
import '../providers/vibration_provider.dart';

class ThreeDButton extends ConsumerStatefulWidget {
  final (int, int) at;
  final Map<String, dynamic>? tutorial;

  const ThreeDButton({super.key, required this.at, this.tutorial});

  @override
  ConsumerState createState() => _ThreeDButtonState();
}

class _ThreeDButtonState extends ConsumerState<ThreeDButton>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late GameProvider liveGame;
  late Cell cell;

  GameProvider get staticGameProvider => ref.watch(gameProvider);
  AdsController get adsController => ref.read(adsProvider);
  VibrationProvider get vibration => getIt.get<VibrationProvider>();
  AudioProvider get audioProvider => getIt.get<AudioProvider>();

  final Map<Color, Widget> baseHex = {
    Colors.white: HexagonWidget(
      key: UniqueKey(),
      type: HexagonType.POINTY,
      height: double.infinity,
      color: Colors.white,
    ),
    Colors.red: HexagonWidget(
      key: UniqueKey(),
      type: HexagonType.POINTY,
      height: double.infinity,
      color: Colors.red,
    ),
    Colors.amber: HexagonWidget(
      key: UniqueKey(),
      type: HexagonType.POINTY,
      height: double.infinity,
      color: Colors.amber,
    ),
  };

  final Map<Color, Widget> topHex = {
    Colors.white: HexagonWidget(
      key: UniqueKey(),
      padding: 0,
      elevation: 10,
      type: HexagonType.POINTY,
      height: double.infinity,
      color: Colors.white,
    ),
    Colors.red: HexagonWidget(
      key: UniqueKey(),
      padding: 0,
      elevation: 10,
      type: HexagonType.POINTY,
      height: double.infinity,
      color: Colors.red,
    ),
    Colors.amber: HexagonWidget(
      key: UniqueKey(),
      padding: 0,
      elevation: 10,
      type: HexagonType.POINTY,
      height: double.infinity,
      color: Colors.amber,
    ),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Animation duration
    );

    _animation = Tween<double>(begin: -5.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.tutorial != null) return;
    _onCellTap();
    _controller.forward(); // Start the "press down" animation
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.tutorial != null) return;
    _controller.reverse(); // Revert back to the "unpressed" state
  }

  void _onTapCancel() {
    if (widget.tutorial != null) return;
    _controller
        .reverse(); // Handle tap cancel to revert back to the unpressed state
  }

  Cell getCell((int, int) at, GameProvider liveGame) {
    final diff = (liveGame.currentLevelData.gridHeight *
            liveGame.currentLevelData.gridWidth) -
        (at.$1 * at.$2);
    if (diff <= 0) return Cell(type: CellType.empty);
    try {
      return liveGame.currentLevelData.grid[widget.at.$1][widget.at.$2];
    } catch (e) {
      return Cell(type: CellType.empty);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    liveGame = ref.watch(gameProvider);
    cell = getCell(widget.at, liveGame);
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          baseHex[widget.tutorial?['color'] ?? cell.color]!,
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, _animation.value - 5),
                child: topHex[widget.tutorial?['color'] ?? cell.color]!,
              );
            },
          ),
        ],
      ),
    );
  }

  void _onCellTap() {
    if (widget.tutorial != null) return;
    if (staticGameProvider.state.value != GameState.playing) return;

    liveGame.currentLevelState?.numberOfTaps++;

    if (cell.type == CellType.tap && !cell.isTapped) {
      audioProvider.play('audio/ball.mp3');
      liveGame.tapCell(widget.at);
      HapticFeedback.mediumImpact();
    } else if (cell.type == CellType.doNotTap) {
      vibration.vibrate(pattern: [200, 100, 200, 100], intensities: [1, 255]);

      ref.read(gameProvider).updateGameState(GameState.lost);
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
