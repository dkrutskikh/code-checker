import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'config/config.dart';
import 'metrics/metric.dart';
import 'metrics_factory.dart';
import 'models/entity_type.dart';
import 'models/issue.dart';
import 'models/report.dart';
import 'reports_builder.dart';
import 'reports_store.dart';
import 'rules/rule.dart';
import 'rules_factory.dart';
import 'scope_visitor.dart';
import 'suppressions.dart';
import 'utils/node_utils.dart';

/// Performs code quality analysis on specific files
///
/// See [Runner] to get analysis info
class Checker {
  final Iterable<Glob> _globalExclude;

  final Iterable<Rule> _codeRules;
  final Iterable<Metric> _classesMetrics;
  final Iterable<Metric> _methodsMetrics;
  final Iterable<Glob> _metricsExclude;
  final ReportsStore _store;

  Checker(this._store, Config config)
      : _globalExclude = _prepareExcludes(config?.excludePatterns),
        _codeRules = config?.rules != null ? rulesByConfig(config.rules) : [],
        _classesMetrics =
            _initializeMetrics(config.metrics, EntityType.classEntity)
                .toList(growable: false),
        _methodsMetrics =
            _initializeMetrics(config.metrics, EntityType.methodEntity)
                .toList(growable: false),
        _metricsExclude = _prepareExcludes(config?.excludeForMetricsPatterns);

  /// Return a future that will complete after static analysis done for files from [folders].
  Future<void> runAnalysis(Iterable<String> folders, String rootFolder) async {
    final collection = AnalysisContextCollection(
      includedPaths:
          folders.map((path) => p.normalize(p.join(rootFolder, path))).toList(),
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );

    final filePaths = folders
        .expand((directory) => Glob('$directory/**.dart')
            .listSync(root: rootFolder, followLinks: false)
            .whereType<File>()
            .where((entity) => !_isExcluded(
                  p.relative(entity.path, from: rootFolder),
                  _globalExclude,
                ))
            .map((entity) => entity.path))
        .toList();

    for (final filePath in filePaths) {
      final normalized = p.normalize(p.absolute(filePath));

      final analysisContext = collection.contextFor(normalized);
      final result =
          await analysisContext.currentSession.getResolvedUnit(normalized);

      final visitor = ScopeVisitor();
      result.unit.visitChildren(visitor);

      final lineInfo = result.unit.lineInfo;

      _store.recordFile(filePath, rootFolder, (builder) {
        if (!_isExcluded(
          p.relative(filePath, from: rootFolder),
          _metricsExclude,
        )) {
          _computeClassMetrics(visitor, builder, result);
          _computeMethodMetrics(visitor, builder, result);
        }

        final ignores = Suppressions(result.content, lineInfo);
        builder.recordIssues(_checkOnCodeIssues(ignores, result));
      });
    }
  }

  void _computeClassMetrics(
    ScopeVisitor visitor,
    ReportsBuilder builder,
    ResolvedUnitResult result,
  ) {
    for (final classDeclaration in visitor.classes) {
      builder.recordClass(
        classDeclaration,
        Report(
          location: nodeLocation(
            node: classDeclaration.declaration,
            source: result,
          ),
          metrics: [
            for (final metric in _classesMetrics)
              metric.compute(
                classDeclaration.declaration,
                visitor.classes,
                visitor.functions,
                result,
              ),
          ],
        ),
      );
    }
  }

  void _computeMethodMetrics(
    ScopeVisitor visitor,
    ReportsBuilder builder,
    ResolvedUnitResult result,
  ) {
    for (final functionDeclaration in visitor.functions) {
      builder.recordFunction(
        functionDeclaration,
        Report(
          location: nodeLocation(
            node: functionDeclaration.declaration,
            source: result,
          ),
          metrics: [
            for (final metric in _methodsMetrics)
              metric.compute(
                functionDeclaration.declaration,
                visitor.classes,
                visitor.functions,
                result,
              ),
          ],
        ),
      );
    }
  }

  Iterable<Issue> _checkOnCodeIssues(
    Suppressions ignores,
    ResolvedUnitResult source,
  ) =>
      _codeRules.where((rule) => !ignores.isSuppressed(rule.id)).expand(
            (rule) => rule.check(source).where((issue) => !ignores
                .isSuppressedAt(issue.ruleId, issue.location.start.line)),
          );
}

Iterable<Glob> _prepareExcludes(Iterable<String> patterns) =>
    patterns?.map((exclude) => Glob(exclude))?.toList() ?? [];

Iterable<Metric> _initializeMetrics(
  Map<String, Object> metricsConfig,
  EntityType type,
) =>
    allMetrics(metricsConfig)
        .where((metric) => metric.documentation.measuredEntity == type);

bool _isExcluded(String filePath, Iterable<Glob> excludes) =>
    excludes.any((exclude) => exclude.matches(filePath));
