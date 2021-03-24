import 'dart:io';

import 'package:args/command_runner.dart';

import 'ci/dev.dart';
import 'ci/git.dart';
import 'ci/pub.dart';

void main(List<String> args) {
  CommandRunner<void>('tools/ci', 'tools for automate some ci/cd cases')
    ..addCommand(CheckBranch())
    ..addCommand(BumpDevVersion())
    ..addCommand(PushNewVersion())
    ..addCommand(PublishToPub())
    ..run(args);
}

class CheckBranch extends Command<void> {
  @override
  String get name => 'check-branch';

  @override
  String get description =>
      'Validate developer branch for compliance with our conventions.';

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

class PushNewVersion extends Command<void> {
  @override
  String get name => 'push-new-version';

  @override
  String get description => 'Push new version.';

  @override
  void run() {
    final version = getPackageVersion(readPubspec());

    pushNewVersion(version);
  }
}

class PublishToPub extends Command<void> {
  @override
  String get name => 'publish';

  @override
  String get description => 'Publish to pub.dev.';

  @override
  void run() {
    final version = getPackageVersion(readPubspec());

    publishToPub(version);
  }
}
