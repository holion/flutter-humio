class LogStatement {
  String level;
  String message;
  Map<String, dynamic> fields;
  Map<String, String> tags;

  LogStatement(this.level, this.message, this.fields, this.tags);
}
