# Code checker

[![Build Status](https://github.com/dart-code-checker-project/code-checker/workflows/build/badge.svg)](https://github.com/dart-code-checker-project/code-checker)
[![codecov.io](https://codecov.io/gh/dart-code-checker-project/code-checker/branch/main/graphs/badge.svg?branch=main)](https://codecov.io/github/dart-code-checker-project/code-checker?branch=main)
[![License](https://badgen.net/pub/license/code_checker)](https://github.com/dart-code-checker-project/code-checker/blob/master/LICENSE)
[![Pub Version](https://badgen.net/pub/v/code_checker)](https://pub.dev/packages/code_checker/)
![Dart SDK Version](https://badgen.net/pub/sdk-version/code_checker)
![Dart Platform](https://badgen.net/pub/dart-platform/code_checker)

Static source code analytics tool that helps analyse and improve quality, inspired by Wrike [Dart code metrics](https://github.com/wrike/dart-code-metrics).

## Usage

### Analyzer plugin

The plugin for the Dart `analyzer` provide information collected by metrics.

1. Add dependency to `pubspec.yaml`

    ```yaml
    dev_dependencies:
      code_checker: ^0.3.2
    ```

2. Add configuration to `analysis_options.yaml`

    ```yaml
    analyzer:
      plugins:
        - code_checker
    ```

### Command line tool

#### Full usage

```text
Usage: checker [arguments] <directories>

-h, --help                      Print this usage information.


    --number-of-methods=<10>    Number of Methods threshold
    --weight-of-class=<0.33>    Weight Of Class threshold
```
