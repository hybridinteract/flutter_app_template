import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../theme/app_dimensions.dart';
import 'app_loader.dart';

/// A lazily built list that asks for the next page as the user nears the end,
/// with pull-to-refresh and a footer for "loading more" and "couldn't load
/// more".
///
/// It owns only the scrolling. The BLoC owns the data: [items], [hasMore],
/// [isLoadingMore] and [loadMoreError] come from its state, and [onLoadMore]
/// and [onRefresh] add events to it. The FIRST page's loading and error
/// screens stay with the screen (`AppLoader`, `AppErrorWidget`); this widget
/// is shown once a first page has arrived.
///
/// ```dart
/// AppPaginatedList<ProductModel>(
///   items: state.products,
///   hasMore: state.hasMore,
///   isLoadingMore: state.isLoadingMore,
///   loadMoreError: state.loadMoreError,
///   onLoadMore: () => bloc.add(const MoreProductsRequested()),
///   onRefresh: () async => bloc.add(const ProductsRequested()),
///   empty: AppEmptyWidget(title: l10n.productEmptyTitle),
///   itemBuilder: (context, product, _) => ProductTile(product: product),
/// )
/// ```
class AppPaginatedList<T> extends StatefulWidget {
  const AppPaginatedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.empty,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    this.loadMoreError,
    this.onRefresh,
    this.separatorBuilder,
    this.padding,
    this.controller,
    this.loadMoreOffset = AppDimensions.loadMoreTriggerOffset,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Shown when [items] is empty and nothing more is coming. Usually an
  /// `AppEmptyWidget` with the feature's own text.
  final Widget empty;

  /// False once the backend has returned the last page.
  final bool hasMore;
  final bool isLoadingMore;

  /// Asks for the next page. Called at most once until [items] or
  /// [isLoadingMore] changes, so a fast fling does not request a page twice.
  final VoidCallback onLoadMore;

  /// Message for a failed next page. While set, the footer shows it with a
  /// retry button and scrolling does not ask again on its own.
  final String? loadMoreError;

  /// Pull-to-refresh. Null turns it off.
  final RefreshCallback? onRefresh;

  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsetsGeometry? padding;

  /// Pass one only if the screen needs it (e.g. scroll-to-top). Otherwise the
  /// list creates and disposes its own.
  final ScrollController? controller;
  final double loadMoreOffset;

  @override
  State<AppPaginatedList<T>> createState() => _AppPaginatedListState<T>();
}

class _AppPaginatedListState<T> extends State<AppPaginatedList<T>> {
  ScrollController? _ownController;
  bool _requestPending = false;

  ScrollController get _controller => widget.controller ?? _ownController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _ownController = ScrollController();
    _controller.addListener(_maybeLoadMore);
    _checkAfterLayout();
  }

  @override
  void didUpdateWidget(covariant AppPaginatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_maybeLoadMore);
      if (widget.controller == null) {
        _ownController ??= ScrollController();
      } else {
        _ownController?.dispose();
        _ownController = null;
      }
      _controller.addListener(_maybeLoadMore);
    }
    if (!identical(oldWidget.items, widget.items) ||
        oldWidget.isLoadingMore != widget.isLoadingMore) {
      _requestPending = false;
      _checkAfterLayout();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeLoadMore);
    _ownController?.dispose();
    super.dispose();
  }

  /// A first page shorter than the screen cannot be scrolled, so no scroll
  /// event would ever ask for page two. Check once the new items are laid out.
  void _checkAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });
  }

  void _maybeLoadMore() {
    if (_requestPending ||
        !widget.hasMore ||
        widget.isLoadingMore ||
        widget.loadMoreError != null ||
        !_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    if (!position.hasContentDimensions ||
        position.extentAfter > widget.loadMoreOffset) {
      return;
    }
    _requestPending = true;
    widget.onLoadMore();
  }

  void _retry() {
    _requestPending = true;
    widget.onLoadMore();
  }

  bool get _showFooter =>
      widget.isLoadingMore || (widget.hasMore && widget.loadMoreError != null);

  @override
  Widget build(BuildContext context) {
    final list = widget.items.isEmpty && !widget.hasMore
        ? _buildEmpty()
        : _buildList();

    final onRefresh = widget.onRefresh;
    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh, child: list);
  }

  ScrollPhysics? get _physics => widget.onRefresh == null
      ? null
      // Lets a short list still be pulled down to refresh.
      : const AlwaysScrollableScrollPhysics();

  Widget _buildList() {
    final itemCount = widget.items.length + (_showFooter ? 1 : 0);
    final separatorBuilder = widget.separatorBuilder;

    Widget buildItem(BuildContext context, int index) {
      if (index == widget.items.length) return _buildFooter(context);
      return widget.itemBuilder(context, widget.items[index], index);
    }

    if (separatorBuilder == null) {
      return ListView.builder(
        controller: _controller,
        physics: _physics,
        padding: widget.padding,
        itemCount: itemCount,
        itemBuilder: buildItem,
      );
    }
    return ListView.separated(
      controller: _controller,
      physics: _physics,
      padding: widget.padding,
      itemCount: itemCount,
      itemBuilder: buildItem,
      separatorBuilder: separatorBuilder,
    );
  }

  /// Scrollable even when empty, so pull-to-refresh still works.
  Widget _buildEmpty() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: _controller,
        physics: _physics,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: widget.empty,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final error = widget.loadMoreError;
    if (widget.isLoadingMore || error == null) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        child: AppLoader(size: AppDimensions.iconLg),
      );
    }

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: _retry,
            child: Text(context.l10n.commonTryAgain),
          ),
        ],
      ),
    );
  }
}
