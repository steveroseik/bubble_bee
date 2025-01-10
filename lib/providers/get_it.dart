import 'package:BubbleBee/helpers/constants.dart';
import 'package:BubbleBee/providers/app_life_cycle/app_life_cycle_provider.dart';
import 'package:BubbleBee/providers/audio/audio_provider.dart';
import 'package:BubbleBee/providers/remote_config_provider.dart';
import 'package:BubbleBee/providers/vibration_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

final getIt = GetIt.asNewInstance();

class GetItProvider {
  static initialize() async {
    getIt.registerSingleton<AudioProvider>(AudioProvider());
    getIt.registerSingleton<VibrationProvider>(VibrationProvider());
    getIt.registerSingleton<RemoteConfigProvider>(RemoteConfigProvider());
    getIt.registerSingleton<AppLifecycleProvider>(AppLifecycleProvider());

    await getIt<RemoteConfigProvider>().init();
    await getIt<VibrationProvider>().initialize();
    final hiveBox = await Hive.openLazyBox<String>(localStoragePath);
    getIt.registerSingleton<LazyBox<String>>(hiveBox);
    print('GetIt initialized');
  }
}
