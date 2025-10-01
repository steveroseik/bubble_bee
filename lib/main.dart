import 'package:BubbleBee/providers/ads/ads_provider.dart';
import 'package:BubbleBee/providers/app_life_cycle/app_life_cycle_provider.dart';
import 'package:BubbleBee/providers/game_provider.dart';
import 'package:BubbleBee/providers/get_it.dart';
import 'package:BubbleBee/view/on_boarding.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';
import 'helpers/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  MobileAds.instance.initialize();
  await GetItProvider.initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  bool loading = true;

  AppLifecycleState? prevState;

  static final facebookAppEvents = FacebookAppEvents();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((t) async {
      await ref.read(gameProvider).initializeGameData();
      setState(() {
        loading = false;
      });
    });
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    getIt.get<AppLifecycleProvider>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eagerAds = ref.watch(adsProvider);
    return Sizer(builder: (context, orientation, size) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'comic',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: loading ? CircularProgressIndicator() : WelcomeScreen(),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    getIt.get<AppLifecycleProvider>().state = state;
    if (prevState == state) return;
    prevState = state;
    if (state == AppLifecycleState.paused) {
      final staticGameProvider = ref.read(gameProvider);
      if (mounted && staticGameProvider.state.value == GameState.playing) {
        staticGameProvider.updateGameState(GameState.paused);
      }
    }
  }
}
