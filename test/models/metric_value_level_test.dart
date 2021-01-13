@TestOn('vm')
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:test/test.dart';

void main() {
  test(
    'MetricValueLevel fromString converts string to MetricValueLevel object',
    () {
      const humanReadableLevels = ['NoTEd', 'wARniNG', 'aLaRM', '', null];

      assert(
        humanReadableLevels.length == MetricValueLevel.values.length + 1,
        "humanReadableLevels has invalid lengths, perhaps array doesn't contain all values",
      );

      expect(
        humanReadableLevels.map(MetricValueLevel.fromString),
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
