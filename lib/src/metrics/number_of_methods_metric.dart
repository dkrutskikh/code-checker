import 'package:analyzer/dart/analysis/results.dart';

import '../models/class_type.dart';
import '../models/entity_type.dart';
import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';
import '../utils/metric_utils.dart';
import '../utils/scope_utils.dart';
import 'metric.dart';
import 'metric_computation_result.dart';
import 'metric_documentation.dart';

const _documentation = MetricDocumentation(
  name: 'Number of Methods',
  shortName: 'NOM',
  brief: 'The number of methods of a class.',
  definition: [],
  measuredEntity: EntityType.classEntity,
);

/// Number of Methods (NOM)
///
/// The number of methods of a class
class NumberOfMethodsMetric extends Metric<int> {
  static const String metricId = 'number-of-methods';

  NumberOfMethodsMetric({Map<String, Object> config = const {}})
      : super(
          id: metricId,
          documentation: _documentation,
          threshold: readThreshold<int>(config, metricId, 10),
          levelComputer: valueLevel,
        );

  @override
  MetricComputationResult<int> computeImplementation(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ResolvedUnitResult source,
  ) =>
      MetricComputationResult(
        value: classMethods(classDeclaration, functionDeclarations).length,
      );

  @override
  String commentMessage(ClassType type, int value, int threshold) {
    final methods = '$value ${value == 1 ? 'method' : 'methods'}';
    final exceeds = value > threshold
        ? ', which exceeds the maximum of $threshold allowed'
        : '';

    return 'This ${type.toString().toLowerCase()} has $methods$exceeds.';
  }

  @override
  String recommendationMessage(ClassType type, int value, int threshold) =>
      (value > threshold)
          ? 'Consider breaking this ${type.toString().toLowerCase()} up into smaller parts.'
          : null;
}
