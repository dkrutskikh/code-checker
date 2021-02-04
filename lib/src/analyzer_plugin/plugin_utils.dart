// ignore: implementation_imports
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';

// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart' as analyzer_internal;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as p;

import '../config/analysis_options.dart';
import '../models/metric_value_level.dart';
import '../utils/yaml_utils.dart';

AnalysisOptions readAnalysisOptions(analyzer_internal.AnalysisDriver driver) {
  if (driver?.contextRoot?.optionsFilePath?.isNotEmpty ?? false) {
    final file =
        driver?.resourceProvider?.getFile(driver.contextRoot.optionsFilePath);
    if (file?.exists ?? false) {
      final yaml = AnalysisOptionsProvider(driver.sourceFactory)
          .getOptionsFromFile(file);

      return AnalysisOptions(yamlMapToDartMap(yaml));
    }
  }

  return null;
}

p.AnalysisErrorSeverity severityFromMetricValueLevel(MetricValueLevel level) =>
    level == MetricValueLevel.alarm
        ? p.AnalysisErrorSeverity.WARNING
        : p.AnalysisErrorSeverity.INFO;
