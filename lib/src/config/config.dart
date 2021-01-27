import 'package:meta/meta.dart';

/// Class representing config
@immutable
class Config {
  final Iterable<String> excludePatterns;
  final Iterable<String> excludeForMetricsPatterns;
  final Map<String, Object> metrics;

  const Config({
    @required this.excludePatterns,
    @required this.excludeForMetricsPatterns,
    @required this.metrics,
  });
}
