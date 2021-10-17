import 'package:humio/enricher.dart';
import 'package:humio/tag_enricher.dart';

import 'humio.dart';

class HumioEnrichers implements Humio {
  Humio base;
  List<Enricher> _enrichers = [];

  HumioEnrichers(this.base);

  HumioEnrichers.defaultImplementation(
    String ingestToken, {
    bool? setRawMessage = false,
  }) : this(Humio.defaultImplementation(
          ingestToken,
          setRawMessage: setRawMessage,
        ));

  void addEnricher(Enricher enricher) {
    _enrichers.add(enricher);
  }

  @override
  bool setRawMessage = false;

  @override
  Future<bool> log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? fields,
    Map<String, String>? tags,
  }) async {
    for (var enricher in _enrichers) {
      var enricherFields = await enricher.enrich(
        level,
        message,
        error: error,
        stackTrace: stackTrace,
        fields: fields,
        tags: tags,
      );

      if (enricher is TagEnricher)
        tags = {
          ...tags ?? {},
          ...enricherFields,
        };
      else
        fields = {
          ...fields ?? {},
          ...enricherFields,
        };
    }

    return await base.log(
      level,
      message,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
      tags: tags,
    );
  }
}
