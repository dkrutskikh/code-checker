// ignore_for_file: dead_code, unused_local_variable

// BlockFunctionBody
Stream<String> mapLogErrors() async* {
  // AssertStatement
  assert(false, '');

  // CatchClause
  try {
    const a = 1;
  } on Exception catch (_, __) {
    const b = 1;
  }

  // ConditionalExpression
  const c = true ? 'true' : 'false';

  // ExpressionFunctionBody
  <Object>[].map((d) => null);

  // ForStatement
  for (final e in <Object>[]) {
    final ee = e;
  }

  // IfStatement
  if (c.isNotEmpty) {
    const cc = '$c$c';
  }

  // SwitchDefault
  switch (c) {
    case 'a':
      break;
    default:
      break;
  }

  // WhileStatement
  while (c != null) {
    const cc = c;
  }

  yield c;

  // TokenType.AMPERSAND_AMPERSAND
  final d = c.isNotEmpty && true;

  // TokenType.BAR_BAR
  final e = c.isNotEmpty || false;

  // TokenType.QUESTION_PERIOD
  final f = c?.isNotEmpty;

  // TokenType.QUESTION_QUESTION
  final g = Object() ?? Object();

  // TokenType.QUESTION_QUESTION_EQ
  Object h;
  h ??= Object();
}
