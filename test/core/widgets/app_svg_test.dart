import 'package:app_template/core/widgets/app_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_asset_bundle.dart';

const _assetPath = 'assets/svg/test_icon.svg';
const _svg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
    'viewBox="0 0 24 24"><rect width="24" height="24" fill="#000000"/></svg>';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: DefaultAssetBundle(
      bundle: FakeAssetBundle({_assetPath: _svg}),
      child: Scaffold(body: Center(child: child)),
    ),
  );

  SvgPicture svgPicture(WidgetTester tester) =>
      tester.widget<SvgPicture>(find.byType(SvgPicture));

  Finder imageSemantics() => find.descendant(
    of: find.byType(AppSvg),
    matching: find.byWidgetPredicate(
      (widget) => widget is Semantics && (widget.properties.image ?? false),
    ),
  );

  group('AppSvg', () {
    testWidgets('is hidden from screen readers without a semanticLabel', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const AppSvg(_assetPath)));
      await tester.pump();

      expect(svgPicture(tester).excludeFromSemantics, isTrue);
      expect(imageSemantics(), findsNothing);
    });

    testWidgets('is announced as an image with a semanticLabel', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const AppSvg(_assetPath, semanticLabel: 'Settings')),
      );
      await tester.pump();

      expect(svgPicture(tester).excludeFromSemantics, isFalse);
      expect(imageSemantics(), findsOneWidget);
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    });
  });
}
