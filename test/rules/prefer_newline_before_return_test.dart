@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/models/severity.dart';
import 'package:code_checker/src/rules/prefer_newline_before_return/prefer_newline_before_return.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const examplePath = 'test/resources/prefer_newline_before_return_example.dart';

void main() {
  test('PreferNewlineBeforeReturnRule reports about found issues', () async {
    final issues = PreferNewlineBeforeReturnRule()
        .check(await resolveFile(path: p.normalize(p.absolute(examplePath))));

    expect(issues, hasLength(3));

    expect(
      issues.map((issue) => issue.ruleId).toSet().single,
      equals('prefer_newline_before_return'),
    );

    expect(
      issues.map((issue) => issue.location.start.offset),
      equals([264, 985, 1147]),
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
      equals([277, 998, 1160]),
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
