import 'package:meta/meta.dart';

import 'code_example.dart';
import 'entity_type.dart';

/// Represents any metric documentation.
@immutable
class MetricDocumentation {
  /// The name of a metric.
  final String name;

  /// The short name of a metric.
  final String shortName;

  /// The short message with formal statement about a metric.
  final String brief;

  /// The type of entities which will be measured by a metric.
  final EntityType measuredType;

  final Iterable<CodeExample> examples;

  /// Initialize a newly created [MetricDocumentation].
  ///
  /// This data object is used for a documentation generating from a source code.
  const MetricDocumentation({
    @required this.name,
    @required this.shortName,
    @required this.brief,
    @required this.measuredType,
    @required this.examples,
  });
}
