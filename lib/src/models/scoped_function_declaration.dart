import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

import 'function_type.dart';
import 'scoped_class_declaration.dart';

/// Represents a declaration of method/function
@immutable
class ScopedFunctionDeclaration {
  final FunctionType type;
  final Declaration declaration;
  final ScopedClassDeclaration enclosingDeclaration;

  const ScopedFunctionDeclaration(
    this.type,
    this.declaration,
    this.enclosingDeclaration,
  );
}
