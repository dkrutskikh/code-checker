import 'package:meta/meta.dart';

import '../models/entity_type.dart';

/// Represents all metric documentation
@immutable
class MetricDocumentation {
  /// The name of a metric
  final String name;

  /// The short name of a metric
  final String shortName;

  /// The short message with formal statement about metric
  final String brief;

  /// The message with detailed statement of what exactly a metric calculate
  ///
  /// (Markdown format supported)
  final String details;

  /// Which type of entities will be measured by a metric
  final EntityType measuredType;

  const MetricDocumentation({
    @required this.name,
    @required this.shortName,
    @required this.brief,
    @required this.details,
    @required this.measuredType,
  });
}
