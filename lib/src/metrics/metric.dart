import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

import '../models/metric_value.dart';
import '../models/metric_value_level.dart';
import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';
import 'metric_computation_result.dart';
import 'metric_documentation.dart';

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
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ResolvedUnitResult source,
  ) {
    final result =
        computeImplementation(classDeclaration, functionDeclarations, source);

    return MetricValue<T>(
      metricsId: id,
      value: result.value,
      level: _levelComputer(result.value, threshold),
      comment: commentMessage(
          classDeclaration.type.toString(), result.value, threshold),
      recommendation: recommendationMessage(
          classDeclaration.type.toString(), result.value, threshold),
      context: result.context,
    );
  }

  @protected
  MetricComputationResult<T> computeImplementation(
    ScopedClassDeclaration classDeclaration,
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
