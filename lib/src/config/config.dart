import 'package:meta/meta.dart';

/// Class representing config
///
/// commonly found in `analysis_options.yaml`.
@immutable
class Config {
  final Iterable<String> excludePatterns;
  final Iterable<String> metricsExcludePatterns;
  final Map<String, Object> metrics;

  const Config({
    @required this.excludePatterns,
    @required this.metricsExcludePatterns,
    @required this.metrics,
  });
}
