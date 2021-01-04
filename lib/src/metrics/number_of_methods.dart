import '../models/scoped_class_declaration.dart';
import '../models/scoped_function_declaration.dart';

/// Number of Methods (NOM)
///
/// The number of methods of a class
class NumberOfMethodsMetric {
  int compute(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
  ) =>
      _classFunctions(classDeclaration, functionDeclarations).length;

  Iterable<ScopedFunctionDeclaration> _classFunctions(
    ScopedClassDeclaration classDeclaration,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
  ) =>
      functionDeclarations
          .where((func) => func.enclosingDeclaration == classDeclaration);
}
