
abstract class ErrorReporterInterface {
  Future<void> initialize();
  bool get isInitialized;
  
  //* Method to set user context
  void setUser({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? data,
  });
  
  //* Method to add breadcrumb
  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    String? type,
  });
  
  //* Method to clear all data (for user logout, etc)
  void clearContext();
}