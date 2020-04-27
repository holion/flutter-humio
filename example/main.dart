import 'dart:io';

import 'package:humio/humio.dart';

String _token = "your-ingest-token";

Future main() async {
  var humio = Humio(humioIngestToken);

  await humio.log('information', 'The example program has been started');

  await humio.information(
      'The example app uses extension methods to avoid magic strings for the level');

  await humio.verbose(
      'There are extension methods available for the most common log levels');

  await humio.debug('We also reached this line');

  try {
    throw 'Something bad happened';
  } catch (error, stackTrace) {
    await humio.error(
        'Errors can easily be logged with the error message and the corresponding stack trace',
        error,
        stackTrace);
  }

  await humio.fatal(
    'Something went very wrong - so additional details are provided',
    fields: {
      'appversion': '1.0',
      'additionalvalue': true,
    },
  );

  await humio.warning(
    'Tags can easily be specified. They will be used for indexing in Humio.',
    fields: {
      'appversion': '1.0',
      'additionalvalue': true,
    },
    tags: {
      'private': 'yes',
    },
  );
}

String get humioIngestToken {
  if (_token.indexOf('-') < 0) return _token;

  var filename = 'test/humio-ingest-token';

  var file = File(filename);
  if (!file.existsSync())
    throw '''
Couldn\'t load Humio ingest token from file (${file.absolute.path}).

You should either put your Humio ingest token in the specified file or put it directly in example/main.dart in the _token variable.

If you want it in the specified file, you should open the file in a text editor and put your ingest token in the file - without anything else. No JSON no nothing - just the token.
''';

  return _token = file.readAsStringSync();
}
