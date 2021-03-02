import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_checker/src/metrics/function_metric.dart';
import 'package:code_checker/src/metrics/metric_computation_result.dart';
import 'package:code_checker/src/models/scoped_class_declaration.dart';
import 'package:code_checker/src/models/scoped_function_declaration.dart';

void simpleFunction() {
  // simple comment

  print('simple report');
}

void simpleFunctionWithArguments(
  int a, {
  String b,
}) {}

set simpleSetter(num value) {}

String get simpleGetter => '';

class NumberOfParametersMetric extends FunctionMetric<int> {
  @override
  String commentMessage(String nodeType, int value, int threshold) => '';

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
}
