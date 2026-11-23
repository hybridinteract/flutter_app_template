import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/widgets/app_paginated_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const itemHeight = 100.0;

  List<int> numbers(int count) => List.generate(count, (i) => i);

  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  AppPaginatedList<int> list({
    required List<int> items,
    bool hasMore = true,
    bool isLoadingMore = false,
    String? loadMoreError,
    VoidCallback? onLoadMore,
    RefreshCallback? onRefresh,
  }) {
    return AppPaginatedList<int>(
      items: items,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
      loadMoreError: loadMoreError,
      onLoadMore: onLoadMore ?? () {},
      onRefresh: onRefresh,
      empty: const Text('nothing here'),
      itemBuilder: (context, item, _) =>
          SizedBox(height: itemHeight, child: Text('item $item')),
    );
  }

  group('AppPaginatedList', () {
    testWidgets('shows the empty widget when there are no items', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(list(items: const [], hasMore: false)));

      expect(find.text('nothing here'), findsOneWidget);
    });

    testWidgets('asks for more once when the first page is shorter than the '
        'screen', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        wrap(list(items: numbers(2), onLoadMore: () => calls++)),
      );
      await tester.pump();
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('asks for more once when scrolled near the end', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        wrap(list(items: numbers(30), onLoadMore: () => calls++)),
      );
      await tester.pump();
      expect(calls, 0);

      await tester.drag(find.byType(ListView), const Offset(0, -2500));
      await tester.pump();
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('does not ask for more when hasMore is false', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        wrap(
          list(items: numbers(2), hasMore: false, onLoadMore: () => calls++),
        ),
      );
      await tester.pump();

      expect(calls, 0);
    });
  });
}
