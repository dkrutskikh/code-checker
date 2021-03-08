import 'package:analyzer/dart/analysis/results.dart';

// ignore: implementation_imports
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';

// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart' as analyzer_internal;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as p;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as p;
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import '../config/analysis_options.dart';
import '../config/config.dart';
import '../metrics_factory.dart';
import '../models/entity_type.dart';
import '../models/issue.dart';
import '../models/metric_value_level.dart';
import '../models/report.dart';
import '../models/severity.dart';
import '../rules_factory.dart';
import '../scope_visitor.dart';
import '../suppressions.dart';
import '../utils/metric_utils.dart';
import '../utils/node_utils.dart';
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

Iterable<p.AnalysisErrorFixes> collectMetrics(
  ResolvedUnitResult source,
  Suppressions ignores,
  Uri sourceUri,
  PluginConfig config,
) {
  if (isExcluded(source: source, excludes: config.metricsExclude)) {
    return [];
  }

  final visitor = ScopeVisitor();
  source.unit.visitChildren(visitor);

  final analysisErrorFixes = <p.AnalysisErrorFixes>[];

  for (final classDeclaration in visitor.classes) {
    final report = Report(
      location: nodeLocation(
        node: classDeclaration.declaration,
        source: source,
      ),
      metrics: [
        for (final metric in config.classesMetrics)
          if (metric.supports(
            classDeclaration.declaration,
            visitor.classes,
            visitor.functions,
            source,
          ))
            metric.compute(
              classDeclaration.declaration,
              visitor.classes,
              visitor.functions,
              source,
            ),
      ],
    );

    analysisErrorFixes.addAll(fixesFromMetricReport(report));
  }

  for (final functionDeclaration in visitor.functions) {
    final report = Report(
      location: nodeLocation(
        node: functionDeclaration.declaration,
        source: source,
      ),
      metrics: [
        for (final metric in config.methodsMetrics)
          if (metric.supports(
            functionDeclaration.declaration,
            visitor.classes,
            visitor.functions,
            source,
          ))
            metric.compute(
              functionDeclaration.declaration,
              visitor.classes,
              visitor.functions,
              source,
            ),
      ],
    );

    analysisErrorFixes.addAll(fixesFromMetricReport(report));
  }

  return analysisErrorFixes;
}

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

Iterable<p.AnalysisErrorFixes> fixesFromMetricReport(Report report) =>
    report.metrics.expand((value) {
      if (value.level >= MetricValueLevel.warning) {
        return [
          p.AnalysisErrorFixes(
            p.AnalysisError(
              severityFromMetricValueLevel(value.level),
              p.AnalysisErrorType.HINT,
              p.Location(
                report.location.sourceUrl.path,
                report.location.start.offset,
                report.location.length,
                report.location.start.line,
                report.location.start.column,
              ),
              value.comment,
              value.metricsId,
              correction: value.recommendation,
              url: documentation(value.metricsId).toString(),
              contextMessages: value.context
                  .map((message) => p.DiagnosticMessage(
                        message.message,
                        p.Location(
                          message.location.sourceUrl.path,
                          message.location.start.offset,
                          message.location.length,
                          message.location.start.line,
                          message.location.start.column,
                        ),
                      ))
                  .toList(growable: false),
              hasFix: false,
            ),
          ),
        ];
      }

      return [];
    });

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
    patterns?.map((exclude) => Glob(p.join(root, exclude)))?.toList() ?? [];
