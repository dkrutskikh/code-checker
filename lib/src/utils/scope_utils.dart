// @dart=2.8

import 'package:analyzer/dart/ast/ast.dart';

import '../models/scoped_function_declaration.dart';

Iterable<ScopedFunctionDeclaration> classMethods(
  Declaration classNode,
  Iterable<ScopedFunctionDeclaration> functionDeclarations,
) =>
    functionDeclarations
        .where((func) => func.enclosingDeclaration?.declaration == classNode)
        .toList(growable: false);
