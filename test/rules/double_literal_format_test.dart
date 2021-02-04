@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/models/severity.dart';
import 'package:code_checker/src/rules/double_literal_format/double_literal_format.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const examplePath = 'test/resources/double_literal_format_example.dart';

void main() {
  test('DoubleLiteralFormatRule reports about found issues', () async {
    final issues = DoubleLiteralFormatRule()
        .check(await resolveFile(path: p.normalize(p.absolute(examplePath))));

    expect(issues, hasLength(12));

    expect(
      issues.map((issue) => issue.ruleId).toSet().single,
      equals('double-literal-format'),
    );

    expect(
      issues.map((issue) => issue.location.start.offset),
      equals([25, 38, 57, 72, 104, 117, 135, 150, 181, 195, 214, 230]),
    );
    expect(
      issues.map((issue) => issue.location.start.line),
      equals([2, 2, 2, 2, 4, 4, 4, 4, 6, 6, 6, 6]),
    );
    expect(
      issues.map((issue) => issue.location.start.column),
      equals([12, 25, 44, 59, 12, 25, 43, 58, 12, 26, 45, 61]),
    );

    expect(
      issues.map((issue) => issue.location.end.offset),
      equals([30, 46, 62, 80, 108, 123, 139, 156, 187, 203, 220, 238]),
    );
    expect(
      issues.map((issue) => issue.location.end.line),
      equals([2, 2, 2, 2, 4, 4, 4, 4, 6, 6, 6, 6]),
    );
    expect(
      issues.map((issue) => issue.location.end.column),
      equals([17, 33, 49, 67, 16, 31, 47, 64, 18, 34, 51, 69]),
    );

    expect(
      issues.map((issue) => issue.location.text),
      equals([
        '05.23',
        '003.6e+5',
        '012.2',
        '001.1e-1',
        '.257',
        '.16e+5',
        '.259',
        '.14e-5',
        '0.2100',
        '0.100e+5',
        '0.2500',
        '0.400e-5',
      ]),
    );

    expect(
      issues.map((issue) => issue.location.sourceUrl.toString()).toSet().single,
      endsWith(examplePath),
    );

    expect(
      issues.every((issue) => issue.severity == Severity.style),
      isTrue,
    );

    expect(
      issues.map((issue) => issue.message),
      equals([
        "Double literal shouldn't have redundant leading '0'.",
        "Double literal shouldn't have redundant leading '0'.",
        "Double literal shouldn't have redundant leading '0'.",
        "Double literal shouldn't have redundant leading '0'.",
        "Double literal shouldn't begin with '.'.",
        "Double literal shouldn't begin with '.'.",
        "Double literal shouldn't begin with '.'.",
        "Double literal shouldn't begin with '.'.",
        "Double literal shouldn't have a trailing '0'.",
        "Double literal shouldn't have a trailing '0'.",
        "Double literal shouldn't have a trailing '0'.",
        "Double literal shouldn't have a trailing '0'.",
      ]),
    );

    expect(
      issues.map((issue) => issue.verboseMessage),
      equals([
        "Remove redundant leading '0'",
        "Remove redundant leading '0'",
        "Remove redundant leading '0'",
        "Remove redundant leading '0'",
        "Add missing leading '0'",
        "Add missing leading '0'",
        "Add missing leading '0'",
        "Add missing leading '0'",
        "Remove redundant trailing '0'",
        "Remove redundant trailing '0'",
        "Remove redundant trailing '0'",
        "Remove redundant trailing '0'",
      ]),
    );

    expect(
      issues.map((issue) => issue.suggestion.replacement),
      equals([
        '5.23',
        '3.6e+5',
        '12.2',
        '1.1e-1',
        '0.257',
        '0.16e+5',
        '0.259',
        '0.14e-5',
        '0.21',
        '0.1e+5',
        '0.25',
        '0.4e-5',
      ]),
    );
    expect(
      issues.map((issue) => issue.suggestion.comment),
      equals([
        "Remove redundant leading '0'",
        "Remove redundant leading '0'",
        "Remove redundant leading '0'",
        "Remove redundant leading '0'",
        "Add missing leading '0'",
        "Add missing leading '0'",
        "Add missing leading '0'",
        "Add missing leading '0'",
        "Remove redundant trailing '0'",
        "Remove redundant trailing '0'",
        "Remove redundant trailing '0'",
        "Remove redundant trailing '0'",
      ]),
    );
  });
}
