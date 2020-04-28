import 'dart:io';

class Config {
  static String _token = "your-ingest-token";

  static String get humioIngestToken {
    if (_token.indexOf('-') < 0) return _token;

    var filename = '.humio-ingest-token';

    var file = File(filename);
    if (!file.existsSync())
      throw '''
Couldn\'t load Humio ingest token from file (${file.absolute.path}).

You should either put your Humio ingest token in the specified file or put it directly in example/config.dart in the _token variable.

If you want it in the specified file, you should open the file in a text editor and put your ingest token in the file - without anything else. No JSON no nothing - just the token.
''';

    return _token = file.readAsStringSync();
  }
}
