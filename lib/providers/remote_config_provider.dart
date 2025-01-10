import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigProvider {
  /// Ads State
  /// 0 - No Ads
  /// 1 - Test Ads
  /// 2 - Production Ads
  int adState = 0;

  init() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero,
      ));

      await remoteConfig.fetchAndActivate();
      adState = remoteConfig.getInt("adState");
    } catch (e, s) {
      print("Caught at firebaseCloudMessaging_Listeners()");
      print(s);
    }
  }
}
