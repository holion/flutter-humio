import 'enricher.dart';

/// A TagEnricher can add tags to every log statement.
class TagEnricher implements Enricher {
  Future<Map<String, String>> enrich(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? fields,
    Map<String, String>? tags,
  }) async {
    return {};
  }
}
