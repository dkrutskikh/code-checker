@TestOn('vm')
import 'package:code_checker/src/checker.dart';
import 'package:code_checker/src/models/file_report.dart';
import 'package:code_checker/src/reports_store.dart';
import 'package:code_checker/src/runner.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class CheckerMock extends Mock implements Checker {}

class ReportsStoreMock extends Mock implements ReportsStore {}

void main() {
  group('Runner', () {
    test('results() returns array of FileReport', () {
      const stubReports = [
        FileReport(
          path: 'lib/foo.dart',
          relativePath: 'foo.dart',
          classes: {},
          functions: {},
          issues: [],
          antiPatternCases: [],
        ),
        FileReport(
          path: 'lib/bar.dart',
          relativePath: 'bar.dart',
          classes: {},
          functions: {},
          issues: [],
          antiPatternCases: [],
        ),
      ];

      final store = ReportsStoreMock();
      when(store.reports()).thenReturn(stubReports);

      final runner = Runner(CheckerMock(), store, const [], '');

      expect(runner.results(), equals(stubReports));
    });

    test('run() calls MetricsAnalyzer.runAnalysis for every file paths', () {
      const folders = ['lib', 'test'];
      const root = '/home/developer/project/';

      final checker = CheckerMock();
      Runner(checker, ReportsStoreMock(), folders, root).run();

      verify(checker.runAnalysis(folders, root));
      verifyNoMoreInteractions(checker);
    });
  });
}
