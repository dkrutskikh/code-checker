// @dart=2.8

import 'package:analyzer/dart/analysis/results.dart';
import 'package:meta/meta.dart';

import '../models/issue.dart';
import '../models/severity.dart';
import 'rule_documentation.dart';

/// Interface that code checker uses to communicate with the rules
///
/// All rule classes must implement from this interface
abstract class Rule {
  /// The id of the rule.
  final String id;

  /// documentation associated with this rule
  final RuleDocumentation documentation;

  /// The severity of issues emitted by this rule
  final Severity severity;

  const Rule({
    @required this.id,
    @required this.documentation,
    @required this.severity,
  });

  /// Returns [Iterable] with [Issue]'s detected while check the passed [source]
  Iterable<Issue> check(ResolvedUnitResult source);
}
