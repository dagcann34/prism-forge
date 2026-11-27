/// Production Google Mobile Ads (AdMob) SDK service for PRISM FORGE.
///
/// Features:
/// - Google UMP GDPR / EEA / UK Consent flow + Privacy Options re-entry point
/// - Auto-preloaded Interstitial Ads with exponential retry & retention-safe cooldowns
/// - Auto-preloaded Rewarded Video Ads across 3 opt-in placements
///   (Rescue Revive, +100% Energy Boost, Instant Anvil Temper)
/// - Anchored Adaptive Banner Ad widget isolated safely below the footer
/// - Impression-level `onPaidEvent` revenue telemetry callback
/// - Deterministic `MockAdService` for offline unit & Flutter widget tests
library;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../engine/ad_policy.dart';

export '../engine/ad_policy.dart';

typedef AdRevenueCallback = void Function(AdRevenueEvent event);

abstract class AdService {
  AdFrequencyPolicy get policy;
  bool get isBannerVisible;
  bool get isRewardedReady;
  bool get isPrivacyOptionsRequired;

  /// Notifies UI when banner/consent/readiness state updates.
  Listenable get statusListenable;

  Future<void> initialize();
  Future<bool> showRewarded(RewardedPlacement placement);
  Future<void> maybeShowInterstitial();
  Future<void> showPrivacyOptionsForm();

  /// Builds the bottom Anchored Adaptive Banner widget (or safe fallback).
  Widget buildBannerWidget({
    required double maxWidth,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required String fallbackLabel,
  });

  void dispose();
}

/// Real Google Mobile Ads SDK (`google_mobile_ads`) monetization controller.
class PlatformAdService implements AdService {
  PlatformAdService({AdFrequencyPolicy? policy, this.onRevenueEvent})
    : policy = policy ?? AdFrequencyPolicy();

  @override
  final AdFrequencyPolicy policy;

  final AdRevenueCallback? onRevenueEvent;

  final ValueNotifier<int> _statusTick = ValueNotifier<int>(0);
  bool _disposed = false;
  bool _initialized = false;
  bool _sdkReady = false;
  bool _privacyOptionsRequired = false;

  InterstitialAd? _interstitialAd;
  bool _loadingInterstitial = false;
  int _interstitialRetryAttempt = 0;

  RewardedAd? _rewardedAd;
  bool _loadingRewarded = false;
  int _rewardedRetryAttempt = 0;

  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  int _lastBannerWidth = 0;
  bool _loadingBanner = false;

  bool get _isMobilePlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  String get _bannerUnitId => Platform.isIOS
      ? AdUnitConfig.iosBannerId
      : AdUnitConfig.androidBannerId;

  String get _interstitialUnitId => Platform.isIOS
      ? AdUnitConfig.iosInterstitialId
      : AdUnitConfig.androidInterstitialId;

  String get _rewardedUnitId => Platform.isIOS
      ? AdUnitConfig.iosRewardedId
      : AdUnitConfig.androidRewardedId;

  @override
  Listenable get statusListenable => _statusTick;

  @override
  bool get isBannerVisible => !policy.adsRemoved;

  @override
  bool get isRewardedReady => _rewardedAd != null || !_isMobilePlatform;

  @override
  bool get isPrivacyOptionsRequired => _privacyOptionsRequired;

  void _notify() {
    if (_disposed) return;
    _statusTick.value = _statusTick.value + 1;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (!_isMobilePlatform || policy.adsRemoved) return;

    await _gatherConsentAndInitSdk();
  }

