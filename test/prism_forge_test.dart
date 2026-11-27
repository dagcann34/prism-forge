import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_forge/audio/prism_audio.dart';
import 'package:prism_forge/engine/models.dart';
import 'package:prism_forge/services/achievements_service.dart';
import 'package:prism_forge/services/ad_service.dart';
import 'package:prism_forge/storage/prism_storage.dart';
import 'package:prism_forge/ui/app.dart';

void main() {
  testWidgets(
    'launches into vibrant PRISM FORGE with Anvil, Trophy Hub, AdMob slot & modes',
    (tester) async {
      await tester.pumpWidget(
        PrismForgeApp(
          storage: MemoryPrismStorage(const PrismSaveData(reducedMotion: true)),
          audio: PrismAudio(),
          adService: MockAdService(),
          gamesService: PlatformGamesService(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PRİZMA DÖKÜM'), findsOneWidget);
      expect(find.text('#1/24'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('anvil_slot')), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('trophy_button')),
        findsOneWidget,
      );
      expect(find.text('Tropik'), findsOneWidget);

      // Open Trophy Vault (zero forced login; optional Game Center/Play Games sync!)
      await tester.tap(find.byKey(const ValueKey<String>('trophy_button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Kupa Vitrini'), findsOneWidget);
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

      // Rotate consumes 35% energy (50% -> 15%)
      await tester.tap(find.byKey(const ValueKey<String>('rotate_button')));
      await tester.pumpAndSettle();
      expect(find.text('15%'), findsOneWidget);
    },
  );
}
