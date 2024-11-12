import 'package:flutter/material.dart';
import 'package:neopop/widgets/shimmer/neopop_shimmer.dart';
import 'package:simple_animated_button/elevated_layer_button.dart';

class GameButton extends StatelessWidget {
  final BoxDecoration? baseDecoration;
  final BoxDecoration? topDecoration;
  late BorderRadius borderRadius;
  Color? color;
  final bool enableShimmer;
  late Color shimmerColor;
  final Gradient? gradient;
  final Widget? child;
  Function()? onPressed;
  final Duration? animationDuration;
  final Duration? shimmerAnimationDuration;
  final Duration? shimmerDelayDuration;
  final double? height;
  final double? width;
  final double? aspectRatio;

  GameButton(
      {super.key,
      this.baseDecoration,
      this.topDecoration,
      BorderRadius? borderRadius,
      this.color,
      Color? shimmerColor,
      this.enableShimmer = true,
      this.gradient,
      this.child,
      this.onPressed,
      this.animationDuration,
      this.shimmerDelayDuration,
      this.shimmerAnimationDuration,
      this.height,
      this.width,
      this.aspectRatio}) {
    this.borderRadius = borderRadius ?? BorderRadius.circular(0);
    this.shimmerColor = shimmerColor ?? Colors.yellowAccent;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedLayerButton(
      baseDecoration:
          baseDecoration?.copyWith(borderRadius: borderRadius, color: color) ??
              BoxDecoration(borderRadius: borderRadius, color: color),
      topDecoration:
          topDecoration?.copyWith(borderRadius: borderRadius, color: color) ??
              BoxDecoration(borderRadius: borderRadius, color: color),
      buttonHeight: height,
      buttonWidth: width,
      aspectRatio: aspectRatio,
      animationDuration: animationDuration ?? const Duration(milliseconds: 100),
      animationCurve: Curves.easeIn,
      onClick: () {
        onPressed?.call();
      },
      topLayerChild: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: child ?? Container()),
          if (enableShimmer)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: borderRadius,
                child: NeoPopShimmer(
                    shimmerColor: shimmerColor,
                    duration: shimmerAnimationDuration ??
                        const Duration(milliseconds: 1500),
                    delay: shimmerDelayDuration ??
                        const Duration(milliseconds: 2000),
                    child: Container()),
              ),
            ),
        ],
      ),
    );
  }
}
