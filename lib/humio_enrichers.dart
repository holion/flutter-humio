import 'package:humio/enricher.dart';

import 'humio.dart';

class HumioEnrichers implements Humio {
  Humio base;
  List<Enricher> _enrichers;

  HumioEnrichers(this.base) {
    _enrichers = List<Enricher>();
  }

  HumioEnrichers.defaultImplementation(
    String ingestToken, {
    bool setRawMessage = false,
  }) : this(Humio(ingestToken, setRawMessage: setRawMessage));

  void addEnricher(Enricher enricher) {
    _enrichers.add(enricher);
  }

  @override
  String ingestUrl;

  @override
  bool setRawMessage;

  @override
  Future<bool> log(
    String level,
    String message, {
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> fields,
    Map<String, String> tags,
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