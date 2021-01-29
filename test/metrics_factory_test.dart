@TestOn('vm')
import 'package:code_checker/src/metrics/maximum_nesting_level/maximum_nesting_level_metric.dart';
import 'package:code_checker/src/metrics_factory.dart';
import 'package:test/test.dart';

void main() {
  test('allMetrics returns all metrics initialized by passed config', () {
    expect(allMetrics({}), isNotEmpty);
    expect(
      allMetrics({})
          .where((metric) => metric.id == MaximumNestingLevelMetric.metricId)
          .single
          .threshold,
      equals(5),
    );
    expect(
      allMetrics({MaximumNestingLevelMetric.metricId: '10'})
          .where((metric) => metric.id == MaximumNestingLevelMetric.metricId)
          .single
          .threshold,
      equals(10),
    );
  });
}
