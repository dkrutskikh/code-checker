// @dart=2.8

import 'models/issue.dart';
import 'models/report.dart';
import 'models/scoped_class_declaration.dart';
import 'models/scoped_function_declaration.dart';

abstract class ReportsBuilder {
  void recordClass(ScopedClassDeclaration declaration, Report report);

  void recordFunction(ScopedFunctionDeclaration declaration, Report report);

  void recordAntiPatternCases(Iterable<Issue> issues);

  void recordIssues(Iterable<Issue> issues);
}
