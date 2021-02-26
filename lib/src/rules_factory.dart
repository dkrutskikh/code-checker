import 'rules/double_literal_format/double_literal_format.dart';
import 'rules/prefer_newline_before_return/prefer_newline_before_return.dart';
import 'rules/prefer_trailing_comma/prefer_trailing_comma.dart';
import 'rules/rule.dart';

final _implementedRules = <String, Rule Function(Map<String, Object>)>{
  DoubleLiteralFormatRule.ruleId: (config) =>
      DoubleLiteralFormatRule(config: config),
  PreferNewlineBeforeReturnRule.ruleId: (config) =>
      PreferNewlineBeforeReturnRule(config: config),
  PreferTrailingComma.ruleId: (config) => PreferTrailingComma(config: config),
};

Iterable<Rule> get allRules =>
    _implementedRules.keys.map((id) => _implementedRules[id]({})).toList();

Iterable<Rule> rulesByConfig(Map<String, Object> config) =>
    _implementedRules.keys
        .where((id) => config.keys.contains(id))
        .map((id) => _implementedRules[id](config[id] as Map<String, Object>))
        .toList();
