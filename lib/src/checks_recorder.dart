import 'package:code_checker/checker.dart';
import 'package:code_checker/rules.dart';

abstract class ChecksRecorder {
  void recordClass(ScopedClassDeclaration declaration, ClassReport report);

  void recordDesignIssues(Iterable<Issue> issues);

  void recordIssues(Iterable<Issue> issues);
}
