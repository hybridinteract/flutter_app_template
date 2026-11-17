abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Basic internet connectivity check or platform connectivity
    // In production this can be backed by connectivity_plus or internet_connection_checker
    return true;
  }
}
