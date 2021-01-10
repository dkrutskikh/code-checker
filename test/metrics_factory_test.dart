@TestOn('vm')
import 'package:code_checker/src/metrics_factory.dart';
import 'package:test/test.dart';

void main() {
  test('getMetricsById returns only required metrics', () {
    expect(getMetricsById({}), isEmpty);
    expect(
      getMetricsById({'number-of-methods': '1', 'metric-id': '2'})
          .map((metric) => metric.id),
      equals(['number-of-methods']),
    );
  });
}
