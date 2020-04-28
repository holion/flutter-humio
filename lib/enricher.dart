class Enricher {
  Future<Map<String, dynamic>> enrich(
    String level,
    String message, {
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> fields,
    Map<String, String> tags,
  }) async {
    return {};
  }
}
