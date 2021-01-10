import 'package:args/args.dart';

import 'arguments_validation_exceptions.dart';

/// Umbrella method to run all checks throws [InvalidArgumentException]
void validateArguments(ArgResults arguments) {
  checkPathsToAnalyzeNotEmpty(arguments);
}

void checkPathsToAnalyzeNotEmpty(ArgResults arguments) {
  if (arguments.rest.isEmpty) {
    const _exceptionMessage =
        'Invalid number of directories. At least one must be specified';

    throw const InvalidArgumentException(_exceptionMessage);
  }
}
