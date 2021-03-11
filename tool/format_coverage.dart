import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Provides the list of tokens supported by the parser.
abstract class LcovToken {
  /// The end of a section.
  static const endOfRecord = 'end_of_record';

  /// The coverage data of a line.
  static const lineData = 'DA';

  /// The number of instrumented lines.
  static const linesFound = 'LF';

  /// The number of lines with a non-zero execution count.
  static const linesHit = 'LH';

  /// The path to a source file.
  static const sourceFile = 'SF';
}

/// Provides details for line coverage.
@immutable
class LcovLineData {
  /// Creates a new line data.
  const LcovLineData({
    @required this.lineNumber,
    @required this.executionCount,
  });

  /// The execution count.
  final int executionCount;

  /// The line number.
  final int lineNumber;

  /// Returns a string representation of this object.
  @override
  String toString() => '${LcovToken.lineData}:$lineNumber,$executionCount';
}

/// Provides the coverage data of lines.
class LcovLineCoverage {
  /// Creates a new line coverage.
  LcovLineCoverage([this.found = 0, this.hit = 0, Iterable<LcovLineData> data])
      : data = data?.toList() ?? <LcovLineData>[];

  /// The coverage data.
  final List<LcovLineData> data;

  /// The number of instrumented lines.
  int found;

  /// The number of lines with a non-zero execution count.
  int hit;

  /// Returns a string representation of this object.
  @override
  String toString() {
    final buffer = StringBuffer();

    if (data.isNotEmpty) {
      buffer
        ..writeAll(data, '\n')
        ..writeln();
    }
    buffer
      ..writeln('${LcovToken.linesFound}:$found')
      ..write('${LcovToken.linesHit}:$hit');

    return buffer.toString();
  }
}

class LcovException extends FormatException {
  /// Creates a new LCOV exception.
  LcovException(String message, [String source = '', int offset = 0])
      : super(message, source, offset);
}

/// Provides the coverage data of a source file.
class LcovRecord {
  /// Creates a new record with the specified source file.
  LcovRecord(this.sourceFile, {this.lines});

  /// The path to the source file.
  String sourceFile;

  /// The line coverage.
  LcovLineCoverage lines;

  /// Returns a string representation of this object.
  @override
  String toString() {
    final buffer = StringBuffer('${LcovToken.sourceFile}:$sourceFile')
      ..writeln();

    if (lines != null) {
      buffer.writeln(lines);
    }

    buffer.write(LcovToken.endOfRecord);
    return buffer.toString();
  }
}

/// Represents a trace file, that is a coverage report.
class LcovReport {
  /// Creates a new report.
  LcovReport([Iterable<LcovRecord> records])
      : records = records?.toList() ?? <LcovRecord>[];

  /// Parses the specified [coverage] data in [LCOV](http://ltp.sourceforge.net/coverage/lcov.php) format.
  /// Throws a [LcovException] if a parsing error occurred.
  LcovReport.fromCoverage(String coverage) : records = <LcovRecord>[] {
    var offset = 0;

    try {
      LcovRecord record;
      for (var line in coverage.split(RegExp(r'\r?\n'))) {
        offset += line.length;
        line = line.trim();
        if (line.isEmpty) {
          continue;
        }

        final parts = line.split(':');
        if (parts.length < 2 && parts.first != LcovToken.endOfRecord) {
          throw LcovException('Invalid token format.', coverage, offset);
        }

        final data = parts.skip(1).join(':').split(',');
        switch (parts.first) {
          case LcovToken.sourceFile:
            record = LcovRecord(data.first)..lines = LcovLineCoverage();
            break;

          case LcovToken.lineData:
            if (data.length < 2) {
              throw LcovException('Invalid line data.', coverage, offset);
            }
            record.lines.data.add(LcovLineData(
                lineNumber: int.parse(data[0], radix: 10),
                executionCount: int.parse(data[1], radix: 10)));
            break;

          case LcovToken.linesFound:
            record.lines.found = int.parse(data.first, radix: 10);
            break;

          case LcovToken.linesHit:
            record.lines.hit = int.parse(data.first, radix: 10);
            break;

          case LcovToken.endOfRecord:
            records.add(record);
            break;

          default:
            throw LcovException('Unknown token.', coverage, offset);
        }
      }
    } on LcovException {
      rethrow;
    } on Exception {
      throw LcovException(
          'The coverage data has an invalid LCOV format.', coverage, offset);
    }
    if (records.isEmpty) {
      throw LcovException('The coverage data is empty.', coverage);
    }
  }

