import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import '../models/processed_file.dart';

/// Returns [SourceSpanBase] with information about original code for [node] from [source]
SourceSpanBase nodeLocation({
  @required SyntacticEntity node,
  @required ProcessedFile source,
  bool withCommentOrMetadata = false,
}) {
  final offset = !withCommentOrMetadata && node is AnnotatedNode
      ? node.firstTokenAfterCommentAndMetadata.offset
      : node.offset;
  final end = node.end;

  final offsetLocation = source.parsedContent.lineInfo.getLocation(offset);
  final endLocation = source.parsedContent.lineInfo.getLocation(end);

  return SourceSpanBase(
    SourceLocation(
      offset,
      sourceUrl: source.url,
      line: offsetLocation.lineNumber,
      column: offsetLocation.columnNumber,
    ),
    SourceLocation(
      end,
      sourceUrl: source.url,
      line: endLocation.lineNumber,
      column: endLocation.columnNumber,
    ),
    source.content.substring(offset, end),
  );
}
