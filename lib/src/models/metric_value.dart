import 'package:meta/meta.dart';

import 'context_message.dart';
import 'metric_value_level.dart';

/// Represents a value computed by the metric
@immutable
class MetricValue<T> {
  /// The id of the metric whose compute this value.
  final String metricsId;

  final T value;

  /// Level of this value computed by the metric.
  final MetricValueLevel level;

  /// Message for user containing information about this value.
  final String comment;

  /// Additional information associated with this value.
  ///
  /// That provide context to help the user understand how the metric compute this one.
  final Iterable<ContextMessage> context;

  const MetricValue({
    @required this.metricsId,
    @required this.value,
    @required this.level,
    @required this.comment,
    this.context = const [],
  });
}
