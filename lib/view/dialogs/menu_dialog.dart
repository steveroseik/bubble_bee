import 'package:BubbleBee/providers/audio/audio_provider.dart';
import 'package:BubbleBee/providers/get_it.dart';
import 'package:BubbleBee/view/dialogs/tutorial_dialog.dart';
import 'package:BubbleBee/view/on_boarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../game_button.dart';

showMenuDialog(BuildContext context, {required Function() onPressed}) async {
  return await showAdaptiveDialog(
    context: context,
    builder: (context) {
      return MenuDialogScreen();
    },
  );
}

class MenuDialogScreen extends StatefulWidget {
  const MenuDialogScreen({super.key});

  @override
  State<MenuDialogScreen> createState() => _MenuDialogScreenState();
}

class _MenuDialogScreenState extends State<MenuDialogScreen> {
  AudioProvider get audioProvider => getIt.get<AudioProvider>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 70.w,
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
              children: [
                Text(
                  "Menu",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                SizedBox(height: 3.h),
                GameButton(
                  height: 6.h,
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
                  ),
                  onPressed: () {
                    // onPressed.call();
                    Navigator.of(context).pop(true);
                  },
                  aspectRatio: 3 / 1,
                  enableShimmer: false,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Continue',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                GameButton(
                  height: 6.h,
                  baseDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepOrange.shade900,
                        Colors.deepOrange.shade700
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  topDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.amber.shade900, Colors.amber.shade800],
                    ),
                  ),
                  onPressed: () {
                    showTutorialDialog(context);
                  },
                  aspectRatio: 3 / 1,
                  enableShimmer: false,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gamepad_rounded,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Tutorial',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                GameButton(
                  height: 6.h,
                  baseDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade900, Colors.blue.shade700],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  topDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.blue, Colors.blue],
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      audioProvider.toggleMute();
                    });
                  },
                  aspectRatio: 3 / 1,
                  enableShimmer: false,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        audioProvider.muted
                            ? CupertinoIcons.volume_off
                            : CupertinoIcons.volume_down,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Turn ${audioProvider.muted ? 'On' : 'Off'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                GameButton(
                  height: 6.h,
                  baseDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade700,
                        Colors.deepPurple.shade600
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  topDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.deepPurple.shade400,
                        Colors.deepPurple.shade300
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    // onPressed.call();
                    Navigator.of(context).pop(false);
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => WelcomeScreen()));
                  },
                  aspectRatio: 3 / 1,
                  enableShimmer: false,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_filled,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Home',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
