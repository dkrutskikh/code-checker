import 'rules/double_literal_format/double_literal_format.dart';
import 'rules/newline_before_return/newline_before_return.dart';
import 'rules/rule.dart';

final _implementedRules = <String, Rule Function(Map<String, Object>)>{
  DoubleLiteralFormatRule.ruleId: (config) =>
      DoubleLiteralFormatRule(config: config),
  NewlineBeforeReturnRule.ruleId: (config) =>
      NewlineBeforeReturnRule(config: config),
};

Iterable<Rule> get allRules =>
    _implementedRules.keys.map((id) => _implementedRules[id]({})).toList();

Iterable<Rule> rulesByConfig(Map<String, Object> config) =>
    _implementedRules.keys
        .where((id) => config.keys.contains(id))
        .map((id) => _implementedRules[id](config[id] as Map<String, Object>))
        .toList();
