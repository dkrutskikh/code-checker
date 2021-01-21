import 'package:code_checker/src/metrics/number_of_methods_metric.dart';
import 'package:code_checker/src/metrics/weight_of_class_metric.dart';
import 'package:code_checker/src/models/class_report.dart';
import 'package:code_checker/src/models/metric_value.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:source_span/source_span.dart';

ClassReport buildClassReportStub({
  SourceSpanBase location,
  Iterable<MetricValue<num>> metrics = const [],
}) {
  const defaultMetricValues = [
    MetricValue<int>(
      metricsId: NumberOfMethodsMetric.metricId,
      documentation: '',
      value: 0,
      level: MetricValueLevel.none,
      comment: '',
    ),
    MetricValue<double>(
      metricsId: WeightOfClassMetric.metricId,
      documentation: '',
      value: 1,
      level: MetricValueLevel.none,
      comment: '',
    ),
  ];

  return ClassReport(
    location:
        location ?? SourceSpanBase(SourceLocation(0), SourceLocation(0), ''),
    metrics: [...metrics, ...defaultMetricValues],
  );
}
