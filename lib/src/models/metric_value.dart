import 'package:meta/meta.dart';

import 'metric_value_level.dart';

/// Represents a value computed by the metric
@immutable
class MetricValue<T> {
  /// The id of the metric whose compute this value.
  final String metricsId;

  final T value;

  /// Level of this value computed by the metric.
  final MetricValueLevel level;

  const MetricValue({
    @required this.metricsId,
    @required this.value,
    @required this.level,
  });
}
