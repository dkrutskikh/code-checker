import 'package:analyzer/dart/ast/ast.dart';

import '../models/class_type.dart';
import '../models/function_type.dart';
import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';
import '../utils/metric_utils.dart';
import '../utils/scope_utils.dart';
import 'metric.dart';
import 'metric_computation_result.dart';

/// Weight Of Class (WOC)
///
/// Number of **functional** public methods divided by the total number of public methods.
class WeightOfClassMetric extends Metric<double> {
  static const String metricId = 'weight-of-class';
  static const _metricName = 'Weight Of Class';
  static const _metricShortName = 'WOC';
  static const _defaultThreshold = 0.33;

  WeightOfClassMetric({Map<String, Object> config = const {}})
      : super(
          id: metricId,
          name: _metricName,
          shortName: _metricShortName,
          documentation: null,
          threshold: readThreshold<double>(config, metricId, _defaultThreshold),
          levelComputer: invertValueLevel,
        );

  @override
  MetricComputationResult<double> computeImplementation(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
  ) {
    final totalPublicMethods =
        classFunctions(classDeclaration, functionDeclarations)
            .where((function) => !Identifier.isPrivateName(function.name))
            .toList(growable: false);

    final functionalMethods = totalPublicMethods.where((function) {
      if (function.type == FunctionType.constructor) {
        return false;
      }

      final declaration = function.declaration;
      if (declaration is MethodDeclaration) {
        return !declaration.isGetter && !declaration.isSetter;
      }

      return true;
    });

    return MetricComputationResult(
      value: functionalMethods.length / totalPublicMethods.length,
    );
  }

  @override
  String commentMessage(ClassType type, double value, double threshold) {
    final exceeds = value < threshold
        ? ', which is lower then the threshold of $threshold allowed'
        : '';

    return 'This ${type.toString().toLowerCase()} has a weight of $value$exceeds.';
  }
}
