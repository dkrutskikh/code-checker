# Code checker

[![Build Status](https://github.com/dart-code-checker/code-checker/workflows/build/badge.svg)](https://github.com/dart-code-checker/code-checker)
[![codecov.io](https://codecov.io/gh/dart-code-checker/code-checker/branch/main/graphs/badge.svg?branch=main)](https://codecov.io/github/dart-code-checker/code-checker?branch=main)
[![License](https://badgen.net/pub/license/code_checker)](https://github.com/dart-code-checker/code-checker/blob/master/LICENSE)
[![Pub Version](https://badgen.net/pub/v/code_checker)](https://pub.dev/packages/code_checker)
![Dart SDK Version](https://badgen.net/pub/sdk-version/code_checker)
![Dart Platform](https://badgen.net/pub/dart-platform/code_checker)

Static source code analytics tool that helps analyse and improve quality, inspired by Wrike [Dart code metrics](https://github.com/wrike/dart-code-metrics). It provides [additional rules](https://dart-code-checker.github.io/code-checker/docs/rules/) for dart analyzer and collects [code metrics](https://dart-code-checker.github.io/code-checker/docs/metrics/).

## Usage

### Analyzer plugin

The plugin for the Dart `analyzer` provide information collected by metrics.

1. Add dependency to `pubspec.yaml`

    ```yaml
    dev_dependencies:
      code_checker: ^0.9.0
    ```

2. Add configuration to `analysis_options.yaml`

    ```yaml
    analyzer:
      plugins:
        - code_checker
   
    code_checker:
      metrics:
        lines-of-code: 100
        maximum-nesting-level: 5
        number-of-methods: 10
        weight-of-class: 0.33
      metrics-exclude:
        - test/**
      rules:
        - double_literal_format
        - prefer_newline_before_return
        - prefer_trailing_comma
    ```

### Command line tool

#### Full usage

```text
Usage: checker [arguments] <directories>

-h, --help                                        Print this usage information.


-r, --reporter=<console>                          The format of the output of the analysis
                                                  [console (default), json]


    --maximum-nesting-level=<5>                   Maximum Nesting Level threshold
    --number-of-methods=<10>                      Number of Methods threshold
    --weight-of-class=<0.33>                      Weight Of a Class threshold


    --root-folder=<./>                            Root folder
                                                  (defaults to current directory)
    --exclude=<{/**.g.dart,/**.template.dart}>    File paths in Glob syntax to be exclude
                                                  (defaults to "{/**.g.dart,/**.template.dart}")
```
