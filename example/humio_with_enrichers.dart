import 'package:humio/enricher.dart';
import 'package:humio/humio.dart';
import 'package:humio/humio_enrichers.dart';

import 'config.dart';

class HumioEnricherExample {
  Future run() async {
    var humio = HumioEnrichers.defaultImplementation(Config.humioIngestToken);

    humio.addEnricher(CounterEnricher());

    await humio.verbose('An enriched message');
    await humio.verbose('One more enriched message');
    await humio.verbose('And a third one');
  }
}

class CounterEnricher implements Enricher {
  var _counter = 0;

  @override
  Future<Map<String, dynamic>> enrich(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? fields,
    Map<String, String>? tags,
  }) async =>
      {'log_count': _counter++};
}
