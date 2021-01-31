@TestOn('vm')
import 'package:code_checker/src/metrics/number_of_methods_metric.dart';
import 'package:test/test.dart';

import '../stub_builders.dart';

void main() {
  test('ClassReport metric returns required metric or null', () {
    final report = buildReportStub();

    expect(report.metric(NumberOfMethodsMetric.metricId), isNotNull);
    expect(
      report.metric(NumberOfMethodsMetric.metricId).metricsId,
      equals(NumberOfMethodsMetric.metricId),
    );

    expect(report.metric('id'), isNull);
  });
}
