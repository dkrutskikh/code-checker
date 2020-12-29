import 'package:meta/meta.dart';

/// Represents a single change.
@immutable
class Replacement {
  /// A human-readable description of the change to be applied.
  final String comment;

  /// Code with changes to replace original code with.
  final String replacement;

  const Replacement({
    @required this.comment,
    @required this.replacement,
  });
}
