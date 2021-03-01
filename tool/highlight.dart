import 'dart:convert';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

const _keywords = [
  Keyword.ABSTRACT,
  Keyword.AS,
  Keyword.ASSERT,
  Keyword.ASYNC,
  Keyword.AWAIT,
  Keyword.BREAK,
  Keyword.CASE,
  Keyword.CLASS,
  Keyword.CONST,
  Keyword.CONTINUE,
  Keyword.COVARIANT,
  Keyword.DEFAULT,
  Keyword.DEFERRED,
  Keyword.ENUM,
  Keyword.EXPORT,
  Keyword.EXTENDS,
  Keyword.EXTENSION,
  Keyword.EXTERNAL,
  Keyword.FACTORY,
  Keyword.FINAL,
  Keyword.GET,
  Keyword.HIDE,
  Keyword.IMPLEMENTS,
  Keyword.IMPORT,
  Keyword.IN,
  Keyword.IS,
  Keyword.LATE,
  Keyword.LIBRARY,
  Keyword.MIXIN,
  Keyword.NATIVE,
  Keyword.NEW,
  Keyword.OF,
  Keyword.ON,
  Keyword.OPERATOR,
  Keyword.PART,
  Keyword.REQUIRED,
  Keyword.RETHROW,
  Keyword.RETURN,
  Keyword.SET,
  Keyword.SHOW,
  Keyword.STATIC,
  Keyword.SUPER,
  Keyword.SYNC,
  Keyword.THIS,
  Keyword.THROW,
  Keyword.TYPEDEF,
  Keyword.VAR,
  Keyword.WITH,
  Keyword.YIELD,
];

const _blockKeywords = {
  Keyword.CATCH,
  Keyword.DO,
  Keyword.ELSE,
  Keyword.FINALLY,
  Keyword.FOR,
  Keyword.IF,
  Keyword.SWITCH,
  Keyword.TRY,
  Keyword.WHILE,
};

const _atoms = {Keyword.FALSE, Keyword.NULL, Keyword.TRUE};

const _builtins = {
  'void',
  'bool',
  'num',
  'int',
  'double',
  'dynamic',
  'String',
  'Null',
  'Never',
  'Function',
};

const _comments = {TokenType.MULTI_LINE_COMMENT, TokenType.SINGLE_LINE_COMMENT};

const _number = {TokenType.DOUBLE, TokenType.HEXADECIMAL, TokenType.INT};

const String cssTheme = '''
.dart {
  display: block;
  overflow-x: auto;
  padding: 0.5em;
}

.dart-number {
  color: #627978;
}

.dart-comment {
  color: #9198B4;
}

.dart-keyword {
  color: #51C686;
}

.dart-atom {
  color: #EE8666;
}

.dart-builtins {
  color: #C0C2C5;
}

.dart-operator {
  color: #C0C2C5;
}

.dart-variable {
  color: #16ADCA;
}

.dart-variable2 {
  color: #EE8666;
}

.dart-meta {
  color: #627978;
}

.dart-string {
  color: #E55074;
}
''';

@immutable
class HighlightRange {
  final int offset;
  final int end;
  final String style;

  const HighlightRange({
    @required this.offset,
    @required this.end,
    @required this.style,
  });
}

class Highlight {
  Future<Node> parse({
    @required String sourcePath,
    bool withLineIdices = false,
    int startLine,
    int endLine,
  }) async {
    final headBlock = Element.tag('tr');
    if (withLineIdices) {
      headBlock.append(Element.tag('th'));
    }
    headBlock.append(Element.tag('th'));

    final contentBlock = Element.tag('tr');
    if (withLineIdices) {
      contentBlock.append(lineIndices(1, endLine - startLine));
    }

    contentBlock
        .append(await codeHighligh(sourcePath, startLine, endLine - startLine));

    return Element.tag('table')
      ..classes.add('highlight')
      ..append(Element.tag('tbody')..append(headBlock)..append(contentBlock));
  }

  Element lineIndices(int startIndex, int count) {
    final linesIndices = Element.tag('code');
    for (var i = startIndex; i < (startIndex + count); ++i) {
      linesIndices.append(Element.tag('span')..text = '$i\n');
    }

    return Element.tag('td')..append(linesIndices);
  }

  Future<Element> codeHighligh(
    String sourcePath,
    int startLine,
    int count,
  ) async {
    final source = await resolveFile(path: p.normalize(p.absolute(sourcePath)));

    final higlights = <HighlightRange>[];

    var token = source.unit.beginToken;
    while (token != source.unit.endToken) {
      final tokenRange = _tokenColor(token);
      if (tokenRange != null) {
        higlights.add(tokenRange);
      }
      if (token.precedingComments != null) {
        Token commentToken = token.precedingComments;
        while (commentToken != null) {
          final commentTokenRange = _tokenColor(commentToken);
          if (commentTokenRange != null) {
            higlights.add(commentTokenRange);
          }

          commentToken = commentToken.next;
        }
      }

      token = token.next;
    }

    higlights.sort((a, b) => a.offset.compareTo(b.offset));

    var highlightedContent = source.content;
    for (final range in higlights.reversed) {
      highlightedContent = highlightedContent.replaceRange(
        range.offset,
        range.end,
        '<span class="${range.style}">${highlightedContent.substring(range.offset, range.end)}</span>',
      );
    }

    final sourceLines = LineSplitter.split(highlightedContent)
        .toList()
        .sublist(startLine, startLine + count)
        .join('\n');

    return Element.tag('td')
      ..append(Element.tag('code')..append(DocumentFragment.html(sourceLines)));
  }

  HighlightRange _tokenColor(Token token) {
    if (token == null) {
      return null;
    }

    String style;
    if (_number.contains(token.type)) {
      style = 'dart-number';
    } else if (_comments.contains(token.type)) {
      style = 'dart-comment';
    } else if (token.isKeyword &&
        (_keywords.contains(token.keyword) ||
            _blockKeywords.contains(token.keyword))) {
      style = 'dart-keyword';
    } else if (token.isKeyword && _atoms.contains(token.keyword)) {
      style = 'dart-atom';
    } else if (_builtins.contains(token.lexeme)) {
      style = 'dart-builtins';
    } else if (token.isOperator) {
      style = 'dart-operator';
    } else if (token.isIdentifier && token.previous?.type != TokenType.AT) {
      final isCapitalized =
          RegExp(r'^[_$]*[A-Z][a-zA-Z0-9_$]*$').hasMatch(token.lexeme);
      style = isCapitalized ? 'dart-variable2' : 'dart-variable';
    } else if ((token.type == TokenType.AT &&
            (token.next?.isIdentifier ?? false)) ||
        (token.isIdentifier && token.previous?.type == TokenType.AT)) {
      style = 'dart-meta';
    } else if (token.type == TokenType.STRING) {
      style = 'dart-string';
    }

    if (style != null) {
      return HighlightRange(
        offset: token.offset,
        end: token.end,
        style: style,
      );
    }

    return null;
  }
}
