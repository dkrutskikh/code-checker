@TestOn('vm')
import 'package:code_checker/src/rules/double_literal_format/double_literal_format.dart';
import 'package:code_checker/src/rules/member_ordering/member_ordering.dart';
import 'package:code_checker/src/rules/prefer_newline_before_return/prefer_newline_before_return.dart';
import 'package:code_checker/src/rules/prefer_trailing_comma/prefer_trailing_comma.dart';
import 'package:code_checker/src/rules_factory.dart';
import 'package:test/test.dart';

void main() {
  test('rulesByConfig returns only required rules', () {
    expect(rulesByConfig({}), isEmpty);
    expect(
      rulesByConfig({
        PreferNewlineBeforeReturnRule.ruleId: <String, Object>{},
        DoubleLiteralFormatRule.ruleId: <String, Object>{},
        PreferTrailingComma.ruleId: <String, Object>{},
        MemberOrderingRule.ruleId: <String, Object>{},
      }).map((rule) => rule.id),
      equals([
        DoubleLiteralFormatRule.ruleId,
        MemberOrderingRule.ruleId,
        PreferNewlineBeforeReturnRule.ruleId,
        PreferTrailingComma.ruleId,
      ]),
    );
  });
}
