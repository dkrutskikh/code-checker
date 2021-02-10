import 'package:meta/meta.dart';

import '../models/entity_type.dart';

/// Represents any metric documentation
@immutable
class MetricDocumentation {
  /// The name of a metric
  final String name;

  /// The short name of a metric
  final String shortName;

  /// The short message with formal statement about metric
  final String brief;

  /// Which type of entities will be measured by a metric
  final EntityType measuredType;

  final Iterable<CodeExample> examples;

  const MetricDocumentation({
    @required this.name,
    @required this.shortName,
    @required this.brief,
    @required this.measuredType,
    @required this.examples,
  });
}

@immutable
class CodeExample {
  final String examplePath;

  final int startLine;

  const CodeExample({
    @required this.examplePath,
    @required this.startLine,
  });
}
