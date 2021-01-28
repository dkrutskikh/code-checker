import 'models/class_report.dart';
import 'models/function_report.dart';
import 'models/issue.dart';
import 'models/scoped_class_declaration.dart';
import 'models/scoped_function_declaration.dart';

abstract class ReportsBuilder {
  void recordClass(ScopedClassDeclaration declaration, ClassReport report);

  void recordFunction(
    ScopedFunctionDeclaration declaration,
    FunctionReport report,
  );

  void recordAntiPatternCases(Iterable<Issue> issues);

  void recordIssues(Iterable<Issue> issues);
}
