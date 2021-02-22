@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/models/severity.dart';
import 'package:code_checker/src/rules/newline_before_return/newline_before_return.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const examplePath = 'test/resources/newline_before_return_example.dart';

void main() {
  test('NewlineBeforeReturnRule reports about found issues', () async {
    final issues = NewlineBeforeReturnRule()
        .check(await resolveFile(path: p.normalize(p.absolute(examplePath))));

    expect(issues, hasLength(3));

    expect(
      issues.map((issue) => issue.ruleId).toSet().single,
      equals('newline-before-return'),
    );

    expect(
      issues.map((issue) => issue.location.start.offset),
      equals([234, 955, 1117]),
    );
    expect(
      issues.map((issue) => issue.location.start.line),
      equals([14, 59, 71]),
    );
    expect(
      issues.map((issue) => issue.location.start.column),
      equals([5, 5, 5]),
    );

    expect(
      issues.map((issue) => issue.location.end.offset),
      equals([247, 968, 1130]),
    );
    expect(
      issues.map((issue) => issue.location.end.line),
      equals([14, 59, 71]),
    );
    expect(
      issues.map((issue) => issue.location.end.column),
      equals([18, 18, 18]),
    );

    expect(
      issues.map((issue) => issue.location.text),
      equals(['return a + 1;', 'return a + 2;', 'return a + 2;']),
    );

    expect(
      issues.map((issue) => issue.location.sourceUrl.toString()).toSet().single,
      endsWith(examplePath),
    );

    expect(
      issues.map((issue) => issue.severity).toSet().single,
      equals(Severity.style),
    );

    expect(
      issues.map((issue) => issue.message).toSet().single,
      equals('Missing blank line before return'),
    );

    expect(issues.map((issue) => issue.verboseMessage).toSet().single, isNull);

    expect(issues.map((issue) => issue.suggestion).toSet().single, isNull);
  });
}
