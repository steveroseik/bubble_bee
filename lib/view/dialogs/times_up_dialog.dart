import 'package:BubbleBee/providers/ads/ads_provider.dart';
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
            child: Column(
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
                    GameButton(
                      height: 5.h,
                      baseDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade300,
                            Colors.deepPurple.shade400
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      topDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Colors.deepPurple,
                            Colors.deepPurple.shade700
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onPressed: () {
                        ref.read(gameProvider).continuePlaying();
                        Navigator.of(context).pop();
                      },
                      aspectRatio: 3 / 1,
                      enableShimmer: false,
                      borderRadius: BorderRadius.circular(10),
                      child: Center(
                          child: Text(
                        game.currentLevel != 1 ? 'Reload' : 'Retry',
                        style: TextStyle(
                            color: Colors.orange.shade50,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
                    if (game.currentLevel != 1)
                      GameButton(
                        height: 5.h,
                        baseDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade900,
                              Colors.green.shade800
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        topDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: !retryEnabled
                                ? [Colors.white, Colors.purple.shade300]
                                : [Colors.green, Colors.green.shade700],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: !retryEnabled
                            ? null
                            : () {
                                setState(() {
                                  retryEnabled = false;
                                });
                                adsController.showRewardedAd(
                                    onUserEarnedReward: () {
                                  Navigator.of(context).pop();
                                  ref.read(gameProvider).retryLevel();
                                });
                              },
                        aspectRatio: 3 / 1,
                        enableShimmer: false,
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Center(
                                child: Text(
                              'Retry',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                            Positioned(
                              right: -10,
                              top: -10,
                              child: Image.asset('assets/images/video.png',
                                  width: 5.h, height: 5.h),
                            )
                          ],
                        ),
                      )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
