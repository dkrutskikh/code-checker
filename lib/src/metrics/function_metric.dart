import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

import '../models/metric_value_level.dart';
import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';
import 'metric.dart';
import 'metric_documentation.dart';

abstract class FunctionMetric<T extends num> extends Metric<T> {
  const FunctionMetric({
    @required String id,
    @required MetricDocumentation documentation,
    @required T threshold,
    @required MetricValueLevel Function(num, num) levelComputer,
  }) : super(
          id: id,
          documentation: documentation,
          threshold: threshold,
          levelComputer: levelComputer,
        );

  @override
  String nodeType(
    Declaration node,
    Iterable<ScopedClassDeclaration> classDeclarations,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
  ) =>
      functionDeclarations
          .firstWhere(
            (declaration) => declaration.declaration == node,
            orElse: () => null,
          )
          ?.type
          ?.toString();
}
