import 'package:meta/meta.dart';

import '../models/class_type.dart';
import '../models/metric_value.dart';
import '../models/metric_value_level.dart';
import '../models/processed_file.dart';
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
    ProcessedFile source,
  ) {
    final result =
        computeImplementation(classDeclaration, functionDeclarations, source);

    return MetricValue<T>(
      metricsId: id,
      documentation:
          'https://dart-code-checker-project.github.io/code-checker/metrics/$id.html',
      value: result.value,
      level: _levelComputer(result.value, threshold),
      comment: commentMessage(classDeclaration.type, result.value, threshold),
      recommendation:
          recommendationMessage(classDeclaration.type, result.value, threshold),
      context: result.context,
    );
  }

  @protected
  MetricComputationResult<T> computeImplementation(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ProcessedFile source,
  );

  @protected
  String commentMessage(ClassType type, T value, T threshold);

  @protected
  String recommendationMessage(ClassType type, T value, T threshold) => null;
}
