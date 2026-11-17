import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/widgets/app_loader.dart';
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
    testWidgets('builds only the visible items', (tester) async {
      await tester.pumpWidget(wrap(list(items: numbers(100), hasMore: false)));

      expect(find.text('item 0'), findsOneWidget);
      expect(find.text('item 99'), findsNothing);
    });

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

    testWidgets('shows a loader footer while loading more', (tester) async {
      await tester.pumpWidget(
        wrap(list(items: numbers(2), isLoadingMore: true)),
      );

      expect(find.byType(AppLoader), findsOneWidget);
    });

    testWidgets('shows the load-more error with a working retry', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        wrap(
          list(
            items: numbers(2),
            loadMoreError: 'Could not load more',
            onLoadMore: () => calls++,
          ),
        ),
      );
      await tester.pump();

      // The error stops automatic requests; only the button retries.
      expect(calls, 0);
      expect(find.text('Could not load more'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(calls, 1);
    });

    testWidgets('pull to refresh calls onRefresh, even when empty', (
      tester,
    ) async {
      var refreshed = false;
      await tester.pumpWidget(
        wrap(
          list(
            items: const [],
            hasMore: false,
            onRefresh: () async => refreshed = true,
          ),
        ),
      );

      await tester.fling(find.text('nothing here'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(refreshed, isTrue);
    });
  });
}
