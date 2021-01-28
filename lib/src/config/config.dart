import 'package:meta/meta.dart';

import 'analysis_options.dart';

const _rootKey = 'code_checker';

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

  factory Config.fromAnalysisOptions(AnalysisOptions options) => Config(
        excludePatterns: options.readIterableOfString(['analyzer', 'exclude']),
        excludeForMetricsPatterns:
            options.readIterableOfString([_rootKey, 'metrics-exclude']),
        metrics: options.readMap([_rootKey, 'metrics']),
      );
}
