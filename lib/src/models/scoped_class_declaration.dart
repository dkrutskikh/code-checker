import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

/// Represents a declaration of class/mixin/extension
@immutable
class ScopedClassDeclaration {
  final CompilationUnitMember declaration;

  const ScopedClassDeclaration(this.declaration);
}
