@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/metrics/number_of_arguments_metric.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:code_checker/src/scope_visitor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const examplePath = 'test/resources/number_of_arguments_metric_example.dart';

Future<void> main() async {
  final metric = NumberOfArgumentsMetric(
    config: {NumberOfArgumentsMetric.metricId: '3'},
  );

  final scopeVisitor = ScopeVisitor();

  final example = await resolveFile(path: p.normalize(p.absolute(examplePath)));
  example.unit.visitChildren(scopeVisitor);

  group('NumberOfArgumentsMetric computes arguments count of the', () {
    test('simple function', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.first.declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(0));
      expect(metricValue.level, equals(MetricValueLevel.none));
      expect(
        metricValue.comment,
        equals('This function has 0 arguments.'),
      );
      expect(metricValue.recommendation, isNull);
      expect(metricValue.context, isEmpty);
    });

    test('simple function with arguments', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.toList()[1].declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(2));
      expect(metricValue.level, equals(MetricValueLevel.none));
      expect(
        metricValue.comment,
        equals('This function has 2 arguments.'),
      );
      expect(metricValue.recommendation, isNull);
      expect(metricValue.context, isEmpty);
    });

    test('simple setter', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.toList()[2].declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(1));
      expect(metricValue.level, equals(MetricValueLevel.none));
      expect(
        metricValue.comment,
        equals('This function has 1 argument.'),
      );
      expect(metricValue.recommendation, isNull);
      expect(metricValue.context, isEmpty);
    });

    test('simple getter', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.toList()[3].declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(0));
      expect(metricValue.level, equals(MetricValueLevel.none));
      expect(
        metricValue.comment,
        equals('This function has 0 arguments.'),
      );
      expect(metricValue.recommendation, isNull);
      expect(metricValue.context, isEmpty);
    });

    test('class method', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.toList()[4].declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(3));
      expect(metricValue.level, equals(MetricValueLevel.noted));
      expect(
        metricValue.comment,
        equals('This method has 3 arguments.'),
      );
      expect(metricValue.recommendation, isNull);
      expect(metricValue.context, isEmpty);
    });

    test('class method 2', () {
      final metricValue = metric.compute(
        scopeVisitor.functions.last.declaration,
        scopeVisitor.classes,
        scopeVisitor.functions,
        example,
      );

      expect(metricValue.metricsId, equals(metric.id));
      expect(metricValue.value, equals(4));
      expect(metricValue.level, equals(MetricValueLevel.warning));
      expect(
        metricValue.comment,
        equals(
          'This method has 4 arguments, exceeds the maximum of 3 allowed.',
        ),
      );
      expect(metricValue.recommendation, isNull);
      expect(metricValue.context, isEmpty);
    });
  });
}
