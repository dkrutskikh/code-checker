@TestOn('vm')
import 'package:args/args.dart';
import 'package:code_checker/src/cli/arguments_validation.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class ArgResultsMock extends Mock implements ArgResults {}

void main() {
  group('arguments validation', () {
    group('checkPathsToAnalyzeNotEmpty', () {
      test("emits exception when arguments doesn't contains any folder", () {
        final result = ArgResultsMock();
        when(result.rest).thenReturn([]);

        expect(
          () {
            checkPathsToAnalyzeNotEmpty(result);
          },
          throwsException,
        );
      });
    });
  });
}
