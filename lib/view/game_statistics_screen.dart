import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:BubbleBee/providers/game_provider.dart';

class GameStatisticsScreen extends ConsumerStatefulWidget {
  const GameStatisticsScreen({super.key});

  @override
  ConsumerState<GameStatisticsScreen> createState() =>
      _GameStatisticsScreenState();
}

class _GameStatisticsScreenState extends ConsumerState<GameStatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(gameProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Statistics'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Total Seconds'),
            trailing: Text(provider.currentUser.totalSecondsSaved.toString()),
          ),
          ListTile(
            title: Text('Total Time Played'),
            trailing: Text(provider.currentUser.levels.length.toString()),
          ),
          ListTile(
            title: Text('Total Falls'),
            trailing: Text(provider.currentUser.totalFalls.toString()),
          ),
          ListTile(
            title: Text('Total Taps'),
            trailing: Text(provider.currentUser.totalNumberOfTaps.toString()),
          ),
          Text('Levels Details'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.currentUser.levels.length,
            itemBuilder: (context, index) {
              final level = provider.currentUser.levels[index];
              return ListTile(
                title: Text('Level ${level.level}'),
                subtitle: Column(
                  children: [
                    Text('Time Saved: ${level.timeSaved}'),
                    Text('Taps: ${level.numberOfTaps}'),
                    Text('Level difference: ${level.levelDifference}'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
