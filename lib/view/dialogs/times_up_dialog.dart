import 'dart:async';

import 'package:BubbleBee/helpers/constants.dart';
import 'package:BubbleBee/providers/ads/ads_provider.dart';
import 'package:BubbleBee/providers/app_life_cycle/app_life_cycle_provider.dart';
import 'package:BubbleBee/providers/audio/audio_provider.dart';
import 'package:BubbleBee/providers/game_provider.dart';
import 'package:BubbleBee/providers/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../game_button.dart';

showGameFailDialog(BuildContext context,
    {required String title, required String subtitle}) async {
  return await showAdaptiveDialog(
    context: context,
    builder: (context) {
      return GameFailDialog(title: title, subtitle: subtitle);
    },
  );
}

class GameFailDialog extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;

  const GameFailDialog(
      {super.key, required this.title, required this.subtitle});

  @override
  ConsumerState<GameFailDialog> createState() => _TimesUpDialogState();
}

class _TimesUpDialogState extends ConsumerState<GameFailDialog> {
  bool retryEnabled = true;

  @override
  void initState() {
    getIt.get<AudioProvider>().play('audio/level_miss.wav');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adsController = ref.read(adsProvider);
    final game = ref.read(gameProvider);
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 80.w,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.deepOrange.shade700]),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(3, 3),
                    spreadRadius: 1,
                    blurRadius: 3)
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -5.h,
                  right: -5.h,
                  child: Image.asset(
                    'assets/images/bee.png',
                    height: 10.h,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "You Lost!",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TimedButton(context: context),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimedButton extends ConsumerStatefulWidget {
  final BuildContext context;
  const TimedButton({super.key, required this.context});

  @override
  ConsumerState<TimedButton> createState() => _TimedButtonState();
}

class _TimedButtonState extends ConsumerState<TimedButton> {
  Timer? timer;

  int timeRemaining = 5;

  bool pause = false;
  bool adsDisabled = false;

  AppLifecycleProvider get lifecycleProvider =>
      getIt.get<AppLifecycleProvider>();

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (lifecycleProvider.state != AppLifecycleState.resumed) return;
      if (mounted && timer.isActive && !pause) {
        if (timeRemaining == 0) {
          ref.read(gameProvider).continuePlaying();
          Navigator.of(context).pop();
          timer.cancel();
        }
        setState(() {
          timeRemaining--;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final adsController = ref.watch(adsProvider);
    final game = ref.watch(gameProvider);
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: adsDisabled
              ? Container(
                  key: Key('hidenAdsBtnatLosePop&91236798'),
                )
              : GameButton(
                  key: Key('adsBtnatLosePop&91236798'),
                  width: 45.w,
                  baseDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade900, Colors.green.shade800],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  topDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.green, Colors.green.shade700],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () async {
                    setState(() {
                      pause = true;
                    });

                    final response = await adsController.showRewardedAd(
                        onUserEarnedReward: () {
                      if (mounted) {
                        Navigator.of(context).pop();
                        ref.read(gameProvider).retryLevel();
                      }
                    });

                    if (response == AdStatus.failed) {
                      setState(() {
                        pause = false;
                        adsDisabled = true;
                      });
                    }
                  },
                  aspectRatio: 4 / 1,
                  enableShimmer: false,
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                          child: Text(
                        'Retry',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Image.asset('assets/images/video.png',
                            width: 5.h, height: 5.h),
                      )
                    ],
                  ),
                ),
        ),
        SizedBox(height: 1.5.h),
        ValueListenableBuilder(
            valueListenable: adsController.interstitialStatus,
            builder: (context, value, child) {
              return (game.currentLevel > 1)
                  ? TextButton(
                      onPressed: value == AdStatus.active ||
                              adsController.tracker.shouldShowAd()
                          ? null
                          : () {
                              print('tapped');
                              timer?.cancel();
                              ref.read(gameProvider).continuePlaying();
                              Navigator.of(context).pop();
                            },
                      child: Text(
                          'Falling to Level ${game.currentLevel ~/ 2} in ${timeRemaining < 0 ? '0' : timeRemaining > 5 ? '5' : timeRemaining} seconds',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 16.sp)),
                    )
                  : TextButton(
                      onPressed: value == AdStatus.active ||
                              adsController.tracker.shouldShowAd()
                          ? null
                          : () {
                              print('tapped');
                              timer?.cancel();
                              ref.read(gameProvider).continuePlaying();
                              Navigator.of(context).pop();
                            },
                      child: Text(
                          'Retrying Level 1 in ${timeRemaining < 0 ? '0' : timeRemaining > 5 ? '5' : timeRemaining} seconds',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 16.sp)),
                    );
            }),
      ],
    );
  }
}
