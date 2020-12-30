import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:source_span/source_span.dart';

import '../models/processed_file.dart';

/// Returns [SourceSpanBase] with information about original code for [node] from [source]
SourceSpanBase nodeLocation(SyntacticEntity node, ProcessedFile source) {
  final offsetLocation = source.parsedContent.lineInfo.getLocation(node.offset);
  final endLocation = source.parsedContent.lineInfo.getLocation(node.end);

  return SourceSpanBase(
    SourceLocation(
      node.offset,
      sourceUrl: source.url,
      line: offsetLocation.lineNumber,
      column: offsetLocation.columnNumber,
    ),
    SourceLocation(
      node.end,
      sourceUrl: source.url,
      line: endLocation.lineNumber,
      column: endLocation.columnNumber,
    ),
    source.content.substring(node.offset, node.end),
  );
}
