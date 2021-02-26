@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/models/severity.dart';
import 'package:code_checker/src/rules/prefer_trailing_comma/prefer_trailing_comma.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const examplePath = 'test/resources/prefer_trailing_comma_example.dart';

void main() {
  test('PreferTrailingComma reports about found issues', () async {
    final issues = PreferTrailingComma()
        .check(await resolveFile(path: p.normalize(p.absolute(examplePath))));

    expect(issues, hasLength(12));

    expect(
      issues.map((issue) => issue.ruleId).toSet().single,
      equals('prefer_trailing_comma'),
    );

    expect(
      issues.map((issue) => issue.location.start.offset),
      equals([
        265,
        540,
        739,
        1449,
        1574,
        1683,
        1936,
        2454,
        2620,
        2912,
        3207,
        3595,
      ]),
    );
    expect(
      issues.map((issue) => issue.location.start.line),
      equals([
        12,
        26,
        32,
        79,
        85,
        89,
        110,
        140,
        145,
        164,
        181,
        197,
      ]),
    );
    expect(
      issues.map((issue) => issue.location.start.column),
      equals([50, 7, 43, 52, 9, 8, 3, 59, 50, 3, 3, 3]),
    );

    expect(
      issues.map((issue) => issue.location.end.offset),
      equals([
        285,
        578,
        750,
        1469,
        1612,
        1702,
        1945,
        2469,
        2633,
        2950,
        3245,
        3673,
      ]),
    );
    expect(
      issues.map((issue) => issue.location.end.line),
      equals([12, 26, 32, 79, 85, 89, 110, 140, 145, 164, 181, 197]),
    );
    expect(
      issues.map((issue) => issue.location.end.column),
      equals([70, 45, 54, 72, 47, 27, 12, 74, 63, 41, 41, 81]),
    );

    expect(
      issues.map((issue) => issue.location.text),
      equals([
        'String thirdArgument',
        "'and another string for length exceed'",
        'String arg3',
        'String thirdArgument',
        "'and another string for length exceed'",
        "'some other string'",
        'sixthItem',
        'this.forthField',
        '3.14159265359',
        "'and another string for length exceed'",
        "'and another string for length exceed'",
        "'and another string for length exceed': 'and another string for length exceed'",
      ]),
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
      equals('Missing trailing comma'),
    );

    expect(issues.map((issue) => issue.verboseMessage).toSet().single, isNull);

    expect(
      issues.map((issue) => issue.suggestion.comment).toSet().single,
      equals('Add trailing comma'),
    );

    expect(issues.map((issue) => issue.suggestion.replacement), const [
      'String thirdArgument,',
      "'and another string for length exceed',",
      'String arg3,',
      'String thirdArgument,',
      "'and another string for length exceed',",
      "'some other string',",
      'sixthItem,',
      'this.forthField,',
      '3.14159265359,',
      "'and another string for length exceed',",
      "'and another string for length exceed',",
      "'and another string for length exceed': 'and another string for length exceed',",
    ]);
  });
}
