import 'package:dio/dio.dart';
import 'package:humio/dispatcher.dart';

/// Humio dispatcher can send log statements to Humio.
class HumioDispatcher implements Dispatcher {
  String _ingestToken;

  /// The URL logs are sent to.
  ///
  /// You should probably never touch the value of this property.
  String ingestUrl = 'https://cloud.humio.com/api/v1/ingest/humio-structured';

  HumioDispatcher(this._ingestToken);

  @override
  Future<bool> dispatch(String json) async {
    if (_ingestToken.isEmpty == true) throw 'Humio ingest token is not defined';
    if (ingestUrl.isEmpty == true) throw 'Humio ingest URL is not defined';

    var dio = Dio();

    Response<dynamic> response;
    try {
      response = await dio.post(
        ingestUrl,
        data: json,
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
