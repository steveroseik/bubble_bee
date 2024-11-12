import 'package:BubbleBee/view/3d_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

showTutorialDialog(BuildContext context) async {
  await showAdaptiveDialog(
    context: context,
    builder: (context) => TutorialDialog(),
  );
}

class TutorialDialog extends ConsumerStatefulWidget {
  const TutorialDialog({super.key});

  @override
  ConsumerState<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends ConsumerState<TutorialDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 98.w,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tutorial",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
              SizedBox(height: 5.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 20.w,
                      width: 20.w,
                      child: ThreeDButton(
                        at: (0, 0),
                        tutorial: {"color": Colors.white},
                      )),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ('Empty Cell'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        Text(
                          'Your goal is to tap on all the empty cells before time ends.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey.shade300),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 3.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 20.w,
                      width: 20.w,
                      child: ThreeDButton(
                        at: (0, 0),
                        tutorial: {"color": Colors.amber},
                      )),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ('Full Cell'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        Text(
                          'This cell is already filled, tapping on it will not make any changes.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey.shade300),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 3.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 20.w,
                      width: 20.w,
                      child: ThreeDButton(
                        at: (0, 0),
                        tutorial: {"color": Colors.red},
                      )),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ('Danger Cell'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        Text(
                          'Tapping on this cell will end the game immediately.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey.shade300),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.check_rounded),
                  label: Text('Got it'))
            ],
          ),
        ),
      ),
    );
  }
}
