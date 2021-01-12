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

  /// Returns user defined name
  String get name {
    if (declaration is FunctionDeclaration) {
      return (declaration as FunctionDeclaration).name?.name;
    } else if (declaration is ConstructorDeclaration) {
      return (declaration as ConstructorDeclaration).name?.name ??
          (declaration.parent as NamedCompilationUnitMember).name?.name;
    } else if (declaration is MethodDeclaration) {
      return (declaration as MethodDeclaration).name?.name;
    }

    return null;
  }

  /// Returns full user defined name
  ///
  /// using the pattern `className.methodName`
  String get fullName {
    final className = enclosingDeclaration?.name;
    final functionName = name;

    return functionName == null
        ? null
        : (className == null ? name : '$className.$functionName');
  }

  const ScopedFunctionDeclaration(
    this.type,
    this.declaration,
    this.enclosingDeclaration,
  );
}
