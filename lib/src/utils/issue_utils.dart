import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import '../models/issue.dart';
import '../models/replacement.dart';
import '../rules/rule.dart';
import 'metric_utils.dart';

Issue createIssue({
  @required Rule rule,
  @required SourceSpan location,
  @required String message,
  String verboseMessage,
  Replacement replacement,
}) =>
    Issue(
      ruleId: rule.id,
      documentation: documentation(rule.id),
      location: location,
      severity: rule.severity,
      message: message,
      verboseMessage: verboseMessage,
      suggestion: replacement,
    );
