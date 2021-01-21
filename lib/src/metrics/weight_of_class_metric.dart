import 'package:analyzer/dart/ast/ast.dart';

import '../models/class_type.dart';
import '../models/entity_type.dart';
import '../models/function_type.dart';
import '../models/processed_file.dart';
import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';
import '../utils/metric_utils.dart';
import '../utils/scope_utils.dart';
import 'metric.dart';
import 'metric_computation_result.dart';
import 'metric_documentation.dart';

const _documentation = MetricDocumentation(
  name: 'Weight Of a Class',
  shortName: 'WOC',
  definition:
      'The number of "functional" public methods divided by the total number of public members',
  measuredEntity: EntityType.classEntity,
);

/// Weight Of a Class (WOC)
///
/// Number of **functional** public methods divided by the total number of public methods
class WeightOfClassMetric extends Metric<double> {
  static const String metricId = 'weight-of-class';

  WeightOfClassMetric({Map<String, Object> config = const {}})
      : super(
          id: metricId,
          documentation: _documentation,
          threshold: readThreshold<double>(config, metricId, 0.33),
          levelComputer: invertValueLevel,
        );

  @override
  MetricComputationResult<double> computeImplementation(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ProcessedFile source,
  ) {
    final totalPublicMethods =
        classMethods(classDeclaration, functionDeclarations)
            .where(_isPublicMethod)
            .toList(growable: false);

    final functionalMethods = totalPublicMethods.where(_isFunctionalMethod);

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

  bool _isPublicMethod(ScopedFunctionDeclaration function) =>
      !Identifier.isPrivateName(function.name);

  bool _isFunctionalMethod(ScopedFunctionDeclaration function) {
    const _nonFunctionalTypes = {
      FunctionType.constructor,
      FunctionType.setter,
      FunctionType.getter,
    };

    return !_nonFunctionalTypes.contains(function.type);
  }
}
