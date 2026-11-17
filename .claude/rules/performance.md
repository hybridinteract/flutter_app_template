---
paths:
  - "lib/**"
---
# Performance & Memory Rules

## Memory: release what you create
- A `State` that creates a `TextEditingController`, `ScrollController`, `PageController`, `TabController`, `FocusNode`, `AnimationController`, `Timer`, `Debouncer` or `StreamSubscription` releases it in `dispose()` (`dispose()` / `cancel()`). Create them in `initState` or as `late final` fields, never in `build()`.
- A controller passed in by the parent belongs to the parent: do not dispose it.
- A class that opens a `StreamController` closes it; a class that calls `listen` keeps the `StreamSubscription` and cancels it. The `cancel_subscriptions` and `close_sinks` lints report misses as warnings.
- Feature BLoCs are route-scoped so they close with their route (see bloc.md). Never make a BLoC app-wide just to keep its data; cache in the repository instead.
- After every `await` in a widget, check `context.mounted` (in a `State`: `mounted`) before using `context` or calling `setState`.
- Load network images only through `AppNetworkImage`: it caches on disk and decodes at the displayed size. `Image.network` / `NetworkImage` fail the architecture check.
- Long-lived singletons (repositories, services, stores) hold only small, bounded data, never whole lists, files or images.
- A response that arrives after a route-scoped BLoC closed is dropped safely (closing cancels its emitters), so ordinary requests need no cancelling. Uploads, downloads and requests a newer one replaces take a Dio `CancelToken` in the service (every `DioClient` method accepts one); the repository owns the token and cancels it.

## Rebuild only what changed
- Use `const` constructors wherever they compile (the lints enforce it).
- Place `BlocBuilder` / `BlocSelector` as low in the tree as possible. When a widget needs only some state fields, use `BlocSelector`, `buildWhen` / `listenWhen` or `context.select`.
- Split a large `build()` into small `StatelessWidget` classes, not methods that return widgets: classes can be `const` and rebuild on their own.
- Read screen data with `MediaQuery.sizeOf(context)`, `paddingOf`, `viewInsetsOf`, `devicePixelRatioOf`, not `MediaQuery.of(context)`, which rebuilds on every change (keyboard, rotation, text scale).
- Call `setState` in the smallest widget that owns the changing value.

## Lists
- Any list fed by data that can grow uses `ListView.builder` / `.separated`, `GridView.builder` or `AppPaginatedList`. Never `ListView(children: items.map(...).toList())` or a `Column` of items in a `SingleChildScrollView`: both build every item up front.
- No `shrinkWrap: true` on long lists (it lays out every item). Combine scrolling sections with `CustomScrollView` and slivers.
- API lists that can be long are paginated (`AppConstants.defaultPageSize`) and shown with `AppPaginatedList`.
- Items that can be inserted, removed or reordered get `key: ValueKey(item.id)`.

## Keep the UI thread free
- `build()` only builds widgets: no sorting, filtering, parsing, I/O or formatting of whole lists. Do that in the BLoC and put the result in the state.
- Decode large JSON payloads (long lists, roughly 100 KB or more) in the service with `Isolate.run` / `compute`.
- Debounce input that fires on every keystroke (search, filters) with `Debouncer` (`AppConstants.searchDebounce`), and dispose it.
- Wrap parts that repaint often (progress, timers, charts, video) in a `RepaintBoundary`. Animate fades with `FadeTransition` / `AnimatedOpacity`, not `Opacity` over a large subtree.
- Bundle image assets at the sizes they are shown (1x/2x/3x folders), compressed (WebP where possible). Prefer `Icons` over image files for icons.

## Startup
- `main()` awaits only what the first frame needs (config, storage, DI). Everything else is a lazy singleton or loads after the first frame.

## Logging
- No `print` (`avoid_print` lint). Use `debugPrint` only behind `kDebugMode` or `AppConfig.instance.enableLogging`, and never log tokens, passwords or whole response bodies in release.

## Measure before optimizing
- Profile with `flutter run --profile` on a real device; debug mode is slow on purpose. In DevTools: Performance for jank, Memory for leaks (memory that keeps growing while you open and close the same screen), Network for duplicate or oversized requests.
