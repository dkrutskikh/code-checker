@TestOn('vm')
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_checker/src/models/class_type.dart';
import 'package:code_checker/src/models/function_type.dart';
import 'package:code_checker/src/models/issue.dart';
import 'package:code_checker/src/models/replacement.dart';
import 'package:code_checker/src/models/scoped_class_declaration.dart';
import 'package:code_checker/src/models/scoped_function_declaration.dart';
import 'package:code_checker/src/models/severity.dart';
import 'package:code_checker/src/reports_recorder.dart';
import 'package:mockito/mockito.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

import 'stub_builders.dart';

class ClassDeclarationMock extends Mock implements ClassDeclaration {}

class FunctionDeclarationMock extends Mock implements FunctionDeclaration {}

class SimpleIdentifierMock extends Mock implements SimpleIdentifier {}

void main() {
  group('ReportsRecorder', () {
    const filePath = '/home/developer/work/project/example.dart';
    const rootDirectory = '/home/developer/work/project/';

    group('recordFile', () {
      test('throws ArgumentError if called without filePath', () {
        expect(
          () {
            ReportsRecorder().recordFile(null, null, null);
          },
          throwsArgumentError,
        );
      });

      test('throws ArgumentError if called without function', () {
        expect(
          () {
            ReportsRecorder().recordFile(filePath, rootDirectory, null);
          },
          throwsArgumentError,
        );
      });

      group('Stores class reports for file', () {
        const className = 'simpleClass';

        final simpleIdentifierMock = SimpleIdentifierMock();
        when(simpleIdentifierMock.name).thenReturn(className);

        final classDeclarationMock = ClassDeclarationMock();
        when(classDeclarationMock.name).thenReturn(simpleIdentifierMock);

        test('throws ArgumentError if called without record', () {
          expect(
            () {
              ReportsRecorder().recordFile(
                filePath,
                rootDirectory,
                (recorder) {
                  recorder.recordClass(null, null);
                },
              );
            },
            throwsArgumentError,
          );
        });

        test('Stores record for file', () {
          final record =
              ScopedClassDeclaration(ClassType.generic, classDeclarationMock);

          final classReport = buildReportStub();

          expect(
            ReportsRecorder()
                .recordFile(filePath, rootDirectory, (recorder) {
                  recorder.recordClass(record, classReport);
                })
                .reports()
                .single
                .classes,
            containsPair(className, classReport),
          );
        });
      });

      group('Stores function reports for file', () {
        const functionName = 'simpleFunction';

        final simpleIdentifierMock = SimpleIdentifierMock();
        when(simpleIdentifierMock.name).thenReturn(functionName);

        final functionDeclarationMock = FunctionDeclarationMock();
        when(functionDeclarationMock.name).thenReturn(simpleIdentifierMock);

        final record = ScopedFunctionDeclaration(
          FunctionType.function,
          functionDeclarationMock,
          null,
        );

        test('throws ArgumentError if called without record', () {
          expect(
            () {
              ReportsRecorder().recordFile(
                filePath,
                rootDirectory,
                (recorder) {
                  recorder.recordFunction(null, null);
                },
              );
            },
            throwsArgumentError,
          );
        });

        test('Stores record for file', () {
          final functionReport = buildReportStub();

          expect(
            ReportsRecorder()
                .recordFile(filePath, rootDirectory, (recorder) {
                  recorder.recordFunction(record, functionReport);
                })
                .reports()
                .single
                .functions,
            containsPair(functionName, functionReport),
          );
        });
      });

      group('Stores issues for file', () {
        test('aggregates issues for file', () {
          const _issueRuleId = 'ruleId1';
          const _issueRuleDocumentation = 'https://docu.edu/ruleId1.html';
          const _issueMessage = 'first issue message';
          const _issueCorrection = 'correction';
          const _issueCorrectionComment = 'correction comment';

          final issueRecord = ReportsRecorder()
              .recordFile(filePath, rootDirectory, (recorder) {
                recorder.recordIssues([
                  Issue(
                    ruleId: _issueRuleId,
                    documentation: Uri.parse(_issueRuleDocumentation),
                    location: SourceSpan(
                      SourceLocation(
                        1,
                        sourceUrl: Uri.parse(filePath),
                        line: 2,
                        column: 3,
                      ),
                      SourceLocation(6, sourceUrl: Uri.parse(filePath)),
                      'issue',
                    ),
                    severity: Severity.style,
                    message: _issueMessage,
                    suggestion: const Replacement(
                      comment: _issueCorrectionComment,
                      replacement: _issueCorrection,
                    ),
                  ),
                ]);
              })
              .reports()
              .single
              .issues
              .single;

          expect(issueRecord.ruleId, _issueRuleId);
          expect(
            issueRecord.documentation.toString(),
            _issueRuleDocumentation,
          );
          expect(issueRecord.message, _issueMessage);
          expect(issueRecord.suggestion.comment, _issueCorrectionComment);
          expect(issueRecord.suggestion.replacement, _issueCorrection);
        });
      });
    });

    group('recordClass', () {
      const className = 'simpleClass';

      final simpleIdentifierMock = SimpleIdentifierMock();
      when(simpleIdentifierMock.name).thenReturn(className);

      final classDeclarationMock = ClassDeclarationMock();
      when(classDeclarationMock.name).thenReturn(simpleIdentifierMock);

      final record =
          ScopedClassDeclaration(ClassType.generic, classDeclarationMock);

      test('throws StateError if we call them in invalid state', () {
        expect(
          () {
            ReportsRecorder().recordClass(record, null);
          },
          throwsStateError,
        );
      });

      test('throws ArgumentError if we call them without record', () {
        expect(
          () {
            ReportsRecorder().recordFile(
              filePath,
              rootDirectory,
              (recorder) {
                recorder.recordClass(null, null);
              },
            );
          },
          throwsArgumentError,
        );
      });

      test('store record for file', () {
        final classReport = buildReportStub();

        final recorder =
            ReportsRecorder().recordFile(filePath, rootDirectory, (recorder) {
          recorder.recordClass(record, classReport);
        });

        expect(
          recorder.reports().single.classes,
          containsPair(className, classReport),
        );
      });
    });

    group('recordFunction', () {
      const functionName = 'simpleFunction';

      final simpleIdentifierMock = SimpleIdentifierMock();
      when(simpleIdentifierMock.name).thenReturn(functionName);

      final functionDeclarationMock = FunctionDeclarationMock();
      when(functionDeclarationMock.name).thenReturn(simpleIdentifierMock);

      final record = ScopedFunctionDeclaration(
        FunctionType.function,
        functionDeclarationMock,
        null,
      );

      test('throws StateError if we call them in invalid state', () {
        expect(
          () {
            ReportsRecorder().recordFunction(record, null);
          },
          throwsStateError,
        );
      });

      test('throws ArgumentError if we call them without record', () {
        expect(
          () {
            ReportsRecorder().recordFile(
              filePath,
              rootDirectory,
              (recorder) {
                recorder.recordFunction(null, null);
              },
            );
          },
          throwsArgumentError,
        );
      });

      test('store record for file', () {
        final functionReport = buildReportStub();

        final recorder =
            ReportsRecorder().recordFile(filePath, rootDirectory, (recorder) {
          recorder.recordFunction(record, functionReport);
        });

        expect(
          recorder.reports().single.functions,
          containsPair(functionName, functionReport),
        );
      });
    });

    group('recordAntiPatternCases', () {
      test('throws StateError if we call them in invalid state', () {
        expect(
          () {
            ReportsRecorder().recordAntiPatternCases([]);
          },
          throwsStateError,
        );
      });

      test('aggregate issues for file', () {
        const _issuePatternId = 'patternId1';
        const _issuePatternDocumentation = 'https://docu.edu/patternId1.html';
        const _issueMessage = 'first pattern message';
        const _issueRecommendation = 'recommendation';

        final recorder =
            ReportsRecorder().recordFile(filePath, rootDirectory, (recorder) {
          recorder.recordAntiPatternCases([
            Issue(
              ruleId: _issuePatternId,
              documentation: Uri.parse(_issuePatternDocumentation),
              location: SourceSpan(
                SourceLocation(
                  1,
                  sourceUrl: Uri.parse(filePath),
                  line: 2,
                  column: 3,
                ),
                SourceLocation(6, sourceUrl: Uri.parse(filePath)),
                'issue',
              ),
              severity: Severity.none,
              message: _issueMessage,
              verboseMessage: _issueRecommendation,
            ),
          ]);
        });

        final issue = recorder.reports().single.antiPatternCases.single;
        expect(issue.ruleId, _issuePatternId);
        expect(
          issue.documentation.toString(),
          _issuePatternDocumentation,
        );
        expect(issue.message, _issueMessage);
        expect(issue.verboseMessage, _issueRecommendation);
      });
    });

    group('recordIssues', () {
      test('throws StateError if we call them in invalid state', () {
        expect(
          () {
            ReportsRecorder().recordIssues([]);
          },
          throwsStateError,
        );
      });

      test('aggregate issues for file', () {
        const _issueRuleId = 'ruleId1';
        const _issueRuleDocumentation = 'https://docu.edu/ruleId1.html';
        const _issueMessage = 'first issue message';
        const _issueCorrection = 'correction';
        const _issueCorrectionComment = 'correction comment';

        final recorder =
            ReportsRecorder().recordFile(filePath, rootDirectory, (recorder) {
          recorder.recordIssues([
            Issue(
              ruleId: _issueRuleId,
              documentation: Uri.parse(_issueRuleDocumentation),
              severity: Severity.style,
              location: SourceSpan(
                SourceLocation(
                  1,
                  sourceUrl: Uri.parse(filePath),
                  line: 2,
                  column: 3,
                ),
                SourceLocation(6, sourceUrl: Uri.parse(filePath)),
                'issue',
              ),
              message: _issueMessage,
              suggestion: const Replacement(
                comment: _issueCorrectionComment,
                replacement: _issueCorrection,
              ),
            ),
          ]);
        });

        final issue = recorder.reports().single.issues.single;
        expect(issue.ruleId, _issueRuleId);
        expect(issue.documentation.toString(), _issueRuleDocumentation);
        expect(issue.message, _issueMessage);
        expect(issue.suggestion.comment, _issueCorrectionComment);
        expect(issue.suggestion.replacement, _issueCorrection);
      });
    });
  });
}
