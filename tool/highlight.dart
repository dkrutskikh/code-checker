// @dart=2.8

class Highlight {
  final _languageMode = dart;

  bool _classNameExists(String className) => className?.isNotEmpty ?? false;

  Iterable<Mode> _expandMode(Mode mode) {
    if (mode.variants != null && mode.cachedVariants == null) {
      mode.cachedVariants = mode.variants.map((variant) {
        if (variant.ref != null) {
          variant = _languageMode.refs[variant.ref];
        }

        return Mode.inherit(mode, variant)..variants = null;
      }).toList();
    }

    return mode.cachedVariants ?? [mode];
  }

  String _joinRe(List<String> regexps, String separator) {
    var numCaptures = 0;
    final ret = StringBuffer();
    for (var i = 0; i < regexps.length; i++) {
      final offset = numCaptures;
      var re = regexps[i];
      if (i > 0) {
        ret.write(separator);
      }

      while (re.isNotEmpty) {
        final match = RegExp(r'\[(?:[^\\\]]|\\.)*\]|\(\??|\\([1-9][0-9]*)|\\.')
            .firstMatch(re);
        if (match == null) {
          ret.write(re);
          break;
        }
        ret.write(_substring(re, 0, match.start));
        re = _substring(re, match.start + match[0].length);
        if (match[0][0] == r'\' && match[1] != null) {
          ret.write('\\${int.parse(match[1]) + offset}');
        } else {
          ret.write(match[0]);
          if (match[0] == '(') {
            numCaptures++;
          }
        }
      }
    }

    return ret.toString();
  }

  void _compileMode(Mode mode, [Mode parent]) {
    if (mode.compiled == true) {
      return;
    }

    mode
      ..compiled = true
      ..keywords = mode.keywords ?? mode.beginKeywords;

    if (mode.keywords != null) {
      final compiledKeywords = <String, Object>{};

      void _flatten(String className, String str) {
        str.split(' ').forEach((kw) {
          final pair = kw.split('|');
          compiledKeywords[pair[0]] = [
            className,
            if (pair.length > 1) int.parse(pair[1]) else 1,
          ];
        });
      }

      if (mode.keywords is String) {
        _flatten('keyword', mode.keywords as String);
      } else if (mode.keywords is Map<String, String>) {
        (mode.keywords as Map<String, String>).forEach(_flatten);
      }
      mode.keywords = compiledKeywords;
    }

    mode.lexemesRe = RegExp(r'\w+', multiLine: true);

    if (parent != null) {
      if (mode.beginKeywords != null) {
        mode.begin = '\\b(${mode.beginKeywords.split(' ').join('|')})\\b';
      }
      mode
        ..begin ??= r'\B|\b'
        ..beginRe = RegExp(mode.begin, multiLine: true)
        ..end ??= r'\B|\b';
      if (mode.end != null) {
        mode.endRe = RegExp(mode.end, multiLine: true);
      }
      mode.terminatorEnd = mode.end ?? '';
    }
    if (mode.illegal != null) {
      mode.illegalRe = RegExp(mode.illegal, multiLine: true);
    }
    mode.contains ??= [];

    Mode _pointToRef(Mode m) => m.ref != null ? _languageMode.refs[m.ref] : m;

    if (mode.contains != null) {
      mode.contains = mode.contains.map(_pointToRef).toList();
    }
    if (mode.variants != null) {
      mode.variants = mode.variants.map(_pointToRef).toList();
    }

    final contains = <Mode>[];
    for (final c in mode.contains) {
      contains.addAll(_expandMode(c));
    }

    mode.contains = contains;
    for (final c in mode.contains) {
      _compileMode(c, mode);
    }

    final terminators = (mode.contains
            .map((c) =>
                c.beginKeywords != null ? '\\.?(?:${c.begin})\\.?' : c.begin)
            .toList()
              ..addAll([mode.terminatorEnd, mode.illegal]))
        .where((x) => x != null && x.isNotEmpty)
        .toList();

    mode.terminators = terminators.isNotEmpty
        ? RegExp(_joinRe(terminators, '|'), multiLine: true)
        : null;
  }

  Iterable<_Node> _buildSpan(String className, List<_Node> insideSpan) =>
      !_classNameExists(className)
          ? insideSpan
          : [_Node(className: className, children: insideSpan)];

  bool _testRe(RegExp re, String lexeme) {
    if (re != null) {
      for (final match in re.allMatches(lexeme)) {
        return match.start == 0;
      }
    }

    return false;
  }

