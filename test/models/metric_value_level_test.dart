@TestOn('vm')
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:test/test.dart';

void main() {
  test(
    'MetricValueLevel fromString convert string to MetricValueLevel object',
    () {
      expect(
        ['NoTEd', 'wARniNG', 'aLaRM', '', null]
            .map(MetricValueLevel.fromString),
        equals([
          MetricValueLevel.noted,
          MetricValueLevel.warning,
          MetricValueLevel.alarm,
          MetricValueLevel.none,
          null,
        ]),
      );
    },
  );
}
