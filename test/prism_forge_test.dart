// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_forge/audio/prism_audio.dart';
import 'package:prism_forge/services/achievements_service.dart';
import 'package:prism_forge/services/ad_service.dart';
import 'package:prism_forge/storage/prism_storage.dart';
import 'package:prism_forge/ui/app.dart';

void main() {
  testWidgets(
    'launches into vibrant PRISM FORGE with Anvil, Trophy Hub, AdMob Rewarded & Banner',
    (tester) async {
      final mockAds = MockAdService(privacyOptionsRequired: true);
      await tester.pumpWidget(
        PrismForgeApp(
          storage: MemoryPrismStorage(const PrismSaveData(reducedMotion: true)),
          audio: PrismAudio(),
          adService: mockAds,
          gamesService: PlatformGamesService(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PRİZMA DÖKÜM'), findsOneWidget);
      expect(find.text('#1/24'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('anvil_slot')), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('admob_banner_slot')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('trophy_button')),
        findsOneWidget,
      );
      expect(find.text('Tropik'), findsOneWidget);

      // Open Trophy Vault (zero forced login + UMP Ad Privacy button when required!)
      await tester.tap(find.byKey(const ValueKey<String>('trophy_button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Kupa Vitrini'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('privacy_options_button')),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Cycle vibrant themes (Tropik -> Şeker)
      await tester.tap(find.byKey(const ValueKey<String>('theme_button')));
      await tester.pumpAndSettle();
      expect(find.text('Şeker'), findsOneWidget);

      // Switch to English
      await tester.tap(find.byKey(const ValueKey<String>('lang_button')));
      await tester.pumpAndSettle();
      expect(find.text('PRISM FORGE'), findsOneWidget);
      expect(find.text('Anvil'), findsOneWidget);

      // Open Visual Stage Journey Map and jump to Stage #3 -> theme auto-evolves to Bahar (Blossom)!
      await tester.tap(
        find.byKey(const ValueKey<String>('context_pill_button')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('auto_theme_toggle')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey<String>('stage_tile_3')));
      await tester.pumpAndSettle();
      expect(find.text('#3/24'), findsOneWidget);
      expect(find.text('Blossom'), findsOneWidget);

      // Rotate consumes 35% energy (50% -> 15%)
      await tester.tap(find.byKey(const ValueKey<String>('rotate_button')));
      await tester.pumpAndSettle();
      expect(find.text('15%'), findsOneWidget);

      // Opt-in Rewarded +100% Energy Boost charges Energy straight to 100%!
      await tester.tap(
        find.byKey(const ValueKey<String>('rewarded_energy_button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);
      expect(mockAds.rewardedCount, 1);
      expect(mockAds.lastPlacement, RewardedPlacement.energyBoost);
    },
  );
}
