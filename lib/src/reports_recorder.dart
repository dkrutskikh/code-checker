import 'package:path/path.dart' as p;

import 'models/class_report.dart';
import 'models/file_report.dart';
import 'models/function_report.dart';
import 'models/issue.dart';
import 'models/scoped_class_declaration.dart';
import 'models/scoped_function_declaration.dart';
import 'reports_builder.dart';
import 'reports_store.dart';

/// Holds analysis reports in format-agnostic way
///
/// See [Runner] to get analysis info
class ReportsRecorder implements ReportsBuilder, ReportsStore {
  String _fileGroupPath;
  String _relativeGroupPath;
  Map<ScopedClassDeclaration, ClassReport> _classRecords;
  Map<ScopedFunctionDeclaration, FunctionReport> _functionRecords;
  List<Issue> _issues;
  List<Issue> _antiPatternCases;

  final _reports = <FileReport>[];

  @override
  Iterable<FileReport> reports() => _reports;

  @override
  ReportsStore recordFile(
    String filePath,
    String rootDirectory,
    void Function(ReportsBuilder) f,
  ) {
    if (filePath == null) {
      throw ArgumentError.notNull('filePath');
    }

    if (f == null) {
      throw ArgumentError.notNull('f');
    }

    _startRecordFile(filePath, rootDirectory);
    f(this);
    _endRecordFile();

    return this;
  }

  @override
  void recordClass(ScopedClassDeclaration declaration, ClassReport report) {
    _checkState();

    if (declaration == null) {
      throw ArgumentError.notNull('declaration');
    }

    _classRecords[declaration] = report;
  }

  @override
  void recordFunction(
    ScopedFunctionDeclaration declaration,
    FunctionReport report,
  ) {
    _checkState();

    if (declaration == null) {
      throw ArgumentError.notNull('declaration');
    }

    _functionRecords[declaration] = report;
  }

  @override
  void recordAntiPatternCases(Iterable<Issue> issues) {
    _checkState();

    _antiPatternCases.addAll(issues);
  }

  @override
  void recordIssues(Iterable<Issue> issues) {
    _checkState();

    _issues.addAll(issues);
  }

  void _checkState() {
    if (_fileGroupPath == null) {
      throw StateError('No one file have been started for record. '
          'Use `recordFile` before record any data.');
    }
  }

  void _startRecordFile(String filePath, String rootDirectory) {
    _fileGroupPath = filePath;
    _relativeGroupPath = rootDirectory != null
        ? p.relative(filePath, from: rootDirectory)
        : filePath;
    _classRecords = {};
    _functionRecords = {};
    _issues = [];
    _antiPatternCases = [];
  }

  void _endRecordFile() {
    _reports.add(FileReport(
      path: _fileGroupPath,
      relativePath: _relativeGroupPath,
      classes: Map.unmodifiable(_classRecords.map<String, ClassReport>(
        (key, value) => MapEntry(key.name, value),
      )),
      functions: Map.unmodifiable(_functionRecords.map<String, FunctionReport>(
        (key, value) => MapEntry(key.name, value),
      )),
      issues: _issues,
      antiPatternCases: _antiPatternCases,
    ));
    _relativeGroupPath = null;
    _fileGroupPath = null;
    _functionRecords = null;
    _issues = null;
    _antiPatternCases = null;
  }
}
