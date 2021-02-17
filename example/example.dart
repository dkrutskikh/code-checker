import 'dart:io';

import 'package:code_checker/checker.dart';
import 'package:code_checker/reporters.dart';

Future<void> main() async {
  // Get some folder you would like to analyze
  const foldersToAnalyze = ['lib', 'test'];

  // Root folder path is used to resolve relative file paths
  const rootFolder = 'projectRoot';

  // First of all config has to be created for a checker
  const config = Config(
    excludePatterns: ['test/resources/**'],
    excludeForMetricsPatterns: ['test/**'],
    metrics: {
      'maximum-nesting-level': '5',
      'number-of-methods': '10',
    },
    rules: {
      'double-literal-format': {},
      'newline-before-return': {'severity': 'info'},
    },
  );

  // Store keeps reported issues in format-agnostic way
  final store = ReportsStore.store();

  // Checker traverses files and report its findings to passed store
  final checker = Checker(store, config);

  // Runner coordinates checker and store
  final runner = Runner(checker, store, foldersToAnalyze, rootFolder);

  // Execute run() to analyze files and collect results
  await runner.run();

  // Now runner.results() contains some insights about analyzed code. Let's report it!
  // For a simple example we would report results to terminal

  // Now the reporter itself
  final reporter = ConsoleReporter(stdout);

  // Now pass collected analysis reports from runner to reporter and that's it
  reporter.report(runner.results());

  // There is also JsonReporter for making machine-readable reports
  // If none of these fits your case you can always access raw analysis info via results() method of runner and process it any way you see fit
}
