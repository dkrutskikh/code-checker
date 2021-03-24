import 'package:args/command_runner.dart';

import 'ci/dev.dart';

void main(List<String> args) {
  CommandRunner<void>('tools/ci', 'tools for automate some ci/cd cases')
    ..addCommand(CheckBranch())
    ..addCommand(BumpDevVersion())
    ..run(args);
}

class CheckBranch extends Command<void> {
  @override
  String get name => 'check-branch';

  @override
  String get description =>
      'Validate developer branch for compliance with our conventions.';

  CheckBranch() {
    argParser.addFlag('all', abbr: 'a');
  }

  @override
  void run() {
    final changelogContent = readChangelog();
    final importance = getDevChangesImportance(changelogContent);
    if (importance == ChangesImportance.unknown) {
      printErrorMessage("Can't get changes importance.");
    }

    if (getDevChangesCount(changelogContent) == 0) {
      printErrorMessage("Can't get introduces changes.");
    }
  }
}

class BumpDevVersion extends Command<void> {
  @override
  String get name => 'bump-dev-version';

  @override
  String get description => 'Bump package version.';

  BumpDevVersion() {
    argParser.addFlag('all', abbr: 'a');
  }

  @override
  void run() {
    final changelogContent = readChangelog();
    final pubspecContent = readPubspec();

    final importance = getDevChangesImportance(changelogContent);
    if (importance == ChangesImportance.unknown ||
        getDevChangesCount(changelogContent) == 0) {
      printErrorMessage("Please run 'check-branch' command before.");
    }

    final packageVersion = getPackageVersion(pubspecContent);
    final updatedPackageVersion = bumpPackageVersion(packageVersion);

    savePubspec(patchPubspec(pubspecContent, updatedPackageVersion));
    saveChangelog(
      patchChangelog(
        changelogContent,
        updatedPackageVersion,
        importance,
        DateTime.now(),
      ),
    );
  }
}
