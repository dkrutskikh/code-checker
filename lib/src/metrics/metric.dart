import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

import '../models/metric_documentation.dart';
import '../models/metric_value.dart';
import '../models/metric_value_level.dart';
import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';
import 'metric_computation_result.dart';

/// Interface that code checker uses to communicate with the metrics
///
/// All metric classes must extends from this interface
abstract class Metric<T extends num> {
  /// The id of the metric
  final String id;

  /// documentation associated with this metric
  final MetricDocumentation documentation;

  final T threshold;

  final MetricValueLevel Function(num, num) _levelComputer;

  const Metric({
    @required this.id,
    @required this.documentation,
    @required this.threshold,
    @required MetricValueLevel Function(num, num) levelComputer,
  }) : _levelComputer = levelComputer;

  /// Returns computed [MetricValue]
  MetricValue<T> compute(
    Declaration node,
    Iterable<ScopedClassDeclaration> classDeclarations,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ResolvedUnitResult source,
  ) {
    final result = computeImplementation(
      node,
      classDeclarations,
      functionDeclarations,
      source,
    );

    final type = nodeType(node, classDeclarations, functionDeclarations) ?? '';

    return MetricValue<T>(
      metricsId: id,
      documentation: documentation,
      value: result.value,
      level: _levelComputer(result.value, threshold),
      comment: commentMessage(type, result.value, threshold),
      recommendation: recommendationMessage(type, result.value, threshold),
      context: result.context,
    );
  }

  @protected
  MetricComputationResult<T> computeImplementation(
    Declaration node,
    Iterable<ScopedClassDeclaration> classDeclarations,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ResolvedUnitResult source,
  );

  @protected
  String commentMessage(String nodeType, T value, T threshold);

  @protected
  String recommendationMessage(String nodeType, T value, T threshold) => null;

  @protected
  String nodeType(
    Declaration node,
    Iterable<ScopedClassDeclaration> classDeclarations,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
  );
}
