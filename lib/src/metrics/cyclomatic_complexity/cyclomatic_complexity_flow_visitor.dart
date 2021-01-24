import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:source_span/source_span.dart';

import '../../utils/node_utils.dart';

class CyclomaticComplexityFlowVisitor extends RecursiveAstVisitor<void> {
  final ResolvedUnitResult _source;

  final _complexityElements = <SourceSpanBase>[];

  CyclomaticComplexityFlowVisitor(this._source);

  Iterable<SourceSpanBase> get complexityElements => _complexityElements;

  @override
  void visitAssertStatement(AssertStatement node) {
    _increaseComplexity(node);

    super.visitAssertStatement(node);
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    _collectFunctionBodyData(
      node.block.leftBracket.next,
      node.block.rightBracket,
    );

    super.visitBlockFunctionBody(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    _increaseComplexity(node);

    super.visitCatchClause(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _increaseComplexity(node);

    super.visitConditionalExpression(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _collectFunctionBodyData(
      node.expression.beginToken.previous,
      node.expression.endToken.next,
    );

    super.visitExpressionFunctionBody(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    _increaseComplexity(node);

    super.visitForStatement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _increaseComplexity(node);

    super.visitIfStatement(node);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _increaseComplexity(node);

    super.visitSwitchCase(node);
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _increaseComplexity(node);

    super.visitSwitchDefault(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _increaseComplexity(node);

    super.visitWhileStatement(node);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _increaseComplexity(node);

    super.visitYieldStatement(node);
  }

  void _collectFunctionBodyData(Token firstToken, Token lastToken) {
    const tokenTypes = [
      TokenType.AMPERSAND_AMPERSAND,
      TokenType.BAR_BAR,
      TokenType.QUESTION_PERIOD,
      TokenType.QUESTION_QUESTION,
      TokenType.QUESTION_QUESTION_EQ,
    ];

    var token = firstToken;
    while (token != lastToken) {
      if (token.matchesAny(tokenTypes)) {
        _increaseComplexity(token);
      }

      token = token.next;
    }
  }

  void _increaseComplexity(SyntacticEntity node) {
    _complexityElements.add(nodeLocation(node: node, source: _source));
  }
}
