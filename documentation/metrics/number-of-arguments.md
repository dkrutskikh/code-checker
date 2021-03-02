# Number of Arguments

The number of arguments is the number of arguments received by a method (_function_). If a method receive too many arguments, it is difficult to call and also difficult to change if it is called from many different places.

Example:

```dart
  MetricComputationResult<int> computeImplementation(
    Declaration node,
    Iterable<ScopedClassDeclaration> classDeclarations,
    Iterable<ScopedFunctionDeclaration> functionDeclarations,
    ResolvedUnitResult source,
  ) {
    int argumentsCount;
    if (node is FunctionDeclaration) {
      argumentsCount = node.functionExpression?.parameters?.parameters?.length;
    } else if (node is MethodDeclaration) {
      argumentsCount = node?.parameters?.parameters?.length;
    }

    return MetricComputationResult(value: argumentsCount ?? 0);
  }
```

**Number of Arguments** for example function is **4**.