  Mode _subMode(String lexeme, Mode top) {
    for (var i = 0; i < top.contains.length; i++) {
      if (_testRe(top.contains[i].beginRe, lexeme)) {
        return top.contains[i];
      }
    }

    return null;
  }

  void _addNodes(Iterable<_Node> nodes, List<_Node> result) {
    for (final node in nodes) {
      if (result.isEmpty ||
          result.last.children != null ||
          node.className != null) {
        result.add(node);
      } else {
        result.last.value += node.value;
      }
    }
  }

  void _addText(String text, List<_Node> result) {
    _addNodes([_Node(value: text)], result);
  }

  String parse(String source) {
    _compileMode(_languageMode);

    var top = _languageMode;
    var currentChildren = <_Node>[];
    final stack = <List<_Node>>[];

    Mode current;
    for (current = top; current != _languageMode; current = current.parent) {
      if (_classNameExists(current.className)) {
        currentChildren.add(_Node(className: current.className));
        stack.add(currentChildren);
        currentChildren = currentChildren.last.children;
      }
    }

    var modeBuffer = '';

    Iterable<_Node> _processKeywords() {
      if (top.keywords == null) {
        return [_Node(value: modeBuffer)];
      }

      final result = <_Node>[];
      var lastIndex = 0;

      var match = top.lexemesRe.firstMatch(modeBuffer);
      while (match != null) {
        _addText(_substring(modeBuffer, lastIndex, match.start), result);

        final keywordMatch = (top.keywords[match[0]] as List)?.cast<String>();
        if (keywordMatch != null) {
          _addNodes(
            _buildSpan(keywordMatch[0], [_Node(value: match[0])]),
            result,
          );
        } else {
          _addText(match[0], result);
        }
        lastIndex = match.start + match[0].length;
        match = top.lexemesRe
            .allMatches(modeBuffer, lastIndex)
            .firstWhere((m) => true, orElse: () => null);
      }

      _addText(_substring(modeBuffer, lastIndex), result);

      return result;
    }

    void _processBuffer() {
      _addNodes(_processKeywords(), currentChildren);
      modeBuffer = '';
    }

    int _processLexeme(String buffer, [String lexeme]) {
      modeBuffer += buffer;

      if (lexeme == null) {
        _processBuffer();

        return 0;
      }

      final newMode = _subMode(lexeme, top);
      if (newMode != null) {
        _processBuffer();
        modeBuffer = lexeme;
        if (_classNameExists(newMode.className)) {
          currentChildren.add(_Node(className: newMode.className));
          stack.add(currentChildren);
          currentChildren = currentChildren.last.children;
        }
        top = Mode.inherit(newMode)..parent = top;

        return lexeme.length;
      }

      if (_testRe(top.endRe, lexeme)) {
        final endMode = top;
        final origin = top;
        if (!(origin.excludeEnd == true)) {
          modeBuffer += lexeme;
        }
        _processBuffer();
        if (origin.excludeEnd == true) {
          modeBuffer = lexeme;
        }

        do {
          if (_classNameExists(top.className)) {
            currentChildren = stack.isEmpty ? [] : stack.removeLast();
          }
          top = top.parent;
        } while (top != endMode.parent);

        return lexeme.length;
      }

      if (_testRe(top.illegalRe, lexeme)) {
        throw ArgumentError(
          'Illegal lexeme "$lexeme" for mode "${top.className ?? '<unnamed>'}"',
        );
      }

      modeBuffer += lexeme;

      return lexeme.isEmpty ? 1 : lexeme.length;
    }

    RegExpMatch match;
    int count;
    var index = 0;
    // ignore: literal_only_boolean_expressions
    while (true) {
      match = top.terminators
          ?.allMatches(source, index)
          ?.firstWhere((m) => true, orElse: () => null);

      if (match == null) {
        break;
      }

      count = _processLexeme(_substring(source, index, match.start), match[0]);
      index = count + match.start;
    }
    _processLexeme(_substring(source, index));
    for (current = top; current.parent != null; current = current.parent) {
      if (_classNameExists(current.className)) {
        currentChildren = stack.isEmpty ? [] : stack.removeLast();
      }
    }

    return currentChildren.map(_traverseNode).join('');
  }
}

class _Node {
  final String className;
  String value;
  final List<_Node> children;

  _Node({this.className, this.value, this.children});
}

