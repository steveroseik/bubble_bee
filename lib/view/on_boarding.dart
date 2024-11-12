import 'package:BubbleBee/view/game_button.dart';
import 'package:BubbleBee/view/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../helpers/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, 0.0), // Center the gradient
                radius:
                    1.6, // Increase radius for a wider spread of the gradient
                colors: [
                  Colors.deepPurple.withOpacity(0.9),
                  kVibrantPink.withOpacity(0.9),
                ],
                stops: [
                  0.4,
                  0.9,
                ], // Smoothly transition between colors
              ),
            ),
          ),
          Image.asset(
            'assets/images/logo.png',
            width: 70.w,
            alignment: Alignment.center,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: GameButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => GameScreen()));
                },
                width: 80.w,
                aspectRatio: 5,
                borderRadius: BorderRadius.circular(15),
                baseDecoration: BoxDecoration(
                  color: Colors.black,
                ),
                topDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purpleAccent,
                      Colors.deepOrange,
                      Colors.purpleAccent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Center(
                    child: Text('START GAME',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
