/// Analytics and error logging from your Flutter app to Humio.
///
/// If you already know Humio you know you'll need this library. If you don't know Humio already you should create a free account and start using this library :-)
library humio;

import 'dart:convert';

import 'package:humio/dispatcher.dart';
import 'package:humio/humio_dispatcher.dart';

class Humio {
  Dispatcher _dispatcher;

  /// Should the `message` property of all events be the `@rawmessage` in Humio?
  bool setRawMessage;

  /// Creates a new Humio logging instance
  Humio(
    this._dispatcher, {
    this.setRawMessage = false,
  });

  /// Creates a new Humio logging instance using the [HumioDispatcher].
  Humio.defaultImplementation(
    String ingestToken, {
    setRawMessage = false,
  }) : this(HumioDispatcher(ingestToken), setRawMessage: setRawMessage);

  /// Log a message to Humio.
  ///
  /// The [level] is simply some value which makes sense to you. The [message] is the important part of the log statement.
  /// If you want to log an error the [error] and [stackTrace] should be given. You can provide additional values using the [fields].
  ///
  /// Humio segment data into indexes called `data sources`. An index will be created for each unique pair of [tags].
  ///
  /// You can call this method directly - but we recommend you call it using the [HumioExtensions].
  Future<bool> log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? fields,
    Map<String, String>? tags,
  }) async {
    // If no tags are specified we will create a default one
    if (tags == null)
      tags = {
        'level': level,
      };
    else if (tags['level'] == null) tags['level'] = level;

    // If we are logging this while debugging we should mark the log statement as such
    assert(() {
      tags!['debug'] = 'true';

      return true;
    }());

    if (fields == null) fields = {};

    if (!setRawMessage) fields['message'] = message;

    if (error != null) fields['error'] = error;
    if (stackTrace != null) fields['stacktrace'] = stackTrace.toString();

    dynamic event = {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      if (setRawMessage) 'rawstring': message,
      'attributes': fields
    };

    final body = {
      'tags': tags,
      'events': [event],
    };

    var requestJson = jsonEncode([body]);

    return await _dispatcher.dispatch(requestJson);
  }
}

extension HumioExtensions on Humio {
  /// Verbose is the noisiest level, rarely (if ever) enabled for a production app.
  Future verbose(String message,
          {Map<String, dynamic>? fields, Map<String, String>? tags}) async =>
      await this.log('verbose', message, fields: fields, tags: tags);

  /// Debug is used for internal system events that are not necessarily observable from the outside, but useful when determining how something happened.
  Future debug(String message,
          {Map<String, dynamic>? fields, Map<String, String>? tags}) async =>
      await this.log('debug', message, fields: fields, tags: tags);

  /// Information events describe things happening in the system that correspond to its responsibilities and functions. Generally these are the observable actions the system can perform.
  Future information(String message,
          {Map<String, dynamic>? fields, Map<String, String>? tags}) async =>
      await this.log('information', message, fields: fields, tags: tags);

  /// When service is degraded, endangered, or may be behaving outside of its expected parameters, Warning level events are used.
  Future warning(String message,
          {Map<String, dynamic>? fields, Map<String, String>? tags}) async =>
      await this.log('warning', message, fields: fields, tags: tags);

  /// When functionality is unavailable or expectations broken, an Error event is used.
  Future error(String message, Object error, StackTrace stackTrace,
          {Map<String, dynamic>? fields, Map<String, String>? tags}) async =>
      await this.log('error', message,
          error: error, stackTrace: stackTrace, fields: fields, tags: tags);

  /// The most critical level, Fatal events demand immediate attention.
  Future fatal(String message,
          {Map<String, dynamic>? fields, Map<String, String>? tags}) async =>
      await this.log('fatal', message, fields: fields, tags: tags);
}
