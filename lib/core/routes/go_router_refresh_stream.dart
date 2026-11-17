import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adapts any [Stream] (for example a BLoC's state stream) into a [Listenable]
/// so GoRouter re-runs its `redirect` whenever the stream emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
