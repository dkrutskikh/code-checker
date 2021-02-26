import 'package:analyzer/dart/analysis/results.dart';

import '../../models/issue.dart';
import '../../models/replacement.dart';
import '../../models/severity.dart';
import '../../utils/issue_utils.dart';
import '../../utils/node_utils.dart';
import '../../utils/rule_utils.dart';
import '../rule.dart';
import '../rule_documentation.dart';
import 'multi_line_enumerations_visitor.dart';

// Inspired by ESLint (https://eslint.org/docs/rules/comma-dangle) and DartCodeMetrics (https://pub.dev/packages/dart_code_metrics)

const _documentation = RuleDocumentation(
  name: 'Prefer Trailing Comma',
  brief: 'Enforces add trailing commas wherever possible',
);

const _warningMessage = 'Missing trailing comma';
const _correctionMessage = 'Add trailing comma';

class PreferTrailingComma extends Rule {
  static const String ruleId = 'prefer_trailing_comma';

  PreferTrailingComma({Map<String, Object> config = const {}})
      : super(
          id: ruleId,
          documentation: _documentation,
          severity: readSeverity(config, Severity.style),
        );

  @override
  Iterable<Issue> check(ResolvedUnitResult source) {
    final visitor = MultiLineEnumerationsVisitor(source.lineInfo);

    source.unit.visitChildren(visitor);

    return visitor.nodes.map(
      (node) {
        final targetNodeLocation = nodeLocation(node: node, source: source);

        return createIssue(
          rule: this,
          location: targetNodeLocation,
          message: _warningMessage,
          replacement: Replacement(
            comment: _correctionMessage,
            replacement:
                '${source.content.substring(targetNodeLocation.start.offset, targetNodeLocation.end.offset)},',
          ),
        );
      },
    ).toList(growable: false);
  }
}
