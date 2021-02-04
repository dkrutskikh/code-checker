import 'package:analyzer/dart/analysis/results.dart';

// ignore: implementation_imports
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';

// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart' as analyzer_internal;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as p;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as p;
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../config/analysis_options.dart';
import '../config/config.dart';
import '../metrics_factory.dart';
import '../models/entity_type.dart';
import '../models/issue.dart';
import '../models/metric_value_level.dart';
import '../models/severity.dart';
import '../rules_factory.dart';
import '../suppressions.dart';
import '../utils/yaml_utils.dart';
import 'plugin_config.dart';

Iterable<p.AnalysisErrorFixes> checkOnCodeIssues(
  ResolvedUnitResult source,
  Suppressions ignores,
  Uri sourceUri,
  PluginConfig config,
) =>
    config.codeRules.where((rule) => !ignores.isSuppressed(rule.id)).expand(
          (rule) => rule
              .check(source)
              .where((issue) => !ignores.isSuppressedAt(
                    issue.ruleId,
                    issue.location.start.line,
                  ))
              .map((issue) => fixesFromIssue(issue, source)),
        );

p.AnalysisErrorFixes fixesFromIssue(Issue issue, ResolvedUnitResult source) =>
    p.AnalysisErrorFixes(
      p.AnalysisError(
        severityFromIssueSeverity(issue.severity),
        p.AnalysisErrorType.LINT,
        p.Location(
          issue.location.sourceUrl.path,
          issue.location.start.offset,
          issue.location.length,
          issue.location.start.line,
          issue.location.start.column,
        ),
        issue.message,
        issue.ruleId,
        correction: issue.verboseMessage,
        url: issue.documentation?.toString(),
        hasFix: issue.suggestion != null,
      ),
      fixes: [
        if (issue.suggestion != null)
          p.PrioritizedSourceChange(
            1,
            p.SourceChange(issue.suggestion.comment, edits: [
              p.SourceFileEdit(
                source.libraryElement.source.fullName,
                source.libraryElement.source.modificationStamp,
                edits: [
                  p.SourceEdit(
                    issue.location.start.offset,
                    issue.location.length,
                    issue.suggestion.replacement,
                  ),
                ],
              ),
            ]),
          ),
      ],
    );

bool isExcluded({
  @required AnalysisResult source,
  @required Iterable<Glob> excludes,
}) =>
    excludes.any((exclude) => exclude.matches(source.path));

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

p.AnalysisErrorSeverity severityFromIssueSeverity(Severity level) {
  const _severityMapping = {
    Severity.error: p.AnalysisErrorSeverity.ERROR,
    Severity.warning: p.AnalysisErrorSeverity.WARNING,
    Severity.performance: p.AnalysisErrorSeverity.INFO,
    Severity.style: p.AnalysisErrorSeverity.INFO,
    Severity.none: p.AnalysisErrorSeverity.INFO,
  };

  return _severityMapping[level] ?? p.AnalysisErrorSeverity.INFO;
}

p.AnalysisErrorSeverity severityFromMetricValueLevel(MetricValueLevel level) =>
    level == MetricValueLevel.alarm
        ? p.AnalysisErrorSeverity.WARNING
        : p.AnalysisErrorSeverity.INFO;

Iterable<Glob> _prepareExcludes(Iterable<String> patterns, String root) =>
    patterns?.map((exclude) => Glob(path.join(root, exclude)))?.toList() ?? [];
