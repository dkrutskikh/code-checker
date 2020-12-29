import 'package:meta/meta.dart';

import '../models/issue.dart';
import '../models/processed_file.dart';
import '../models/severity.dart';

/// Interface that code checker uses to communicate with the rules.
///
/// All rule classes must implement from this interface
abstract class Rule {
  /// The id of the rule.
  final String id;

  /// The url of a page containing documentation associated with this rule.
  final Uri documentation;

  /// The severity of issues emitted by this rule.
  final Severity severity;

  const Rule({
    @required this.id,
    @required this.documentation,
    @required this.severity,
  });

  /// Returns [Iterable] with [Issue]'s detected while check the passed [file]
  Iterable<Issue> check(ProcessedFile file);
}
