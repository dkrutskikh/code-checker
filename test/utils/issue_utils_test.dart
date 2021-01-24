@TestOn('vm')
import 'package:code_checker/src/models/replacement.dart';
import 'package:code_checker/src/models/severity.dart';
import 'package:code_checker/src/rules/rule.dart';
import 'package:code_checker/src/utils/issue_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

class RuleMock extends Mock implements Rule {}

void main() {
  test('createIssue returns information issue based on passed information', () {
    const id = 'rule-id';
    final documentationUrl = Uri.parse('https://documentation.html');
    const severity = Severity.none;

    final codeUrl = Uri.parse('file://source.dart');
    final codeLocation = SourceSpan(
      SourceLocation(0, sourceUrl: codeUrl),
      SourceLocation(4, sourceUrl: codeUrl),
      'code',
    );

    const message = 'error message';

    const replacement =
        Replacement(comment: 'comment', replacement: 'new code');

    final rule = RuleMock();
    when(rule.id).thenReturn(id);
    when(rule.documentation).thenReturn(documentationUrl);
    when(rule.severity).thenReturn(severity);

    final issue = createIssue(rule, codeLocation, message, replacement);

    expect(issue.ruleId, equals(id));
    expect(issue.documentation, equals(documentationUrl));
    expect(issue.location, equals(codeLocation));
    expect(issue.severity, equals(severity));
    expect(issue.message, equals(message));
    expect(issue.suggestion, equals(replacement));
  });
}
