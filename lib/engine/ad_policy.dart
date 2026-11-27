/// Pure-Dart AdMob placement configuration, impression revenue telemetry model,
/// and retention-safe monetization frequency policy for PRISM FORGE.
library;

/// Three opt-in, zero-pay-to-win Rewarded Video placements tailored to PRISM FORGE.
enum RewardedPlacement {
  /// Clears center 3x3 + restores 100% energy (+20s in Blitz) on Game Over (max 1/run).
  rescueRevive,

  /// Instant +100% Tactical Energy charge for 3x3 Quantum Nova (max 2/run).
  energyBoost,

  /// Instantly tempers the piece waiting in the Prism Anvil into 🌈 Wildcard + ★ (max 1/run).
  instantTemper,
}

/// Ad format identifier for impression-level revenue reporting (`onPaidEvent`).
enum AdFormatKind { banner, interstitial, rewarded }

/// Impression-level AdMob revenue event emitted from Google Mobile Ads `onPaidEvent`.
class AdRevenueEvent {
  const AdRevenueEvent({
    required this.format,
    required this.adUnitId,
    required this.valueMicros,
    required this.currencyCode,
  });

  final AdFormatKind format;
  final String adUnitId;
  final double valueMicros;
  final String currencyCode;

  double get valueInCurrency => valueMicros / 1000000.0;
}

/// Official Google AdMob test unit IDs with compile-time `--dart-define`
/// overrides so live production unit IDs are injected securely via CI Secrets
/// without hardcoding secrets in source control.
class AdUnitConfig {
  const AdUnitConfig._();

  static const String _testAndroidBanner =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBanner =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testIosInterstitial =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testAndroidRewarded =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _testIosRewarded =
      'ca-app-pub-3940256099942544/6978759866';

  static const String androidBannerId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
    defaultValue: _testAndroidBanner,
  );
  static const String iosBannerId = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
    defaultValue: _testIosBanner,
  );
  static const String androidInterstitialId = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
    defaultValue: _testAndroidInterstitial,
  );
  static const String iosInterstitialId = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
    defaultValue: _testIosInterstitial,
  );
  static const String androidRewardedId = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_ID',
    defaultValue: _testAndroidRewarded,
  );
  static const String iosRewardedId = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_ID',
    defaultValue: _testIosRewarded,
  );

  /// True when any ad unit is still pointing at Google's sample test IDs.
  static bool get isUsingTestIds =>
      androidBannerId == _testAndroidBanner ||
      androidInterstitialId == _testAndroidInterstitial ||
      androidRewardedId == _testAndroidRewarded ||
      iosBannerId == _testIosBanner ||
      iosInterstitialId == _testIosInterstitial ||
      iosRewardedId == _testIosRewarded;
}

/// Pure-Dart monetization frequency capper balancing strong ARPDAU with high D1/D7 retention:
/// - Round 1 is always interstitial-free so new players fall in love with gameplay first.
/// - Minimum 120s cooldown between interstitials (prevents AdMob spam complaints & churn).
/// - 90s post-Rewarded grace window: watching any voluntary Rewarded Ad suppresses
///   the next interstitial so players are never double-hit with back-to-back video ads.
/// - Per-run Rewarded boost caps preserve tactical skill balance.
class AdFrequencyPolicy {
  AdFrequencyPolicy({
    this.minRoundsBeforeFirstInterstitial = 2,
    this.interstitialCooldownSeconds = 120,
    this.postRewardedGraceSeconds = 90,
    this.maxEnergyBoostsPerRun = 2,
    this.maxInstantTempersPerRun = 1,
    this.adsRemoved = false,
  });

  final int minRoundsBeforeFirstInterstitial;
  final int interstitialCooldownSeconds;
  final int postRewardedGraceSeconds;
  final int maxEnergyBoostsPerRun;
  final int maxInstantTempersPerRun;
  bool adsRemoved;

  int _completedRounds = 0;
  DateTime? _lastInterstitialAt;
  DateTime? _lastRewardedAt;
  int _energyBoostsUsedInRun = 0;
  int _instantTempersUsedInRun = 0;

  int get completedRounds => _completedRounds;
  int get energyBoostsUsedInRun => _energyBoostsUsedInRun;
  int get instantTempersUsedInRun => _instantTempersUsedInRun;

  bool get canUseEnergyBoost => _energyBoostsUsedInRun < maxEnergyBoostsPerRun;
  bool get canUseInstantTemper =>
      _instantTempersUsedInRun < maxInstantTempersPerRun;

  /// Resets per-run rewarded caps when starting a fresh board/stage.
  void resetRunCaps() {
    _energyBoostsUsedInRun = 0;
    _instantTempersUsedInRun = 0;
  }

  /// Records a completed Rewarded Ad watch, activating the post-rewarded
  /// interstitial grace window and incrementing the relevant per-run cap.
  void recordRewardedAdWatched(RewardedPlacement placement, {DateTime? now}) {
    _lastRewardedAt = now ?? DateTime.now();
    switch (placement) {
      case RewardedPlacement.rescueRevive:
        break;
      case RewardedPlacement.energyBoost:
        _energyBoostsUsedInRun++;
      case RewardedPlacement.instantTemper:
        _instantTempersUsedInRun++;
    }
  }

  /// Records a finished round/stage transition and returns true if showing an
  /// interstitial is permitted right now.
  bool recordRoundAndShouldShowInterstitial({DateTime? now}) {
    _completedRounds++;
    if (adsRemoved) return false;
    if (_completedRounds < minRoundsBeforeFirstInterstitial) return false;

    final current = now ?? DateTime.now();
    if (_lastInterstitialAt != null &&
        current.difference(_lastInterstitialAt!).inSeconds <
            interstitialCooldownSeconds) {
      return false;
    }
    if (_lastRewardedAt != null &&
        current.difference(_lastRewardedAt!).inSeconds <
            postRewardedGraceSeconds) {
      return false;
    }
    _lastInterstitialAt = current;
    return true;
  }
}
