import 'package:app_template/core/widgets/app_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  group('AppNetworkImage', () {
    testWidgets('shows the fallback without a request when url is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const AppNetworkImage(url: '', width: 80, height: 80)),
      );

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('uses a custom errorWidget when url is null', (tester) async {
      await tester.pumpWidget(
        wrap(const AppNetworkImage(url: null, errorWidget: Text('no image'))),
      );

      expect(find.text('no image'), findsOneWidget);
    });

    testWidgets('decodes at the displayed width times the pixel ratio', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrap(
          const AppNetworkImage(
            url: 'https://example.com/a.png',
            width: 100,
            height: 50,
          ),
        ),
      );

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.memCacheWidth, 200);
      // One side only, so the decoded image keeps its aspect ratio.
      expect(image.memCacheHeight, isNull);
    });

    testWidgets('measures the layout when no size is given', (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 120,
            child: AppNetworkImage(url: 'https://example.com/a.png'),
          ),
        ),
      );

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.memCacheWidth, 360);
    });
  });
}
