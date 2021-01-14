import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';

Iterable<ScopedFunctionDeclaration> classMethods(
  ScopedClassDeclaration classDeclaration,
  Iterable<ScopedFunctionDeclaration> functionDeclarations,
) =>
    functionDeclarations
        .where((func) => func.enclosingDeclaration == classDeclaration)
        .toList(growable: false);
