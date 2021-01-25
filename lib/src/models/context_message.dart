import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

/// Represents a message with relevant information associated with a diagnostic
@immutable
class ContextMessage {
  /// The message to be displayed to the user
  final String message;

  /// The source location associated with or referenced by the message
  final SourceSpan location;

  const ContextMessage({@required this.message, @required this.location});
}
