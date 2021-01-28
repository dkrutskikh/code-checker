@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/scope_visitor.dart';
import 'package:code_checker/src/metrics/cyclomatic_complexity/cyclomatic_complexity_flow_visitor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'CyclomaticComplexityFlowVisitor collects cyclomatic complexity per function',
    () async {
      final scopeVisitor = ScopeVisitor();

      final result = (await resolveFile(
        path: p.normalize(p.absolute('./test/resources/complex_function.dart')),
      ))
        ..unit.visitChildren(scopeVisitor);

      final visitor = CyclomaticComplexityFlowVisitor(result);

      scopeVisitor.functions.single.declaration.visitChildren(visitor);

      expect(visitor.complexityElements, hasLength(14));
    },
  );
}
