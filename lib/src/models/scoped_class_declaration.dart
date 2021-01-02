import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

/// Represents a declaration of class/mixin/extension
@immutable
class ScopedClassDeclaration {
  final CompilationUnitMember declaration;

  /// Returns user defined human readable name
  String get humanReadableName {
    if (declaration is ExtensionDeclaration) {
      return (declaration as ExtensionDeclaration).name.name;
    } else if (declaration is NamedCompilationUnitMember) {
      return (declaration as NamedCompilationUnitMember).name.name;
    }

    return '';
  }

  const ScopedClassDeclaration(this.declaration);
}
