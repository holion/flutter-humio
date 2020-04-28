import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:humio/humio.dart';

String _token;
String get token {
  if (_token != null) return _token;

  var filename = '.humio-ingest-token';
  
  var file = File(filename);
  if (!file.existsSync())
    throw '''
Couldn\'t load Humio ingest token from file (${file.absolute.path}).

You should open the file in a text editor and put your ingest token in the file - without anything else. No JSON no nothing - just the token.
''';

  return _token = file.readAsStringSync();
}

void main() {
  test('log method returns true when correct ingest token is provided',
      () async {
    final sut = Humio(token);

    expect(await sut.log('information', 'Starting test'), true);
  });

  test('level specific methods should pass', () async {
    final sut = Humio(token, setRawMessage: false);

    sut.verbose('A verbose message');
    sut.debug('A debug message');
    sut.information('An information message');
    sut.warning('A warning message');
    sut.fatal('A fatal message');

    await sut.verbose('A verbose message - with await');
  });

  test('error with stack trace and fields', () async {
    final sut = Humio(token);

    try {
      throw 'It crashed :-/';
    } catch (ex) {
      await sut.error(
        'An error message',
        ex,
        StackTrace.current,
        fields: {
          'machinename': 'mymachine',
          'location': 'denmark',
        },
      );
    }
  });

  test('using tags', () async {
    final sut = Humio(token);

    await sut
        .verbose('Verbose logging using tags', tags: {'environment': 'prod'});
  });

  test('with complex fields', () async {
    final sut = Humio(token);

    await sut.verbose(
      'verbose with complex fields',
      fields: {
        'environment': 'test',
        'machine': {
          'name': 'beast',
          'power': true,
        },
      },
    );
  });

  test('existing key overwritten', () async {
    final sut = Humio(token);

    await sut.verbose(
      'Explicit environment (overwrites existing)',
      tags: {'environment': 'prod'},
    );
  });

  test('new key added', () async {
    final sut = Humio(token);

    await sut.verbose(
      'New key added',
      tags: {'sensitive': 'true'},
    );
  });

  test('new key added and existing overwritten', () async {
    final sut = Humio(token);

    await sut.verbose(
      'New key added and existing overwritten',
      tags: {'environment': 'prod', 'sensitive': 'true'},
    );
  });
}
