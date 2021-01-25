@TestOn('vm')
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_checker/src/metrics/function_metric.dart';
import 'package:code_checker/src/metrics/metric_computation_result.dart';
import 'package:code_checker/src/models/class_type.dart';
import 'package:code_checker/src/models/function_type.dart';
import 'package:code_checker/src/models/scoped_class_declaration.dart';
import 'package:code_checker/src/models/scoped_function_declaration.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class CompilationUnitMemberMock extends Mock implements CompilationUnitMember {}

class DeclarationMock extends Mock implements Declaration {}

class FunctionMetricTest extends FunctionMetric<int> {
  @override
  MetricComputationResult<int> computeImplementation(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ResolvedUnitResult source,
  ) =>
      null;

  @override
  String commentMessage(ClassType type, int value, int threshold) => null;
}

void main() {
  test('FunctionMetric nodeType returns type of passed node', () {
    final firstNode = CompilationUnitMemberMock();
    final secondNode = CompilationUnitMemberMock();
    final thirdNode = CompilationUnitMemberMock();
    final fourthNode = CompilationUnitMemberMock();
    final fifthNode = CompilationUnitMemberMock();
    final sixthNode = CompilationUnitMemberMock();

    final functions = [
      ScopedFunctionDeclaration(FunctionType.constructor, firstNode, null),
      ScopedFunctionDeclaration(FunctionType.method, secondNode, null),
      ScopedFunctionDeclaration(FunctionType.function, thirdNode, null),
      ScopedFunctionDeclaration(FunctionType.getter, fourthNode, null),
      ScopedFunctionDeclaration(FunctionType.setter, fifthNode, null),
    ];

    expect(
      FunctionMetricTest().nodeType(firstNode, [], functions),
      equals('Constructor'),
    );
    expect(
      FunctionMetricTest().nodeType(secondNode, [], functions),
      equals('Method'),
    );
    expect(
      FunctionMetricTest().nodeType(thirdNode, [], functions),
      equals('Function'),
    );
    expect(
      FunctionMetricTest().nodeType(fourthNode, [], functions),
      equals('Getter'),
    );
    expect(
      FunctionMetricTest().nodeType(fifthNode, [], functions),
      equals('Setter'),
    );
    expect(FunctionMetricTest().nodeType(sixthNode, [], functions), isNull);
  });
}
