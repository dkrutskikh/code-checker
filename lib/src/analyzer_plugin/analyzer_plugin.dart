import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/context/builder.dart';
// ignore: implementation_imports
import 'package:analyzer/src/context/context_root.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;

class CheckerAnalyzerPlugin extends ServerPlugin {
  var _filesFromSetPriorityFilesRequest = <String>[];

  @override
  String get contactInfo =>
      'https://github.com/dart-code-checker-project/code-checker/issues';

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'Code Checker';

  @override
  String get version => '1.0.0';

  CheckerAnalyzerPlugin(ResourceProvider provider) : super(provider);

  @override
  void contentChanged(String path) {
    super.driverForPath(path).addFile(path);
  }

  @override
  AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
    final root = ContextRoot(
      contextRoot.root,
      contextRoot.exclude,
      pathContext: resourceProvider.pathContext,
    )..optionsFilePath = contextRoot.optionsFile;

    final contextBuilder = ContextBuilder(resourceProvider, sdkManager, null)
      ..analysisDriverScheduler = analysisDriverScheduler
      ..byteStore = byteStore
      ..performanceLog = performanceLog
      ..fileContentOverlay = fileContentOverlay;

    final dartDriver = contextBuilder.buildDriver(root);

    runZonedGuarded(
      () {
        dartDriver.results.listen((analysisResult) {
          _processResult(dartDriver, analysisResult);
        });
      },
      (e, stackTrace) {
        channel.sendNotification(
          plugin.PluginErrorParams(false, e.toString(), stackTrace.toString())
              .toNotification(),
        );
      },
    );

    return dartDriver;
  }

  @override
  Future<plugin.AnalysisSetContextRootsResult> handleAnalysisSetContextRoots(
    plugin.AnalysisSetContextRootsParams parameters,
  ) async {
    final result = await super.handleAnalysisSetContextRoots(parameters);
    // The super-call adds files to the driver, so we need to prioritize them so they get analyzed.
    _updatePriorityFiles();

    return result;
  }

  @override
  Future<plugin.AnalysisSetPriorityFilesResult> handleAnalysisSetPriorityFiles(
    plugin.AnalysisSetPriorityFilesParams parameters,
  ) async {
    _filesFromSetPriorityFilesRequest = parameters.files;
    _updatePriorityFiles();

    return plugin.AnalysisSetPriorityFilesResult();
  }

  @override
  Future<plugin.EditGetFixesResult> handleEditGetFixes(
    plugin.EditGetFixesParams parameters,
  ) async {
    try {
      final driver = driverForPath(parameters.file) as AnalysisDriver;
      final analysisResult = await driver.getResult(parameters.file);

      final fixes = _check(driver, analysisResult)
          .where((fix) =>
              fix.error.location.file == parameters.file &&
              fix.error.location.offset <= parameters.offset &&
              parameters.offset <=
                  fix.error.location.offset + fix.error.location.length &&
              fix.fixes.isNotEmpty)
          .toList();

      return plugin.EditGetFixesResult(fixes);
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(
        plugin.PluginErrorParams(false, e.toString(), stackTrace.toString())
            .toNotification(),
      );

      return plugin.EditGetFixesResult([]);
    }
  }

  void _processResult(
    AnalysisDriver driver,
    ResolvedUnitResult analysisResult,
  ) {
    try {
      if (analysisResult.unit != null &&
          analysisResult.libraryElement != null) {
        final fixes = _check(driver, analysisResult);

        channel.sendNotification(plugin.AnalysisErrorsParams(
          analysisResult.path,
          fixes.map((fix) => fix.error).toList(),
        ).toNotification());
      } else {
        channel.sendNotification(
          plugin.AnalysisErrorsParams(analysisResult.path, []).toNotification(),
        );
      }
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(
        plugin.PluginErrorParams(false, e.toString(), stackTrace.toString())
            .toNotification(),
      );
    }
  }

  Iterable<plugin.AnalysisErrorFixes> _check(
    AnalysisDriver driver,
    ResolvedUnitResult analysisResult,
  ) =>
      <plugin.AnalysisErrorFixes>[];

  /// AnalysisDriver doesn't fully resolve files that are added via `addFile`; they need to be either explicitly requested
  /// via `getResult`/etc, or added to `priorityFiles`.
  ///
  /// This method updates `priorityFiles` on the driver to include:
  ///
  /// - Any files prioritized by the analysis server via [handleAnalysisSetPriorityFiles]
  /// - All other files the driver has been told to analyze via addFile (in [ServerPlugin.handleAnalysisSetContextRoots])
  ///
  /// As a result, [_processResult] will get called with resolved units, and thus all of our diagnostics
  /// will get run on all files in the repo instead of only the currently open/edited ones!
  void _updatePriorityFiles() {
    final filesToFullyResolve = {
      // Ensure these go first, since they're actually considered priority; ...
      ..._filesFromSetPriorityFilesRequest,

      // ... all other files need to be analyzed, but don't trump priority
      for (final driver2 in driverMap.values)
        ...(driver2 as AnalysisDriver).addedFiles,
    };

    // From ServerPlugin.handleAnalysisSetPriorityFiles
    final filesByDriver = <AnalysisDriverGeneric, List<String>>{};
    for (final file in filesToFullyResolve) {
      final contextRoot = contextRootContaining(file);
      if (contextRoot != null) {
        // TODO(dkrutskikh): Which driver should we use if there is no context root?
        final driver = driverMap[contextRoot];
        filesByDriver.putIfAbsent(driver, () => <String>[]).add(file);
      }
    }
    filesByDriver.forEach((driver, files) {
      driver.priorityFiles = files;
    });
  }
}
