// @dart=2.8

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class DoubleLiteralVisitor extends RecursiveAstVisitor<void> {
  final _literals = <DoubleLiteral>[];

  Iterable<DoubleLiteral> get literals => _literals;

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _literals.add(node);

    super.visitDoubleLiteral(node);
  }
}
