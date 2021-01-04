import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'models/function_type.dart';
import 'models/scoped_class_declaration.dart';
import 'models/scoped_function_declaration.dart';

/// Visitor to collect declarations of classes and functions
class ScopeVisitor extends RecursiveAstVisitor<void> {
  final _components = <ScopedClassDeclaration>[];
  final _functions = <ScopedFunctionDeclaration>[];

  ScopedClassDeclaration _enclosingDeclaration;

  Iterable<ScopedClassDeclaration> get components => _components;

  Iterable<ScopedFunctionDeclaration> get functions => _functions;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _registerClassDeclaration(node, () {
      super.visitClassDeclaration(node);
    });
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _registerFunctionDeclaration(FunctionType.constructor, node);

    super.visitConstructorDeclaration(node);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    _registerClassDeclaration(node, () {
      super.visitExtensionDeclaration(node);
    });
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _registerFunctionDeclaration(FunctionType.function, node);

    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _registerFunctionDeclaration(FunctionType.method, node);

    super.visitMethodDeclaration(node);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    _registerClassDeclaration(node, () {
      super.visitMixinDeclaration(node);
    });
  }

  void _registerClassDeclaration(
    CompilationUnitMember node,
    void Function() visitCallback,
  ) {
    _enclosingDeclaration = ScopedClassDeclaration(node);
    _components.add(_enclosingDeclaration);

    visitCallback();

    _enclosingDeclaration = null;
  }

  void _registerFunctionDeclaration(FunctionType type, Declaration node) {
    _functions
        .add(ScopedFunctionDeclaration(type, node, _enclosingDeclaration));
  }
}
