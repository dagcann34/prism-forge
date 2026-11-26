import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_forge/audio/prism_audio.dart';
import 'package:prism_forge/engine/models.dart';
import 'package:prism_forge/storage/prism_storage.dart';
import 'package:prism_forge/ui/app.dart';

void main() {
  testWidgets(
    'launches into PRISM FORGE Quest Stage 1 and switches modes/locales',
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

      // Switch to English
      await tester.tap(find.byKey(const ValueKey<String>('lang_button')));
      await tester.pumpAndSettle();
      expect(find.text('PRISM FORGE'), findsOneWidget);

      // Open 24-Stage Quest Picker
      await tester.tap(
        find.byKey(const ValueKey<String>('context_pill_button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Prism Quest — 24 Stages'), findsOneWidget);

      // Select Stage 13 (First Seal)
      await tester.tap(find.text('#13 🔒'));
      await tester.pumpAndSettle();
      expect(find.text('#13/24'), findsOneWidget);

      // Rotate consumes 35% energy (50% -> 15%)
      await tester.tap(find.byKey(const ValueKey<String>('rotate_button')));
      await tester.pumpAndSettle();
      expect(find.text('15%'), findsOneWidget);

      // Switch to Endless and Daily modes cleanly
      await tester.tap(find.byKey(const ValueKey<String>('mode_endless')));
      await tester.pumpAndSettle();
      expect(find.text('Best'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('mode_daily')));
      await tester.pumpAndSettle();
      expect(find.text('Daily'), findsWidgets);
    },
  );
}
