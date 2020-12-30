@TestOn('vm')
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:code_checker/src/models/processed_file.dart';
import 'package:code_checker/src/utils/node_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class CompilationUnitMock extends Mock implements CompilationUnit {}

class CharacterLocationMock extends Mock implements CharacterLocation {}

class LineInfoMock extends Mock implements LineInfo {}

class SyntacticEntityMock extends Mock implements SyntacticEntity {}

void main() {
  test('nodeLocation returns information about node original code', () {
    const nodeCode = 'code';
    const preNodeCode = 'prefix ';
    const postNodeCode = ' postfix';

    const line = 2;

    const offset = preNodeCode.length;
    final offsetLineInfo = CharacterLocation(line, offset - line);

    const end = offset + nodeCode.length;
    final endLineInfo = CharacterLocation(line, end - line);

    final sourceUrl = Uri.parse('file://source.dart');

    final lineInfoMock = LineInfoMock();
    when(lineInfoMock.getLocation(offset)).thenReturn(offsetLineInfo);
    when(lineInfoMock.getLocation(end)).thenReturn(endLineInfo);

    final compilationUnitMock = CompilationUnitMock();
    when(compilationUnitMock.lineInfo).thenReturn(lineInfoMock);

    final nodeMock = SyntacticEntityMock();
    when(nodeMock.offset).thenReturn(offset);
    when(nodeMock.end).thenReturn(end);

    final span = nodeLocation(
      nodeMock,
      ProcessedFile(
        sourceUrl,
        '$preNodeCode$nodeCode$postNodeCode',
        compilationUnitMock,
      ),
    );

    expect(span.start.sourceUrl, equals(sourceUrl));
    expect(span.start.offset, equals(offset));
    expect(span.start.line, equals(line));
    expect(span.start.column, equals(offset - line));

    expect(span.end.sourceUrl, equals(sourceUrl));
    expect(span.end.offset, equals(end));
    expect(span.end.line, equals(line));
    expect(span.end.column, equals(end - line));

    expect(span.text, equals(nodeCode));
  });
}
