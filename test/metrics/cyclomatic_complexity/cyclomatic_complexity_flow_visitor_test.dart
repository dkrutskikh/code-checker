@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/models/processed_file.dart';
import 'package:code_checker/src/scope_visitor.dart';
import 'package:code_checker/src/metrics/cyclomatic_complexity/cyclomatic_complexity_flow_visitor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'CyclomaticComplexityFlowVisitor collects cyclomatic complexity per function',
    () async {
      final scopeVisitor = ScopeVisitor();

      final unitResult = (await resolveFile(
        path: p.normalize(p.absolute('./test/resources/complex_function.dart')),
      ))
        ..unit.visitChildren(scopeVisitor);

      final visitor = CyclomaticComplexityFlowVisitor(ProcessedFile(
        Uri.parse('file://source.dart'),
        unitResult.content,
        unitResult.unit,
      ));

      scopeVisitor.functions.single.declaration.visitChildren(visitor);

      expect(visitor.complexityElements.length, equals(14));
    },
  );
}
