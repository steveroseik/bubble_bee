import 'package:BubbleBee/providers/audio/audio_provider.dart';
import 'package:BubbleBee/providers/get_it.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../game_button.dart';

showLevelCompleteDialog(BuildContext context,
    {required Function() onPressed}) async {
  return await showAdaptiveDialog(
    context: context,
    builder: (context) {
      return LevelCompleteDialog(onPressed: onPressed);
    },
  );
}

class LevelCompleteDialog extends StatefulWidget {
  final Function() onPressed;
  const LevelCompleteDialog({super.key, required this.onPressed});

  @override
  State<LevelCompleteDialog> createState() => _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends State<LevelCompleteDialog> {
  late ConfettiController controller;

  @override
  void initState() {
    controller = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((t) {
      controller.play();
      getIt.get<AudioProvider>().play('audio/new_rank.wav');
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 80.w,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurple]),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "You have completed the level!",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "You Won!",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 3.h),
                    GameButton(
                      height: 6.h,
                      baseDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.red.shade900],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      topDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Colors.orangeAccent, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onPressed: () {
                        widget.onPressed.call();
                        Navigator.of(context).pop();
                      },
                      aspectRatio: 3 / 1,
                      enableShimmer: false,
                      borderRadius: BorderRadius.circular(10),
                      child: Center(
                          child: Text(
                        'Next Level',
                        style: const TextStyle(color: Colors.white),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: controller,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 100,
              gravity: 0.2,
              shouldLoop:
                  false, // start again as soon as the animation is finished
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ], // manually specify the colors to be used
            ),
          ),
        ],
      ),
    );
  }
}
