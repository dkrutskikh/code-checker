import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_checker/src/models/code_example.dart';

import '../models/entity_type.dart';
import '../models/metric_documentation.dart';
import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';
import '../utils/metric_utils.dart';
import 'function_metric.dart';
import 'metric_computation_result.dart';

const _documentation = MetricDocumentation(
  name: 'Number of Arguments',
  shortName: 'NOA',
  brief: 'Number of arguments used in a method',
  measuredType: EntityType.methodEntity,
  examples: [
    CodeExample(
      examplePath: 'test/resources/number_of_arguments_metric_example.dart',
      startLine: 28,
      endLine: 42,
    ),
  ],
);

/// Number of Arguments (NOA)
///
/// Simply counts the number of arguments received by a method.
class NumberOfArgumentsMetric extends FunctionMetric<int> {
  static const String metricId = 'number-of-arguments';

  NumberOfArgumentsMetric({Map<String, Object> config = const {}})
      : super(
          id: metricId,
          documentation: _documentation,
          threshold: readThreshold<int>(config, metricId, 4),
          levelComputer: valueLevel,
        );

  @override
  MetricComputationResult<int> computeImplementation(
    Declaration node,
    Iterable<ScopedClassDeclaration> classDeclarations,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ResolvedUnitResult source,
  ) {
    int argumentsCount;
    if (node is FunctionDeclaration) {
      argumentsCount = node.functionExpression?.parameters?.parameters?.length;
    } else if (node is MethodDeclaration) {
      argumentsCount = node?.parameters?.parameters?.length;
    }

    return MetricComputationResult(value: argumentsCount ?? 0);
  }

  @override
  String commentMessage(String nodeType, int value, int threshold) {
    final exceeds =
        value > threshold ? ', exceeds the maximum of $threshold allowed' : '';
    final arguments = '$value ${value == 1 ? 'argument' : 'arguments'}';

    return 'This $nodeType has $arguments$exceeds.';
  }
}
