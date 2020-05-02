import 'package:humio/humio.dart';

import 'config.dart';

class HumioBasicExample {
  Future run() async {
    var humio = Humio.defaultImplementation(Config.humioIngestToken);

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
}
