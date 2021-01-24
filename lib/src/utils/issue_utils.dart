import 'package:source_span/source_span.dart';

import '../models/issue.dart';
import '../models/replacement.dart';
import '../rules/rule.dart';

Issue createIssue(
  Rule rule,
  SourceSpan location,
  String message,
  Replacement replacement,
) =>
    Issue(
      ruleId: rule.id,
      documentation: rule.documentation,
      location: location,
      severity: rule.severity,
      message: message,
      suggestion: replacement,
    );
