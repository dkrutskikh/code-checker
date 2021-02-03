import 'package:source_span/source_span.dart';

import '../models/issue.dart';
import '../models/replacement.dart';
import '../rules/rule.dart';
import 'metric_utils.dart';

Issue createIssue(
  Rule rule,
  SourceSpan location,
  String message,
  Replacement replacement,
) =>
    Issue(
      ruleId: rule.id,
      documentation: documentation(rule.id),
      location: location,
      severity: rule.severity,
      message: message,
      suggestion: replacement,
    );
