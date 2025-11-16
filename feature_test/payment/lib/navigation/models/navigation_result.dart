/// Represents the result of a navigation action
class NavigationResult<T> {
  /// Whether the navigation was successful
  final bool success;

  /// Error message if navigation failed
  final String? error;

  /// Result data from the navigation (e.g., from Navigator.pop)
  final T? data;

  /// The route name that was navigated to (if successful)
  final String? routeName;

  const NavigationResult({
    required this.success,
    this.error,
    this.data,
    this.routeName,
  });

  /// Creates a successful navigation result
  factory NavigationResult.success({T? data, String? routeName}) {
    return NavigationResult(
      success: true,
      data: data,
      routeName: routeName,
    );
  }

  /// Creates a failed navigation result
  factory NavigationResult.failure(String error) {
    return NavigationResult(
      success: false,
      error: error,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'NavigationResult.success(routeName: $routeName, data: $data)';
    } else {
      return 'NavigationResult.failure(error: $error)';
    }
  }
}
