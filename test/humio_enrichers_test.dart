import 'package:flutter_test/flutter_test.dart';
import 'package:humio/enricher.dart';
import 'package:humio/humio_enrichers.dart';

import 'humio_stub.dart';

void main() {
  test('Without enrichers the log statement shouldn\'t be changed', () {
    var humioBase = HumioStub();

    var sut = HumioEnrichers(humioBase);

    sut.log('info', 'message');

    expect(humioBase.lastLogStatement.level, 'info');
    expect(humioBase.lastLogStatement.message, 'message');
    expect(humioBase.lastLogStatement.fields, null);
  });

  test('Enricher should add fields', () async {
    var humioBase = HumioStub();

    var sut = HumioEnrichers(humioBase);
    sut.addEnricher(SimpleTestEnricher());

    await sut.log('info', 'message');

    expect(humioBase.lastLogStatement.level, 'info');
    expect(humioBase.lastLogStatement.message, 'message');
    expect(humioBase.lastLogStatement.fields, {'private': 'true'});
  });
}

class SimpleTestEnricher implements Enricher {
  @override
  Future<Map<String, dynamic>> enrich(
    String level,
    String message, {
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> fields,
    Map<String, String> tags,
  }) async =>
      {'private': 'true'};
}
