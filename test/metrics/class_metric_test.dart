@TestOn('vm')
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_checker/src/metrics/class_metric.dart';
import 'package:code_checker/src/metrics/metric_computation_result.dart';
import 'package:code_checker/src/models/class_type.dart';
import 'package:code_checker/src/models/scoped_class_declaration.dart';
import 'package:code_checker/src/models/scoped_function_declaration.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class CompilationUnitMemberMock extends Mock implements CompilationUnitMember {}

class DeclarationMock extends Mock implements Declaration {}

class ClassMetricTest extends ClassMetric<int> {
  @override
  MetricComputationResult<int> computeImplementation(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ResolvedUnitResult source,
  ) =>
      null;

  @override
  String commentMessage(String type, int value, int threshold) => null;
}

void main() {
  test('ClassMetric nodeType returns type of passed node', () {
    final firstNode = CompilationUnitMemberMock();
    final secondNode = CompilationUnitMemberMock();
    final thirdNode = CompilationUnitMemberMock();
    final fourthNode = CompilationUnitMemberMock();

    final classes = [
      ScopedClassDeclaration(ClassType.generic, firstNode),
      ScopedClassDeclaration(ClassType.mixin, secondNode),
      ScopedClassDeclaration(ClassType.extension, thirdNode),
    ];

    expect(ClassMetricTest().nodeType(firstNode, classes, []), equals('class'));
    expect(
      ClassMetricTest().nodeType(secondNode, classes, []),
      equals('mixin'),
    );
    expect(
      ClassMetricTest().nodeType(thirdNode, classes, []),
      equals('extension'),
    );
    expect(ClassMetricTest().nodeType(fourthNode, classes, []), isNull);
  });
}
