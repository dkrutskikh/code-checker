import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

@immutable
class ScopedClassDeclaration {
  final CompilationUnitMember declaration;

  const ScopedClassDeclaration(this.declaration);
}
