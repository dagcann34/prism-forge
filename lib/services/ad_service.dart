/// Flutter platform bridge for AdMob (re-exports pure-Dart AdUnitConfig &
/// AdFrequencyPolicy).
library;

import 'package:flutter/services.dart';

import '../engine/ad_policy.dart';

export '../engine/ad_policy.dart';

abstract class AdService {
  AdFrequencyPolicy get policy;
  bool get isBannerVisible;

  Future<void> initialize();
  Future<bool> showRewarded(RewardedPlacement placement);
  Future<void> maybeShowInterstitial();
}

/// Native MethodChannel bridge (`com.prismforge/ads`) ready for Google Mobile
/// Ads SDK integration, with graceful offline fallback in tests/dev builds.
class PlatformAdService implements AdService {
  PlatformAdService({MethodChannel? channel, AdFrequencyPolicy? policy})
    : _channel = channel ?? const MethodChannel('com.prismforge/ads'),
      policy = policy ?? AdFrequencyPolicy();

  final MethodChannel _channel;

  @override
  final AdFrequencyPolicy policy;

  @override
  bool get isBannerVisible => !policy.adsRemoved;

  @override
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod<void>('initialize', <String, String>{
        'androidBannerId': AdUnitConfig.androidBannerId,
        'iosBannerId': AdUnitConfig.iosBannerId,
        'androidInterstitialId': AdUnitConfig.androidInterstitialId,
        'iosInterstitialId': AdUnitConfig.iosInterstitialId,
        'androidRewardedId': AdUnitConfig.androidRewardedId,
        'iosRewardedId': AdUnitConfig.iosRewardedId,
      });
    } on MissingPluginException {
      // Safe fallback when native AdMob SDK is not linked yet.
    } on PlatformException {
      // Never block gameplay if ad network is offline.
    }
  }

  @override
  Future<bool> showRewarded(RewardedPlacement placement) async {
    try {
      final earned = await _channel.invokeMethod<bool>(
        'showRewarded',
        <String, String>{'placement': placement.name},
      );
      return earned ?? false;
    } on MissingPluginException {
      // In local dev / preview without AdMob SDK linked, grant simulated reward.
      return true;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> maybeShowInterstitial() async {
    if (!policy.recordRoundAndShouldShowInterstitial()) return;
    try {
      await _channel.invokeMethod<void>('showInterstitial');
    } on MissingPluginException {
      // Safe no-op in headless/dev environments.
    } on PlatformException {
      // Never interrupt gameplay on offline ad failure.
    }
  }
}

/// Deterministic mock AdService for unit & widget tests.
class MockAdService implements AdService {
  MockAdService({this.grantReward = true, AdFrequencyPolicy? policy})
    : policy = policy ?? AdFrequencyPolicy();

  final bool grantReward;
  int rewardedCount = 0;
  int interstitialChecks = 0;

  @override
  final AdFrequencyPolicy policy;

  @override
  bool get isBannerVisible => !policy.adsRemoved;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> showRewarded(RewardedPlacement placement) async {
    rewardedCount++;
    return grantReward;
  }

  @override
  Future<void> maybeShowInterstitial() async {
    interstitialChecks++;
    policy.recordRoundAndShouldShowInterstitial();
  }
}
