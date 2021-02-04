import 'package:analyzer/dart/analysis/results.dart';

// ignore: implementation_imports
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';

// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart' as analyzer_internal;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as p;
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

import '../config/analysis_options.dart';
import '../config/config.dart';
import '../metrics_factory.dart';
import '../models/entity_type.dart';
import '../models/metric_value_level.dart';
import '../rules_factory.dart';
import '../utils/yaml_utils.dart';
import 'plugin_config.dart';

bool isSupported(AnalysisResult source) =>
    source.path != null &&
    source.path.endsWith('.dart') &&
    !source.path.endsWith('.g.dart');

PluginConfig pluginConfig(
  Config config,
  Iterable<String> additionalSkippedFolders,
  String contextRoot,
) =>
    PluginConfig(
      globalExclude: _prepareExcludes(
        [...additionalSkippedFolders, ...config.excludePatterns],
        contextRoot,
      ),
      codeRules: config?.rules != null ? rulesByConfig(config.rules) : [],
      classesMetrics:
          metrics(config: config.metrics, measuredType: EntityType.classEntity),
      methodsMetrics: metrics(
        config: config.metrics,
        measuredType: EntityType.methodEntity,
      ),
      metricsExclude:
          _prepareExcludes(config?.excludeForMetricsPatterns, contextRoot),
    );

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

Iterable<Glob> _prepareExcludes(Iterable<String> patterns, String root) =>
    patterns?.map((exclude) => Glob(path.join(root, exclude)))?.toList() ?? [];
