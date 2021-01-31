import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import 'metric_value.dart';
import 'metric_value_level.dart';

/// Represents the metrics report collected for a entity
@immutable
class Report {
  /// Source code location of the target class
  final SourceSpan location;

  /// Target class metrics
  final Iterable<MetricValue<num>> metrics;

  /// Returns a certain target metric
  MetricValue<num> metric(String id) => metrics
      .firstWhere((metric) => metric.metricsId == id, orElse: () => null);

  // TODO(dkrutskikh): after migrate on NullSafety migrate on iterable extensions from collection package
  MetricValueLevel get metricsLevel => metrics.isNotEmpty
      ? metrics.reduce((a, b) => a.level > b.level ? a : b).level
      : MetricValueLevel.none;

  const Report({@required this.location, @required this.metrics});
}