  /// The record list.
  final List<LcovRecord> records;

  /// Returns a string representation of this object.
  @override
  String toString() => (StringBuffer()..writeAll(records, '\n')).toString();
}

void main() {
  final lcovReportFile = File('coverage/coverage.lcov');
  if (!lcovReportFile.existsSync()) {
    _printCoverageOutputDoesNotExistBanner();

    return;
  }

  LcovReport report;

  try {
    report = LcovReport.fromCoverage(lcovReportFile.readAsStringSync());
  } on LcovException catch (err) {
    print('An error occurred: ${err.message}');

    return;
  }

  final uncoveredFiles = _getUncoveredFiles(report);
  _addFilesToReportAsUncovered(uncoveredFiles, report);

  lcovReportFile.writeAsStringSync(report.toString(), mode: FileMode.writeOnly);
  _printCoverageDetails(report);
}

void _printCoverageDetails(LcovReport report) {
  final coveredLines =
      report.records.fold<int>(0, (count, record) => count + record.lines.hit);
  final totalLines = report.records
      .fold<int>(0, (count, record) => count + record.lines.found);

  final percents = (coveredLines * 100 / totalLines).toStringAsPrecision(4);

  print('$coveredLines of $totalLines relevant lines covered ($percents%)');
}

void _printCoverageOutputDoesNotExistBanner() {
  print('Coverage lcov report does not exist.');
}

Set<String> _getUncoveredFiles(LcovReport report) {
  final coveredFiles =
      report.records.map((record) => p.relative(record.sourceFile)).toSet();
  final sourceFiles =
      _findSourceFiles(Directory('lib'), false).map((f) => f.path).toSet();

  return sourceFiles.difference(coveredFiles);
}

void _addFilesToReportAsUncovered(Iterable<String> files, LcovReport report) {
  report.records.addAll(files.map(_fileToUncoveredRecord));
}

LcovRecord _fileToUncoveredRecord(String filePath) {
  final uncoveredLines = LineSplitter.split(File(filePath).readAsStringSync())
      .map((l) => l.trim())
      .toList(growable: false)
      .asMap()
      .entries
      .where((e) =>
          e.value.isNotEmpty &&
          !e.value.startsWith('import') &&
          !e.value.startsWith('library') &&
          !e.value.startsWith('export') &&
          !e.value.startsWith('//') &&
          e.value != '}')
      .map((e) => LcovLineData(lineNumber: e.key + 1, executionCount: 0));

  return LcovRecord(
    filePath,
    lines: LcovLineCoverage(uncoveredLines.length, 0, uncoveredLines),
  );
}

Iterable<File> _findSourceFiles(Directory directory, bool skipGenerated) {
  final sourceFiles = <File>[];
  for (final fileOrDir in directory.listSync()) {
    if (fileOrDir is File &&
        _isSourceFileHaveValidExtension(fileOrDir) &&
        _isSourceFileNotPartOfLibrary(fileOrDir)) {
      sourceFiles.add(fileOrDir);
    } else if (fileOrDir is Directory &&
        p.basename(fileOrDir.path) != 'packages') {
      sourceFiles.addAll(_findSourceFiles(fileOrDir, skipGenerated));
    }
  }

  return sourceFiles;
}

bool _isSourceFileHaveValidExtension(File file) =>
    p.extension(file.path)?.endsWith('.dart') ?? false;

bool _isSourceFileNotPartOfLibrary(File file) =>
    file.readAsLinesSync().every((line) => !line.startsWith('part of '));
