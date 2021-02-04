@TestOn('vm')
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:code_checker/src/analyzer_plugin/plugin_utils.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:test/test.dart';

void main() {
  test(
    'severityFromMetricValueLevel converts MetricValueLevel to AnalysisErrorSeverity',
    () {
      expect(
        MetricValueLevel.values.map(severityFromMetricValueLevel),
        equals([
          AnalysisErrorSeverity.INFO,
          AnalysisErrorSeverity.INFO,
          AnalysisErrorSeverity.INFO,
          AnalysisErrorSeverity.WARNING,
        ]),
      );
    },
  );
}
