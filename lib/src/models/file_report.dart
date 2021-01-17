import 'package:meta/meta.dart';

import 'class_report.dart';
import 'issue.dart';

/// Represents the metrics report collected for a file
@immutable
class FileReport {
  /// The path to the target file
  final String path;

  /// The path to the target file relative to the package root
  final String relativePath;

  /// The all classes reports in the target file
  final Map<String, ClassReport> classes;

  /// The issues detected in the target file
  final Iterable<Issue> issues;

  /// The anti-pattern cases detected in the target file
  final Iterable<Issue> antiPatternCases;

  const FileReport({
    @required this.path,
    @required this.relativePath,
    @required this.classes,
    @required this.issues,
    @required this.antiPatternCases,
  });
}
