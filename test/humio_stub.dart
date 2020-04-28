import 'package:humio/humio.dart';

import 'log_statement.dart';

class HumioStub implements Humio {
  LogStatement lastLogStatement;

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
    lastLogStatement = LogStatement(level, message, fields);

    return true;
  }
}
