import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_forge/audio/prism_audio.dart';
import 'package:prism_forge/engine/models.dart';
import 'package:prism_forge/storage/prism_storage.dart';
import 'package:prism_forge/ui/app.dart';

void main() {
  testWidgets(
    'launches into vibrant PRISM FORGE with Anvil slot, 24 stages & modes',
    (tester) async {
      await tester.pumpWidget(
        PrismForgeApp(
          storage: MemoryPrismStorage(const PrismSaveData(reducedMotion: true)),
          audio: PrismAudio(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PRİZMA DÖKÜM'), findsOneWidget);
      expect(find.text('#1/24'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('anvil_slot')), findsOneWidget);
      expect(find.text('Tropik'), findsOneWidget);

      // Cycle vibrant themes (Tropik -> Şeker)
      await tester.tap(find.byKey(const ValueKey<String>('theme_button')));
      await tester.pumpAndSettle();
      expect(find.text('Şeker'), findsOneWidget);

      // Switch to English
      await tester.tap(find.byKey(const ValueKey<String>('lang_button')));
      await tester.pumpAndSettle();
      expect(find.text('PRISM FORGE'), findsOneWidget);
      expect(find.text('Anvil'), findsOneWidget);

      // Open 24-Stage Quest Picker & select Stage 13
      await tester.tap(
        find.byKey(const ValueKey<String>('context_pill_button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Prism Quest — 24 Stages'), findsOneWidget);
      await tester.tap(find.text('#13 🔒'));
      await tester.pumpAndSettle();
      expect(find.text('#13/24'), findsOneWidget);

      // Rotate consumes 35% energy (50% -> 15%)
      await tester.tap(find.byKey(const ValueKey<String>('rotate_button')));
      await tester.pumpAndSettle();
      expect(find.text('15%'), findsOneWidget);
    },
  );
}
