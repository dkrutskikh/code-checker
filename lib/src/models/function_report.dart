import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import 'metric_value.dart';

/// Represents the metrics report collected for a function / method
@immutable
class FunctionReport {
  /// Source code location of the target function
  final SourceSpan location;

  /// Target function metrics
  final Iterable<MetricValue<num>> metrics;

  /// Returns a certain target metric
  MetricValue<num> metric(String id) => metrics
      .firstWhere((metric) => metric.metricsId == id, orElse: () => null);

  const FunctionReport({@required this.location, @required this.metrics});
}
