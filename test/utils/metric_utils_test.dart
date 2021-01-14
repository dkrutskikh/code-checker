@TestOn('vm')
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:code_checker/src/utils/metric_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Metric utils', () {
    test('readThreshold returns a threshold value from Map based config', () {
      const ruleId1 = 'rule-id-1';
      const ruleId2 = 'rule-id-2';
      const ruleId3 = 'rule-id-3';
      const ruleId4 = 'rule-id-4';
      const ruleId5 = 'rule-id-5';

      const ruleId1Value = 10;
      const ruleId2Value = 0.5;

      const _config = {
        ruleId1: '$ruleId1Value',
        ruleId2: '$ruleId2Value',
        'rule-id-3': '',
        'rule-id-4': null,
      };

      expect(readThreshold<int>(_config, ruleId1, 15), equals(ruleId1Value));
      expect(readThreshold<double>(_config, ruleId2, 15), equals(ruleId2Value));
      expect(readThreshold<int>(_config, ruleId3, 15), equals(15));
      expect(readThreshold<double>(_config, ruleId4, 15), equals(15));
      expect(readThreshold<int>(_config, ruleId5, 15), equals(15));
    });

    test('valueLevel returns a level of passed value', () {
      expect(valueLevel(null, 10), equals(MetricValueLevel.none));
      expect(valueLevel(30, null), equals(MetricValueLevel.none));
      expect(valueLevel(null, null), equals(MetricValueLevel.none));

      expect(valueLevel(30, 10), equals(MetricValueLevel.alarm));
      expect(valueLevel(20, 10), equals(MetricValueLevel.warning));
      expect(valueLevel(10, 10), equals(MetricValueLevel.noted));
      expect(valueLevel(8, 10), equals(MetricValueLevel.none));

      expect(valueLevel(3.0, 1), equals(MetricValueLevel.alarm));
      expect(valueLevel(2.0, 1), equals(MetricValueLevel.warning));
      expect(valueLevel(1.0, 1), equals(MetricValueLevel.noted));
      expect(valueLevel(0.8, 1), equals(MetricValueLevel.none));
    });

    test('invertValueLevel returns a level of passed value', () {
      expect(invertValueLevel(null, 10), equals(MetricValueLevel.none));
      expect(invertValueLevel(30, null), equals(MetricValueLevel.none));
      expect(invertValueLevel(null, null), equals(MetricValueLevel.none));

      expect(invertValueLevel(1, 10), equals(MetricValueLevel.alarm));
      expect(invertValueLevel(5, 10), equals(MetricValueLevel.warning));
      expect(invertValueLevel(10, 10), equals(MetricValueLevel.noted));
      expect(invertValueLevel(13, 10), equals(MetricValueLevel.none));

      expect(invertValueLevel(0.1, 1), equals(MetricValueLevel.alarm));
      expect(invertValueLevel(0.5, 1), equals(MetricValueLevel.warning));
      expect(invertValueLevel(1.0, 1), equals(MetricValueLevel.noted));
      expect(invertValueLevel(1.25, 1), equals(MetricValueLevel.none));
    });

    test('isReportLevel returns true only on "warning" and "alarm"', () {
      <MetricValueLevel, Matcher>{
        MetricValueLevel.none: isFalse,
        MetricValueLevel.noted: isFalse,
        MetricValueLevel.warning: isTrue,
        MetricValueLevel.alarm: isTrue,
      }.forEach((key, value) {
        expect(isReportLevel(key), value);
      });
    });
  });
}