  /// Runs Google UMP Consent flow first (mandatory for EEA/UK GDPR traffic),
  /// then initializes Google Mobile Ads SDK and preloads Interstitial & Rewarded ads.
  Future<void> _gatherConsentAndInitSdk() async {
    final completer = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((
              formError,
            ) async {
              await _refreshPrivacyOptionsFlag();
              await _initMobileAdsIfAllowed();
              if (!completer.isCompleted) completer.complete();
            });
          } catch (_) {
            await _initMobileAdsIfAllowed();
            if (!completer.isCompleted) completer.complete();
          }
        },
        (formError) async {
          // Offline or UMP unconfigured: still attempt safe SDK init so ads work outside EEA.
          await _initMobileAdsIfAllowed();
          if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (_) {
      await _initMobileAdsIfAllowed();
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () async {
        await _initMobileAdsIfAllowed();
      },
    );
  }

  Future<void> _refreshPrivacyOptionsFlag() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      _privacyOptionsRequired =
          status == PrivacyOptionsRequirementStatus.required;
      _notify();
    } catch (_) {
      _privacyOptionsRequired = false;
    }
  }

  Future<void> _initMobileAdsIfAllowed() async {
    if (_sdkReady || !_isMobilePlatform || policy.adsRemoved) return;
    var canRequest = true;
    try {
      canRequest = await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      canRequest = true;
    }
    if (!canRequest) return;

    try {
      await MobileAds.instance.initialize();
      _sdkReady = true;
      _preloadInterstitial();
      _preloadRewarded();
      _notify();
    } catch (_) {
      // Never block gameplay if Mobile Ads SDK fails offline.
    }
  }

  @override
  Future<void> showPrivacyOptionsForm() async {
    if (!_isMobilePlatform) return;
    final completer = Completer<void>();
    try {
      await ConsentForm.showPrivacyOptionsForm((formError) async {
        await _refreshPrivacyOptionsFlag();
        await _initMobileAdsIfAllowed();
        if (!completer.isCompleted) completer.complete();
      });
    } catch (_) {
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  void _preloadInterstitial() {
    if (!_sdkReady ||
        !_isMobilePlatform ||
        policy.adsRemoved ||
        _loadingInterstitial ||
        _interstitialAd != null) {
      return;
    }
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitialRetryAttempt = 0;
          ad.onPaidEvent = (adObj, valueMicros, precision, currencyCode) {
            onRevenueEvent?.call(
              AdRevenueEvent(
                format: AdFormatKind.interstitial,
                adUnitId: _interstitialUnitId,
                valueMicros: valueMicros,
                currencyCode: currencyCode,
              ),
            );
          };
          _interstitialAd = ad;
          _notify();
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          _interstitialAd = null;
          _interstitialRetryAttempt = (_interstitialRetryAttempt + 1).clamp(
            1,
            4,
          );
          final delaySec = 5 * (1 << (_interstitialRetryAttempt - 1));
          Timer(Duration(seconds: delaySec), _preloadInterstitial);
        },
      ),
    );
  }

  void _preloadRewarded() {
    if (!_sdkReady ||
        !_isMobilePlatform ||
        _loadingRewarded ||
        _rewardedAd != null) {
      return;
    }
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingRewarded = false;
          _rewardedRetryAttempt = 0;
          ad.onPaidEvent = (adObj, valueMicros, precision, currencyCode) {
            onRevenueEvent?.call(
              AdRevenueEvent(
                format: AdFormatKind.rewarded,
                adUnitId: _rewardedUnitId,
                valueMicros: valueMicros,
                currencyCode: currencyCode,
              ),
            );
          };
          _rewardedAd = ad;
          _notify();
        },
        onAdFailedToLoad: (error) {
          _loadingRewarded = false;
          _rewardedAd = null;
          _rewardedRetryAttempt = (_rewardedRetryAttempt + 1).clamp(1, 4);
          final delaySec = 5 * (1 << (_rewardedRetryAttempt - 1));
          Timer(Duration(seconds: delaySec), _preloadRewarded);
          _notify();
        },
      ),
    );
  }

  @override
  Future<bool> showRewarded(RewardedPlacement placement) async {
    if (!_isMobilePlatform) {
      policy.recordRewardedAdWatched(placement);
      return true;
    }
    if (!_sdkReady) {
      await _initMobileAdsIfAllowed();
    }
    final ad = _rewardedAd;
    if (ad == null) {
      _preloadRewarded();
      return false;
    }
    _rewardedAd = null;
    _notify();

    var earnedReward = false;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (adObj) {
        adObj.dispose();
        _preloadRewarded();
        if (!completer.isCompleted) completer.complete(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (adObj, error) {
        adObj.dispose();
        _preloadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (adView, reward) {
          earnedReward = true;
          policy.recordRewardedAdWatched(placement);
        },
      );
    } catch (_) {
      await ad.dispose();
      _preloadRewarded();
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }

  @override
  Future<void> maybeShowInterstitial() async {
    if (!policy.recordRoundAndShouldShowInterstitial()) return;
    if (!_isMobilePlatform || !_sdkReady) return;

    final ad = _interstitialAd;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }
    _interstitialAd = null;
    _notify();

    final completer = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (adObj) {
        adObj.dispose();
        _preloadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (adObj, error) {
        adObj.dispose();
        _preloadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      await ad.show();
    } catch (_) {
      await ad.dispose();
      _preloadInterstitial();
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  Future<void> _ensureBannerLoaded(int widthPx) async {
    if (!_sdkReady ||
        !_isMobilePlatform ||
        policy.adsRemoved ||
        _loadingBanner) {
      return;
    }
    if (widthPx < 200) return;
    if (_bannerAd != null && (widthPx - _lastBannerWidth).abs() < 24) return;

    _loadingBanner = true;
    _lastBannerWidth = widthPx;

    AdSize? adaptiveSize;
    try {
      adaptiveSize =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            widthPx,
          );
    } catch (_) {
      adaptiveSize = null;
    }
    final size = adaptiveSize ?? AdSize.banner;
    if (_disposed) {
      _loadingBanner = false;
      return;
    }

    final old = _bannerAd;
    _bannerAd = null;
    _bannerLoaded = false;
    await old?.dispose();

    final banner = BannerAd(
      adUnitId: _bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (_disposed) {
            ad.dispose();
            return;
          }
          _loadingBanner = false;
          _bannerLoaded = true;
          _notify();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _loadingBanner = false;
          _bannerAd = null;
          _bannerLoaded = false;
          _notify();
        },
        onPaidEvent: (adObj, valueMicros, precision, currencyCode) {
          onRevenueEvent?.call(
            AdRevenueEvent(
              format: AdFormatKind.banner,
              adUnitId: _bannerUnitId,
              valueMicros: valueMicros,
              currencyCode: currencyCode,
            ),
          );
        },
      ),
    );
    _bannerAd = banner;
    await banner.load();
  }

  @override
  Widget buildBannerWidget({
    required double maxWidth,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required String fallbackLabel,
  }) {
    if (!isBannerVisible) return const SizedBox.shrink();

    if (_isMobilePlatform && _sdkReady) {
      final widthPx = maxWidth.truncate();
      if (_bannerAd == null && !_loadingBanner && widthPx >= 200) {
        unawaited(_ensureBannerLoaded(widthPx));
      }
      final ad = _bannerAd;
      if (ad != null && _bannerLoaded) {
        return SizedBox(
          key: const ValueKey<String>('admob_banner_slot'),
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        );
      }
    }

    return Container(
      key: const ValueKey<String>('admob_banner_slot'),
      height: 50,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.ad_units_rounded, size: 14, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              fallbackLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _statusTick.dispose();
  }
}

/// Deterministic mock AdService for unit & widget tests (zero platform calls).
class MockAdService implements AdService {
  MockAdService({
    this.grantReward = true,
    this.privacyOptionsRequired = false,
    AdFrequencyPolicy? policy,
  }) : policy = policy ?? AdFrequencyPolicy();

  final bool grantReward;
  final bool privacyOptionsRequired;
  final ValueNotifier<int> _tick = ValueNotifier<int>(0);
  int rewardedCount = 0;
  int interstitialChecks = 0;
  RewardedPlacement? lastPlacement;

  @override
  final AdFrequencyPolicy policy;

  @override
  bool get isBannerVisible => !policy.adsRemoved;

  @override
  bool get isRewardedReady => true;

  @override
  bool get isPrivacyOptionsRequired => privacyOptionsRequired;

  @override
  Listenable get statusListenable => _tick;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> showRewarded(RewardedPlacement placement) async {
    rewardedCount++;
    lastPlacement = placement;
    if (grantReward) {
      policy.recordRewardedAdWatched(placement);
    }
    return grantReward;
  }

  @override
  Future<void> maybeShowInterstitial() async {
    interstitialChecks++;
    policy.recordRoundAndShouldShowInterstitial();
  }

  @override
  Future<void> showPrivacyOptionsForm() async {}

  @override
  Widget buildBannerWidget({
    required double maxWidth,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required String fallbackLabel,
  }) {
    if (!isBannerVisible) return const SizedBox.shrink();
    return Container(
      key: const ValueKey<String>('admob_banner_slot'),
      height: 44,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: Text(
        fallbackLabel,
        style: TextStyle(
          color: textColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tick.dispose();
  }
}
