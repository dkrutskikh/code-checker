// @dart=2.8

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class NestingLevelVisitor extends RecursiveAstVisitor<void> {
  final AstNode _functionNode;
  var _deepestNestingNodesChain = <AstNode>[];

  Iterable<AstNode> get deepestNestingNodesChain => _deepestNestingNodesChain;

  NestingLevelVisitor(this._functionNode);

  @override
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
}
