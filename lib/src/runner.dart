// @dart=2.8

import 'package:meta/meta.dart';

import 'checker.dart';
import 'models/file_report.dart';
import 'reports_store.dart';

/// Coordinates [Checker] and [ReportsStore] to collect code quality info
///
/// Use [Reporter] to produce reports from collected info
@immutable
class Runner {
  final Checker _analyzer;
  final ReportsStore _store;
  final Iterable<String> _folders;
  final String _rootFolder;

  const Runner(this._analyzer, this._store, this._folders, this._rootFolder);

  /// Get results of analysis run. Will return empty iterable if [run()] wasn't executed yet
  Iterable<FileReport> results() => _store.reports();

  /// Perform analysis of file paths passed in constructor
  Future<void> run() => _analyzer.runAnalysis(_folders, _rootFolder);
}
