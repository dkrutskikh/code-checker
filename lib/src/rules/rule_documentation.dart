// @dart=2.8

import 'package:meta/meta.dart';

/// Represents any rule documentation
@immutable
class RuleDocumentation {
  /// The name of a rule
  final String name;

  /// The short message with formal statement about rule
  final String brief;

  const RuleDocumentation({
    @required this.name,
    @required this.brief,
  });
}
