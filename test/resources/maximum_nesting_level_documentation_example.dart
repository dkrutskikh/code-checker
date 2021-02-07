void visitBlock(Block node) {
  final nestingNodesChain = <AstNode>[];

  AstNode astNode = node;
  do {
    if (astNode is Block &&
        (astNode?.parent is! BlockFunctionBody ||
            astNode?.parent?.parent is FunctionExpression ||
            astNode?.parent?.parent is ConstructorDeclaration)) {
      nestingNodesChain.add(astNode);
    }

    astNode = astNode.parent;
  } while (astNode.parent != _functionNode);

  if (nestingNodesChain.length > _deepestNestingNodesChain.length) {
    _deepestNestingNodesChain = nestingNodesChain;
  }

  super.visitBlock(node);
}
