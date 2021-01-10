import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';
import '../utils/metric_utils.dart';
import 'metric.dart';

/// Number of Methods (NOM)
///
/// The number of methods of a class
class NumberOfMethodsMetric extends Metric<int> {
  static const String metricId = 'number-of-methods';
  static const _metricName = 'Number of Methods';
  static const _metricShortName = 'NOM';
  static const _defaultThreshold = 10;

  NumberOfMethodsMetric({Map<String, Object> config = const {}})
      : super(
          id: metricId,
          name: _metricName,
          shortName: _metricShortName,
          documentation: null,
          threshold: readThreshold<int>(config, metricId, _defaultThreshold),
          levelComputer: valueLevel,
        );

  @override
  int computeImplementation(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
  ) =>
      _classFunctions(classDeclaration, functionDeclarations).length;

  Iterable<ScopedFunctionDeclaration> _classFunctions(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
  ) =>
      functionDeclarations
          .where((func) => func.enclosingDeclaration == classDeclaration);
}
