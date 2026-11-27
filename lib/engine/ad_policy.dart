/// Pure-Dart AdMob placement config and smart frequency-capping policy.
library;

/// Rewarded ad placement types.
enum RewardedPlacement {
  /// Clears center 3x3 + restores 100% energy on Game Over (max 1/run).
  rescueRevive,

  /// Instant +100% Tactical Energy boost or Anvil temper.
  energyBoost,
}

/// Official Google AdMob test IDs with compile-time `--dart-define` overrides
/// so live production IDs never need to be committed to source control.
class AdUnitConfig {
  const AdUnitConfig._();

  static const String androidBannerId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  static const String iosBannerId = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );
  static const String androidInterstitialId = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const String iosInterstitialId = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910',
  );
  static const String androidRewardedId = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const String iosRewardedId = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1712485313',
  );
}

/// Pure-Dart frequency capper preventing aggressive interstitial spam.
class AdFrequencyPolicy {
  AdFrequencyPolicy({
    this.minRoundsBeforeFirstInterstitial = 3,
    this.interstitialCooldownSeconds = 180,
    this.adsRemoved = false,
  });

  final int minRoundsBeforeFirstInterstitial;
  final int interstitialCooldownSeconds;
  bool adsRemoved;

  int _completedRounds = 0;
  DateTime? _lastInterstitialAt;

  int get completedRounds => _completedRounds;

  /// Records a finished round and returns true if showing a gentle
  /// end-of-round interstitial is permitted right now.
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
    _lastInterstitialAt = current;
    return true;
  }
}
