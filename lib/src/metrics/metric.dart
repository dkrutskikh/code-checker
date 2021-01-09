import 'package:meta/meta.dart';

import '../models/metric_value.dart';
import '../models/metric_value_level.dart';
import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';

/// Interface that code checker uses to communicate with the metrics.
///
/// All metric classes must extends from this interface
abstract class Metric<T extends num> {
  /// The id of the metric.
  final String id;

  /// The name of the metric.
  final String name;

  /// The url of a page containing documentation associated with this metric.
  final Uri documentation;

  final T threshold;

  final MetricValueLevel Function(num, num) _levelComputer;

  const Metric({
    @required this.id,
    @required this.name,
    @required this.documentation,
    @required this.threshold,
    @required MetricValueLevel Function(num, num) levelComputer,
  }) : _levelComputer = levelComputer;

  /// Returns computed [MetricValue]
  MetricValue<T> compute(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
  ) {
    final value = computeImplementation(classDeclaration, functionDeclarations);

    return MetricValue<T>(
      metricsId: id,
      value: value,
      level: _levelComputer(value, threshold),
    );
  }

  @protected
  T computeImplementation(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
  );
}
