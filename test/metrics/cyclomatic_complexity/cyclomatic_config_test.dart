@TestOn('vm')
import 'package:code_checker/src/metrics/cyclomatic_complexity/cyclomatic_config.dart';
import 'package:test/test.dart';

void main() {
  group('complexityByControlFlowType', () {
    const flowTypes = [
      'assertStatement',
      'blockFunctionBody',
      'catchClause',
      'conditionalExpression',
      'forEachStatement',
      'forStatement',
      'ifStatement',
      'switchDefault',
      'switchCase',
      'whileStatement',
      'yieldStatement',
    ];

    test('returns complexity for flow type', () {
      expect(
        flowTypes.map(complexityByControlFlowType).toSet().single,
        equals(1),
      );
    });

    test('throws exception for unknown flow type', () {
      expect(
        () {
          complexityByControlFlowType('unknown type');
        },
        throwsArgumentError,
      );
    });
  });
}
