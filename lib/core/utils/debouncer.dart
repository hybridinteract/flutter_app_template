import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

/// Runs an action only after calls have stopped for [duration].
///
/// Use it for input that fires on every keystroke (search boxes, filters) so
/// the BLoC gets one event per pause instead of one per character:
///
/// ```dart
/// final _debouncer = Debouncer();
/// onChanged: (q) => _debouncer.run(
///   () => context.read<SearchBloc>().add(SearchQueryChanged(q)),
/// ),
/// // in State.dispose():
/// _debouncer.dispose();
/// ```
///
/// The owner must call [dispose]; a pending timer would otherwise fire after
/// the screen is gone.
class Debouncer {
  Debouncer({this.duration = AppConstants.searchDebounce});

  final Duration duration;
  Timer? _timer;

  /// Replaces any pending action with [action].
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Drops the pending action, if any.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isPending => _timer?.isActive ?? false;

  void dispose() => cancel();
}
