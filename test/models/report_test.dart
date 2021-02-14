// @dart=2.8

@TestOn('vm')
import 'package:code_checker/src/metrics/number_of_methods_metric.dart';
import 'package:code_checker/src/metrics/weight_of_class_metric.dart';
import 'package:code_checker/src/models/metric_value.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:test/test.dart';

import '../stub_builders.dart';

void main() {
  group('Report', () {
    test('metric returns required metric or null', () {
      final report = buildReportStub();

      expect(report.metric(NumberOfMethodsMetric.metricId), isNotNull);
      expect(
        report.metric(NumberOfMethodsMetric.metricId).metricsId,
        equals(NumberOfMethodsMetric.metricId),
      );

      expect(report.metric('id'), isNull);
    });
    test('metricsLevel returns maximum warning level of reported metrics', () {
      expect(
        buildReportStub(metrics: []).metricsLevel,
        equals(MetricValueLevel.none),
      );
      expect(
        buildReportStub(metrics: const [
          MetricValue<int>(
            metricsId: NumberOfMethodsMetric.metricId,
            value: 0,
            level: MetricValueLevel.noted,
            comment: '',
          ),
          MetricValue<double>(
            metricsId: WeightOfClassMetric.metricId,
            value: 1,
            level: MetricValueLevel.noted,
            comment: '',
          ),
        ]).metricsLevel,
        equals(MetricValueLevel.noted),
      );
      expect(
        buildReportStub(metrics: const [
          MetricValue<int>(
            metricsId: NumberOfMethodsMetric.metricId,
            value: 0,
            level: MetricValueLevel.none,
            comment: '',
          ),
          MetricValue<double>(
            metricsId: WeightOfClassMetric.metricId,
            value: 1,
            level: MetricValueLevel.alarm,
            comment: '',
          ),
        ]).metricsLevel,
        equals(MetricValueLevel.alarm),
      );
    });
  });
}
