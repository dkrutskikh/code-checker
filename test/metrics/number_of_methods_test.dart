@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/checker.dart';
import 'package:code_checker/src/metrics/number_of_methods.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:code_checker/src/scope_visitor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('NumberOfMethodsMetric computes', () {
    final metric = NumberOfMethodsMetric();

    <String, int>{
      './test/resources/abstract_class.dart': 1,
      './test/resources/class_with_factory_constructors.dart': 4,
      './test/resources/extension.dart': 1,
      './test/resources/mixin.dart': 1,
    }.forEach((key, value) async {
      final visitor = ScopeVisitor();

      (await resolveFile(path: p.normalize(p.absolute(key))))
          .unit
          .visitChildren(visitor);

      final metricValue =
          metric.compute(visitor.classes.single, visitor.functions);

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(value));
      expect(metricValue.level, equals(MetricValueLevel.none));
    });
  });
}
