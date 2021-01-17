import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import 'metric_value.dart';

@immutable
class ClassReport {
  final SourceSpanBase location;
  final Iterable<MetricValue<num>> metrics;

  MetricValue<num> metric(String id) => metrics
      .firstWhere((metric) => metric.metricsId == id, orElse: () => null);

  const ClassReport({@required this.location, @required this.metrics});
}