/// Extends builtin String.substring function
///
/// RangeError: Value not in range
String _substring(String input, int startIndex, [int endIndex]) {
  var realStartIndex = startIndex;
  var realEndIndex = endIndex ?? input.length;

  if (realStartIndex > realEndIndex) {
    final tmp = realStartIndex;
    realStartIndex = realEndIndex;
    realEndIndex = tmp;
  }

  if (realStartIndex < 0 || realStartIndex > input.length) {
    realStartIndex = 0;
  }

  if (realEndIndex < 0 || realEndIndex > input.length) {
    realEndIndex = input.length;
  }

  return input.substring(realStartIndex, realEndIndex);
}

String _traverseNode(_Node node) {
  final shouldAddSpan = node.className != null &&
      ((node.value != null && node.value.isNotEmpty) ||
          (node.children != null && node.children.isNotEmpty));

  return [
    if (shouldAddSpan) '<span class="dart-${node.className}">',
    if (node.value != null)
      node.value
          .replaceAll('&', '&amp;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;'),
    if (node.children?.isNotEmpty ?? false)
      node.children.map(_traverseNode).join(''),
    if (shouldAddSpan) '</span>',
  ].join('');
}

class Mode {
  final String ref;
  final Map<String, Mode> refs;

  /// `String | Map<String, [String, int]>`
  dynamic keywords;
  final String illegal;
  List<Mode> contains;
  Iterable<Mode> variants;
  final String className;
  String begin;
  final String beginKeywords;
  String end;

  final bool excludeEnd;

  bool compiled;
  Mode parent;
  RegExp lexemesRe;
  RegExp beginRe;
  RegExp endRe;
  RegExp illegalRe;
  String terminatorEnd;
  Iterable<Mode> cachedVariants;
  RegExp terminators;

  Mode({
    this.ref,
    this.refs,
    //
    this.keywords,
    this.illegal,
    this.contains,
    this.variants,
    this.className,
    this.begin,
    this.beginKeywords,
    this.end,
    this.excludeEnd,
    //
    this.compiled,
    this.parent,
    this.lexemesRe,
    this.beginRe,
    this.endRe,
    this.illegalRe,
    this.terminatorEnd,
    this.cachedVariants,
    this.terminators,
  });

  Mode.inherit(Mode a, [Mode b])
      : ref = b?.ref ?? a.ref,
        refs = b?.refs ?? a.refs,
        keywords = b?.keywords ?? a.keywords,
        illegal = b?.illegal ?? a.illegal,
        contains = b?.contains ?? a.contains,
        variants = b?.variants ?? a.variants,
        className = b?.className ?? a.className,
        begin = b?.begin ?? a.begin,
        beginKeywords = b?.beginKeywords ?? a.beginKeywords,
        end = b?.end ?? a.end,
        excludeEnd = b?.excludeEnd ?? a.excludeEnd,
        compiled = b?.compiled ?? a.compiled,
        parent = b?.parent ?? a.parent,
        lexemesRe = b?.lexemesRe ?? a.lexemesRe,
        beginRe = b?.beginRe ?? a.beginRe,
        endRe = b?.endRe ?? a.endRe,
        illegalRe = b?.illegalRe ?? a.illegalRe,
        terminatorEnd = b?.terminatorEnd ?? a.terminatorEnd,
        cachedVariants = b?.cachedVariants ?? a.cachedVariants,
        terminators = b?.terminators ?? a.terminators;
}

final backslashEscape = Mode(begin: r'\\[\s\S]');

final phrasalWordsMode = Mode(
  begin:
      r"\b(a|an|the|are|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|they|like|more)\b",
);

final cLineCommentMode =
    Mode(className: 'comment', begin: '//', end: r'$', contains: [
  Mode(
    begin:
        r"\b(a|an|the|are|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|they|like|more)\b",
  ),
  Mode(className: 'doctag', begin: '(?:TODO|FIXME|NOTE|BUG|XXX):'),
]);

final cBlockCommentMode =
    Mode(className: 'comment', begin: r'/\*', end: r'\*/', contains: [
  Mode(
    begin:
        r"\b(a|an|the|are|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|they|like|more)\b",
  ),
  Mode(className: 'doctag', begin: '(?:TODO|FIXME|NOTE|BUG|XXX):'),
]);

final cNumberMode = Mode(
  className: 'number',
  begin: r'(-?)(\b0[xX][a-fA-F0-9]+|(\b\d+(\.\d*)?|\.\d+)([eE][-+]?\d+)?)',
);

final underscoreTitleMode = Mode(className: 'title', begin: r'[a-zA-Z_]\w*');

