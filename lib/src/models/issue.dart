import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import 'severity.dart';

/// Represents a issue detected by the analysis rule
@immutable
class Issue {
  /// The id of the rule associated with this issue.
  final String ruleId;

  /// The url of a page containing documentation associated with this issue.
  final Uri documentation;

  /// The source location associated with this issue.
  final SourceSpanBase location;

  /// The severity of this issue.
  final Severity severity;

  /// Short message (single line)
  final String message;

  /// Verbose message containing information about how the user can fix this issue.
  final String verboseMessage;

  /// Code with fixed issue to replace original code with
  final String suggestion;

  /// A human-readable description of the change to be applied.
  final String suggestionComment;

  const Issue({
    @required this.ruleId,
    @required this.documentation,
    @required this.location,
    @required this.severity,
    @required this.message,
    this.verboseMessage,
    this.suggestion,
    this.suggestionComment,
  });
}
