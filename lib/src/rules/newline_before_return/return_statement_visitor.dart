// @dart=2.8

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class ReturnStatementVisitor extends RecursiveAstVisitor<void> {
  final _statements = <ReturnStatement>[];

  Iterable<ReturnStatement> get statements => _statements;

  @override
  void visitReturnStatement(ReturnStatement node) {
    super.visitReturnStatement(node);
    _statements.add(node);
  }
}
