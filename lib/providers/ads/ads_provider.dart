import 'dart:async';

import 'package:BubbleBee/providers/remote_config_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../helpers/constants.dart';
import '../get_it.dart';
import 'ad_helper.dart';
import 'ads_tracker.dart';

final adsProvider =
    ChangeNotifierProvider<AdsController>((ref) => AdsController());

class AdsController extends ChangeNotifier {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;

  GameAdTracker tracker = GameAdTracker();

  int get adState => getIt.get<RemoteConfigProvider>().adState;

  ValueNotifier<AdStatus> interstitialStatus =
      ValueNotifier<AdStatus>(AdStatus.loading);
  ValueNotifier<AdStatus> rewardedStatus =
      ValueNotifier<AdStatus>(AdStatus.loading);
  ValueNotifier<AdStatus> bannerStatus =
      ValueNotifier<AdStatus>(AdStatus.loading);

  Widget get bannerAdWidget => SafeArea(
          child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ));

  AdsController() {
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  dispose() {
    interstitialStatus.dispose();
    rewardedStatus.dispose();
    tracker.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    bannerStatus.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          bannerStatus.value = AdStatus.loaded;
        },

        onAdFailedToLoad: (ad, err) {
          bannerStatus.value = AdStatus.failed;
        },

        onAdOpened: (Ad ad) {},

        onAdClosed: (Ad ad) {},

        onAdImpression: (Ad ad) {},
      ),
    )..load();
  }

  Future<AdStatus> showInterstitialAd({bool retry = false}) async {
    if (retry) _loadInterstitialAd();

    final status = await waitUntilChanged(interstitialStatus);

    switch (status) {
      case AdStatus.loaded:
        await _interstitialAd?.show();
        break;
      case AdStatus.failed:
        if (!retry) {
          return showInterstitialAd(retry: true);
        }
        break;
      default:
        break;
    }
    return status;
  }

  Future<AdStatus> showRewardedAd(
      {required Function() onUserEarnedReward, bool retry = false}) async {
    if (retry) _loadRewardedAd();

    final status = await waitUntilChanged(rewardedStatus);
    switch (status) {
      case AdStatus.loaded:
        await _rewardedAd?.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) =>
                onUserEarnedReward.call());

        break;
      case AdStatus.failed:
        if (!retry) {
          return showRewardedAd(
              onUserEarnedReward: onUserEarnedReward, retry: true);
        }
        break;
      default:
        break;
    }
    return status;
  }

  receiveGameUpdate({bool failed = false}) {
    tracker.updateGamesUntilAd(failed ? -2 : -1);
  }

  Future<bool> tryToShowAd({Duration? delay}) async {
    final shouldShow = tracker.shouldShowAd();
    if (shouldShow) {
      if (delay != null) await Future.delayed(delay);

      await showInterstitialAd();
      return true;
    } else {
      return false;
    }
  }

  void _loadInterstitialAd() {
    if (adState == 0) {
      interstitialStatus.value = AdStatus.failed;
      return;
    }

    interstitialStatus.value = AdStatus.loading;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialStatus.value = AdStatus.loaded;
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              interstitialStatus.value = AdStatus.active;
              tracker.reset();
            },
            onAdDismissedFullScreenContent: (ad) {
              interstitialStatus.value = AdStatus.loading;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          interstitialStatus.value = AdStatus.failed;
          print('Failed to load interstitial ad: $err');
        },
      ),
    );
  }

  void _loadRewardedAd() {
    if (adState == 0) {
      rewardedStatus.value = AdStatus.failed;
      return;
    }
    rewardedStatus.value = AdStatus.loading;
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedStatus.value = AdStatus.loaded;
          _rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              rewardedStatus.value = AdStatus.loading;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          rewardedStatus.value = AdStatus.failed;
          print('Failed to load rewarded ad: $err');
        },
      ),
    );
  }

  Future<AdStatus> waitUntilChanged(ValueNotifier<AdStatus> status) async {
    if (status.value != AdStatus.loading) return status.value;
    Completer<AdStatus> completer = Completer();
    void listener() {
      completer.complete(status.value);
      status.removeListener(listener);
    }

    status.addListener(listener);

    return completer.future;
  }
}
