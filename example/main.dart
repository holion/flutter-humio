import 'humio_basic_example.dart';
import 'humio_with_enrichers.dart';

Future main() async {
  await HumioBasicExample().run();
  await HumioEnricherExample().run();
}
