import 'package:analyzer_plugin/protocol/protocol_common.dart' as p;

import '../models/metric_value_level.dart';

p.AnalysisErrorSeverity severityFromMetricValueLevel(MetricValueLevel level) =>
    level == MetricValueLevel.alarm
        ? p.AnalysisErrorSeverity.WARNING
        : p.AnalysisErrorSeverity.INFO;
