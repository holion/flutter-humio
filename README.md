# humio

Analytics and error logging from your Flutter app to Humio.

## Getting Started

To use this plugin, add `humio` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

When humio is added to your project you can initialize it using your Humio ingest token:
```
var humio = Humio.defaultImplementation('your-humio-ingest-token');
```

You are now ready to log to Humio:

```
await humio.information('Logging using the information level');
```

### Example

A longer example:

```
var humio = Humio.defaultImplementation('your-humio-ingest-token');

await humio.information('The example app uses extension methods to avoid magic strings for the level');

await humio.verbose('There are extension methods available for the most common log levels');

try {
  throw 'Something bad happened';
} catch (error, stackTrace) {
  await humio.error(
      'Errors can easily be logged with the error message and the corresponding stack trace',
      error,
      stackTrace);
}
```

for more examples look in `example/humio_basic_example.dart`.

## Enrichers

If you have certain fields you always want to send to Humio, you should consider using Enrichers.

Enrichers can be added dynamically and when they have been added they will annotate every log statement with the fields they provide.

View the example in `example/humio_with_enrichers.dart` for a simple example.