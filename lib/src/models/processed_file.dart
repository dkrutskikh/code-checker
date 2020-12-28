import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

/// Represents a file that is being processed
@immutable
class ProcessedFile {
  /// Path of the file that is being processed
  final Uri url;

  /// Representation content of the file in plain text
  final String content;

  /// Representation content of the file in AST structure
  final CompilationUnit parsedContent;

  const ProcessedFile(this.url, this.content, this.parsedContent);
}
