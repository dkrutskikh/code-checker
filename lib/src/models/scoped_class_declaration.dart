import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

import 'class_type.dart';

/// Represents a declaration of class/mixin/extension
@immutable
class ScopedClassDeclaration {
  final ClassType type;
  final CompilationUnitMember declaration;

  /// Returns user defined name
  String get name {
    if (declaration is ExtensionDeclaration) {
      return (declaration as ExtensionDeclaration).name.name;
    } else if (declaration is NamedCompilationUnitMember) {
      return (declaration as NamedCompilationUnitMember).name.name;
    }

    return '';
  }

  const ScopedClassDeclaration(this.type, this.declaration);
}
