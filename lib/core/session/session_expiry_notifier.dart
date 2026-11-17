import 'dart:async';

/// Broadcasts when the user's session can no longer be renewed
/// (for example, the refresh token was rejected).
///
/// The network layer reports the expiry; the auth feature listens through its
/// repository and signs the user out. This keeps `core/` free of feature code.
class SessionExpiryNotifier {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get onExpired => _controller.stream;

  void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}
