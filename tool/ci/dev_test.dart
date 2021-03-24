@TestOn('vm')
import 'package:test/test.dart';

import 'dev.dart';

void main() {
  group('CI Dev tests', () {
    group('getDevChangesImportance returns', () {
      test('unknown for empty changelog', () {
        expect(getDevChangesImportance([]), equals(ChangesImportance.unknown));
        expect(
          getDevChangesImportance(['# Changelog', '']),
          equals(ChangesImportance.unknown),
        );
      });
      test('unknown for changelog without dev block', () {
        expect(
          getDevChangesImportance([
            '# Changelog',
            '',
            '## 0.10.0 - 2021-03-08',
            '',
            '* Add `Cyclomatic Complexity` metric',
            '* Add `Number of Parameters` metric',
          ]),
          equals(ChangesImportance.unknown),
        );
      });
      test('unknown for unknown importance form changelog with dev block', () {
        expect(
          getDevChangesImportance([
            '# Changelog',
            '',
            '## NEW FEATURE',
            '',
            '* changes',
            '* changes',
          ]),
          equals(ChangesImportance.unknown),
        );
      });
      test('parsed importance for changelog with dev block', () {
        expect(
          getDevChangesImportance([
            '# Changelog',
            '',
            '## MAJOR',
            '',
            '* changes',
            '* changes',
          ]),
          equals(ChangesImportance.major),
        );
        expect(
          getDevChangesImportance([
            '# Changelog',
            '',
            '## MINOR',
            '',
            '* changes',
            '* changes',
          ]),
          equals(ChangesImportance.minor),
        );
        expect(
          getDevChangesImportance([
            '# Changelog',
            '',
            '## PATCH',
            '',
            '* changes',
          ]),
          equals(ChangesImportance.patch),
        );
      });
    });
    group('getPackageVersion returns', () {
      test('0.0.0 for empty pubspec', () {
        expect(getPackageVersion([]), equals('0.0.0'));
        expect(
          getPackageVersion([
            'name: code_checker',
            'description: Static source code analytics tool that helps analyse and improve quality.',
          ]),
          equals('0.0.0'),
        );
      });
      test('version from provided pubspec content', () {
        expect(
          getPackageVersion([
            'name: code_checker',
            'version: 0.10.0',
            'description: Static source code analytics tool that helps analyse and improve quality.',
          ]),
          equals('0.10.0'),
        );
      });
    });

    test('bumpPackageVersion returns increased dev version', () {
      expect(bumpPackageVersion('0.10.0'), equals('0.10.0-dev.1'));
      expect(bumpPackageVersion('1.0.0'), equals('1.0.0-dev.1'));
      expect(bumpPackageVersion('1.2.3-dev.45'), equals('1.2.3-dev.46'));
      expect(bumpPackageVersion('1.2.3-dev.45-beta'), equals('1.2.3-dev.46'));
    });

    test(
        'getDevChangesCount returns count of developer changes introduced in his branch',
        () {
      expect(getDevChangesCount([]), isZero);
      expect(
        getDevChangesCount([
          '# Changelog',
          '',
          '## MINOR',
          '',
          '## 0.10.0 - 2021-03-08',
          '',
          '* Add `Cyclomatic Complexity` metric',
          '* Add `Number of Parameters` metric',
        ]),
        isZero,
      );
      expect(
        getDevChangesCount([
          '# Changelog',
          '',
          '## MINOR',
          '',
          '* changes',
          '',
          '## 0.10.0 - 2021-03-08',
          '',
          '* Add `Cyclomatic Complexity` metric',
          '* Add `Number of Parameters` metric',
        ]),
        equals(1),
      );
    });

    test('getReleaseLineIndices returns lines indices with release paragraphs',
        () {
      expect(getReleaseLineIndices([]), isEmpty);
      expect(
        getReleaseLineIndices([
          '# Changelog',
          '',
          '## MINOR',
          '',
          '* changes',
          '',
          '## 0.10.0 - 2021-03-08',
          '',
          '* Add `Cyclomatic Complexity` metric',
          '* Add `Number of Parameters` metric',
        ]),
        equals([2, 6]),
      );
    });

    test('patchPubspec returns patched content', () {
      expect(patchPubspec([], 'newVersion'), equals(<String>[]));
      expect(
        patchPubspec(
          [
            'name: code_checker',
            'description: Static source code analytics tool that helps analyse and improve quality.',
          ],
          'newVersion',
        ),
        equals([
          'name: code_checker',
          'description: Static source code analytics tool that helps analyse and improve quality.',
        ]),
      );
      expect(
        patchPubspec(
          [
            'name: code_checker',
            'version: 0.10.0',
            'description: Static source code analytics tool that helps analyse and improve quality.',
          ],
          'newVersion',
        ),
        equals([
          'name: code_checker',
          'version: newVersion',
          'description: Static source code analytics tool that helps analyse and improve quality.',
        ]),
      );
    });
    test('patchChangelog returns patched content', () {
      expect(
        patchChangelog(
          [
            '# Changelog',
            '',
            '## MINOR',
            '',
            '* changes',
            '',
            '## 0.10.0 - 2021-03-08',
            '',
            '* Add `Cyclomatic Complexity` metric',
            '* Add `Number of Parameters` metric',
          ],
          'newVersion',
          ChangesImportance.major,
          DateTime(2021, 1, 2),
        ),
        equals([
          '# Changelog',
          '',
          '## newVersion - 2021-01-02',
          '',
          '* changes (MAJOR)',
          '',
          '## 0.10.0 - 2021-03-08',
          '',
          '* Add `Cyclomatic Complexity` metric',
          '* Add `Number of Parameters` metric',
        ]),
      );
    });
  });
}
