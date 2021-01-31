import 'package:code_checker/metrics.dart';
import 'package:code_checker/src/metrics/number_of_methods_metric.dart';
import 'package:code_checker/src/metrics/weight_of_class_metric.dart';
import 'package:code_checker/src/models/metric_value.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:code_checker/src/models/report.dart';
import 'package:source_span/source_span.dart';

Report buildReportStub({
  SourceSpan location,
  Iterable<MetricValue<num>> metrics,
}) {
  const defaultMetricValues = [
    MetricValue<int>(
      metricsId: NumberOfMethodsMetric.metricId,
      value: 0,
      level: MetricValueLevel.none,
      comment: '',
    ),
    MetricValue<double>(
      metricsId: WeightOfClassMetric.metricId,
      value: 1,
      level: MetricValueLevel.none,
      comment: '',
    ),
  ];

  return Report(
    location: location ?? SourceSpan(SourceLocation(0), SourceLocation(0), ''),
    metrics: [
      if (metrics != null) ...metrics,
      if (metrics == null) ...defaultMetricValues,
    ],
  );
}
