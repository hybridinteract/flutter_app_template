import 'package:app_template/core/widgets/app_lottie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_asset_bundle.dart';

const _assetPath = 'assets/animations/test_animation.json';
const _lottieJson =
    '{"v":"5.7.4","fr":30,"ip":0,"op":30,"w":100,"h":100,'
    '"nm":"test","ddd":0,"assets":[],"layers":[]}';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: DefaultAssetBundle(
      bundle: FakeAssetBundle({_assetPath: _lottieJson}),
      child: Scaffold(body: Center(child: child)),
    ),
  );

  /// Lottie loads and parses the file asynchronously, outside the fake clock
  /// of testWidgets, so pump in real time and give it a moment.
  Future<void> pumpLoaded(WidgetTester tester, Widget widget) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(wrap(widget));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
  }

  Finder inAppLottie(Type type) =>
      find.descendant(of: find.byType(AppLottie), matching: find.byType(type));

  // The parsed composition is cached by asset path; start each test clean.
  tearDown(Lottie.cache.clear);

  group('AppLottie', () {
    testWidgets('renders the loaded animation at the given size', (
      tester,
    ) async {
      await pumpLoaded(
        tester,
        const AppLottie(_assetPath, width: 80, height: 60),
      );

      expect(find.byType(Lottie), findsOneWidget);
      expect(tester.getSize(find.byType(AppLottie)), const Size(80, 60));
    });

    testWidgets('loops by default', (tester) async {
      await pumpLoaded(tester, const AppLottie(_assetPath));

      expect(tester.widget<Lottie>(find.byType(Lottie)).repeat, isTrue);
    });

    testWidgets('plays once when repeat is false', (tester) async {
      await pumpLoaded(tester, const AppLottie(_assetPath, repeat: false));

      expect(tester.widget<Lottie>(find.byType(Lottie)).repeat, isFalse);
    });

    testWidgets('sits in exactly one RepaintBoundary', (tester) async {
      await pumpLoaded(tester, const AppLottie(_assetPath));

      expect(inAppLottie(RepaintBoundary), findsOneWidget);
      expect(
        tester.widget<Lottie>(find.byType(Lottie)).addRepaintBoundary,
        isFalse,
      );
    });

    testWidgets('is hidden from screen readers without a semanticLabel', (
      tester,
    ) async {
      await pumpLoaded(tester, const AppLottie(_assetPath));

      expect(inAppLottie(ExcludeSemantics), findsOneWidget);
    });

    testWidgets('is announced as an image with a semanticLabel', (
      tester,
    ) async {
      await pumpLoaded(
        tester,
        const AppLottie(_assetPath, semanticLabel: 'Loading'),
      );

      expect(inAppLottie(ExcludeSemantics), findsNothing);
      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(AppLottie),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.label, 'Loading');
      expect(semantics.properties.image, isTrue);
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    });
  });
}