final dart = Mode(
  refs: {
    '~contains~0~variants~4~contains~2': Mode(
      className: 'subst',
      variants: [Mode(begin: r'\${', end: '}')],
      keywords: 'true false null this is new super',
      contains: [cNumberMode, Mode(ref: '~contains~0')],
    ),
    '~contains~0~variants~4~contains~1':
        Mode(className: 'subst', variants: [Mode(begin: r'\$[A-Za-z0-9_]+')]),
    '~contains~0': Mode(className: 'string', variants: [
      Mode(begin: "r'''", end: "'''"),
      Mode(begin: 'r"""', end: '"""'),
      Mode(begin: "r'", end: "'", illegal: r'\n'),
      Mode(begin: 'r"', end: '"', illegal: r'\n'),
      Mode(begin: "'''", end: "'''", contains: [
        backslashEscape,
        Mode(ref: '~contains~0~variants~4~contains~1'),
        Mode(ref: '~contains~0~variants~4~contains~2'),
      ]),
      Mode(begin: '"""', end: '"""', contains: [
        backslashEscape,
        Mode(ref: '~contains~0~variants~4~contains~1'),
        Mode(ref: '~contains~0~variants~4~contains~2'),
      ]),
      Mode(begin: "'", end: "'", illegal: r'\n', contains: [
        backslashEscape,
        Mode(ref: '~contains~0~variants~4~contains~1'),
        Mode(ref: '~contains~0~variants~4~contains~2'),
      ]),
      Mode(begin: '"', end: '"', illegal: r'\n', contains: [
        backslashEscape,
        Mode(ref: '~contains~0~variants~4~contains~1'),
        Mode(ref: '~contains~0~variants~4~contains~2'),
      ]),
    ]),
  },
  keywords: {
    'keyword':
        'abstract as assert async await break case catch class const continue covariant default deferred do dynamic else enum export extends extension external factory false final finally for Function get hide if implements import in inferface is library mixin new null on operator part rethrow return set show static super switch sync this throw true try typedef var void while with yield',
    'built_in':
        'Comparable DateTime Duration Function Iterable Iterator List Map Match Null Object Pattern RegExp Set Stopwatch String StringBuffer StringSink Symbol Type Uri bool double dynamic int num print Element ElementList document querySelector querySelectorAll window',
  },
  contains: [
    Mode(ref: '~contains~0'),
    Mode(className: 'comment', begin: r'/\*\*', end: r'\*/', contains: [
      phrasalWordsMode,
      Mode(className: 'doctag', begin: '(?:TODO|FIXME|NOTE|BUG|XXX):'),
    ]),
    Mode(className: 'comment', begin: r'///+\s*', end: r'$', contains: [
      Mode(begin: '.', end: r'$'),
      phrasalWordsMode,
      Mode(className: 'doctag', begin: '(?:TODO|FIXME|NOTE|BUG|XXX):'),
    ]),
    cLineCommentMode,
    cBlockCommentMode,
    Mode(
      className: 'class',
      beginKeywords: 'class interface',
      end: '{',
      excludeEnd: true,
      contains: [
        Mode(beginKeywords: 'extends implements'),
        underscoreTitleMode,
      ],
    ),
    cNumberMode,
    Mode(className: 'meta', begin: '@[A-Za-z]+'),
    Mode(begin: '=>'),
  ],
);

const draculaThemeCss = '''
/*
Dracula Theme v1.2.0
https://github.com/dracula/dracula-theme
Copyright 2015, All rights reserved
Code licensed under the MIT license
http://zenorocha.mit-license.org
@author Éverton Ribeiro <nuxlli@gmail.com>
@author Zeno Rocha <hi@zenorocha.com>
*/

.dart {
  display: block;
  overflow-x: auto;
  padding: 0.5em;
  background: #282a36;
}

.dart-keyword,
.dart-selector-tag,
.dart-literal,
.dart-section,
.dart-link {
  color: #8be9fd;
}

.dart-function .dart-keyword {
  color: #ff79c6;
}

.dart,
.dart-subst {
  color: #f8f8f2;
}

.dart-string,
.dart-title,
.dart-name,
.dart-type,
.dart-attribute,
.dart-symbol,
.dart-bullet,
.dart-addition,
.dart-variable,
.dart-template-tag,
.dart-template-variable {
  color: #f1fa8c;
}

.dart-comment,
.dart-quote,
.dart-deletion,
.dart-meta {
  color: #6272a4;
}

.dart-keyword,
.dart-selector-tag,
.dart-literal,
.dart-title,
.dart-section,
.dart-doctag,
.dart-type,
.dart-name,
.dart-strong {
  font-weight: bold;
}

.dart-emphasis {
  font-style: italic;
}
''';
