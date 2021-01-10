const _options = [
  'assertStatement',
  'blockFunctionBody',
  'catchClause',
  'conditionalExpression',
  'forEachStatement',
  'forStatement',
  'ifStatement',
  'switchDefault',
  'switchCase',
  'whileStatement',
  'yieldStatement',
];

int complexityByControlFlowType(String type) {
  if (!_options.contains(type)) {
    throw ArgumentError.value(type);
  }

  return 1;
}
