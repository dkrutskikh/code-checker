import 'models/file_report.dart';
import 'reports_builder.dart';

abstract class ReportsStore {
  /// File reports saved so far
  Iterable<FileReport> reports();

  /// Add new file record for [filePath] using [ReportsBuilder] in [f]
  ///
  /// See [ReportsBuilder] interface on how to build new [FileReport]
  ReportsStore recordFile(
    String filePath,
    String rootDirectory,
    void Function(ReportsBuilder) f,
  );
}
