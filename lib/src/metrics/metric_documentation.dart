import 'package:meta/meta.dart';

import '../models/entity_type.dart';

/// Represents all metric documentation
@immutable
class MetricDocumentation {
  /// The name of a metric
  final String name;

  /// The short name of a metric
  final String shortName;

  /// The short message with formal statement of what exactly a metric calculate
  final String definition;

  /// The url of a page containing documentation associated with a metric
  final String url;

  /// Which type of entities will be measured by a metric
  final EntityType measuredEntity;

  const MetricDocumentation({
    @required this.name,
    @required this.shortName,
    @required this.definition,
    @required this.url,
    @required this.measuredEntity,
  });
}
