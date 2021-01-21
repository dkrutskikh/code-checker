@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/metrics/weight_of_class_metric.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:code_checker/src/scope_visitor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const examplePath = 'test/resources/weight_of_class_example.dart';

void main() {
  test('WeightOfClassMetric computes weight of the example class', () async {
    final metric = WeightOfClassMetric();

    final visitor = ScopeVisitor();

    (await resolveFile(path: p.normalize(p.absolute(examplePath))))
        .unit
        .visitChildren(visitor);

    final firstClassValue =
        metric.compute(visitor.classes.first, visitor.functions);

    expect(firstClassValue.metricsId, equals(metric.id));
    expect(
      firstClassValue.documentation,
      endsWith('/metrics/${metric.id}.html'),
    );
    expect(firstClassValue.value, equals(0.0));
    expect(firstClassValue.level, equals(MetricValueLevel.alarm));
    expect(
      firstClassValue.comment,
      equals(
        'This class has a weight of 0.0, which is lower then the threshold of 0.33 allowed.',
      ),
    );
    expect(firstClassValue.recommendation, isNull);

    final lastClassValue =
        metric.compute(visitor.classes.last, visitor.functions);

    expect(lastClassValue.metricsId, equals(metric.id));
    expect(
      lastClassValue.documentation,
      endsWith('/metrics/${metric.id}.html'),
    );
    expect(lastClassValue.value, equals(0.25));
    expect(lastClassValue.level, equals(MetricValueLevel.warning));
    expect(
      lastClassValue.comment,
      equals(
        'This class has a weight of 0.25, which is lower then the threshold of 0.33 allowed.',
      ),
    );
    expect(lastClassValue.recommendation, isNull);
  });
}
