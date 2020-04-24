library humio;

import 'dart:convert';

import 'package:dio/dio.dart';

class Humio {
  String _ingestToken;

  String ingestUrl = 'https://cloud.humio.com/api/v1/ingest/humio-structured';
  bool setRawMessage;

  Humio(
    this._ingestToken, {
    this.setRawMessage = false,
  });

  Future<bool> log(String severity, String message,
      {Object error,
      StackTrace stackTrace,
      Map<String, dynamic> fields,
      Map<String, String> tags}) async {
    if (_ingestToken?.isEmpty ?? true)
      throw 'Humio ingest token is not defined';
    if (ingestUrl?.isEmpty ?? true) throw 'Humio ingest URL is not defined';

    if (tags == null)
      tags = {
        'environment': 'dev',
      };
    else if (tags['environment'] == null) tags['environment'] = 'dev';

    assert(() {
      tags['debug'] = 'true';

      return true;
    }());

    if (fields == null) fields = {};

    if (!setRawMessage) fields['message'] = message;

    var attributes = Map<String, dynamic>();
    if (error != null) attributes['error'] = error;
    if (stackTrace != null) attributes['stacktrace'] = stackTrace.toString();
    if (fields != null) attributes['fields'] = fields;

    dynamic event = {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      if (setRawMessage) 'rawstring': message,
      'attributes': attributes
    };

    final body = {
      'tags': tags,
      'events': [event],
    };

    var requestJson = jsonEncode([body]);

    var dio = Dio();

    Response<dynamic> response;
    try {
      response = await dio.post(
        ingestUrl,
        data: requestJson,
        options: Options(
          contentType: 'application/json',
          headers: {'Authorization': 'Bearer $_ingestToken'},
        ),
      );
    } on DioError catch (e) {
      print('Humio log error: ${e.message}');

      return false;
    }

    return response.statusCode == 200;
  }
}

extension HumioExtensions on Humio {
  /// Verbose is the noisiest level, rarely (if ever) enabled for a production app.
  Future verbose(String message,
          {Map<String, dynamic> fields, Map<String, String> tags}) async =>
      await this.log('verbose', message, fields: fields, tags: tags);

  /// Debug is used for internal system events that are not necessarily observable from the outside, but useful when determining how something happened.
  void debug(String message,
          {Map<String, dynamic> fields, Map<String, String> tags}) =>
      this.log('debug', message, fields: fields, tags: tags);

  /// Information events describe things happening in the system that correspond to its responsibilities and functions. Generally these are the observable actions the system can perform.
  void information(String message,
          {Map<String, dynamic> fields, Map<String, String> tags}) =>
      this.log('information', message, fields: fields, tags: tags);

  /// When service is degraded, endangered, or may be behaving outside of its expected parameters, Warning level events are used.
  void warning(String message,
          {Map<String, dynamic> fields, Map<String, String> tags}) =>
      this.log('warning', message, fields: fields, tags: tags);

  /// When functionality is unavailable or expectations broken, an Error event is used.
  Future error(String message, Object error, StackTrace stackTrace,
          {Map<String, dynamic> fields, Map<String, String> tags}) async =>
      await this.log('error', message,
          error: error, stackTrace: stackTrace, fields: fields, tags: tags);

  /// The most critical level, Fatal events demand immediate attention.
  void fatal(String message,
          {Map<String, dynamic> fields, Map<String, String> tags}) =>
      this.log('fatal', message, fields: fields, tags: tags);
}
