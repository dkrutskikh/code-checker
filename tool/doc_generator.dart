import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:code_checker/metrics.dart' as checker;
import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';

final _parser = argumentsParser();

void main(List<String> args) {
  try {
    final arguments = _parser.parse(args);

    if (arguments[helpFlagName] as bool) {
      _showUsageAndExit(0);
    }

    validateArguments(arguments);

    _generate(arguments[outputDirectoryName] as String);
  } on FormatException catch (e) {
    print('${e.message}\n');
    _showUsageAndExit(1);
  } on InvalidArgumentException catch (e) {
    print('${e.message}\n');
    _showUsageAndExit(1);
  }
}

void _showUsageAndExit(int exitCode) {
  print(usageHeader);
  print(_parser.usage);
  exit(exitCode);
}

void _generate(String directory) {
  metricsDocumentation(directory);
}

// ----------------------------- Arguments  Parser -----------------------------

const usageHeader = 'Usage: generator [options...] <directories>';
const helpFlagName = 'help';
const outputDirectoryName = 'out';

ArgParser argumentsParser() {
  final parser = ArgParser();

  _appendHelpOption(parser);
  _appendOutputDirectoryOption(parser);

  return parser;
}

void _appendHelpOption(ArgParser parser) {
  parser.addFlag(
    helpFlagName,
    abbr: 'h',
    help: 'Print this usage information.',
    negatable: false,
  );
}

void _appendOutputDirectoryOption(ArgParser parser) {
  parser.addOption(
    outputDirectoryName,
    abbr: 'o',
    help: 'Specifies output directory (required)',
  );
}

// --------------------------- Arguments  Validation ---------------------------

void validateArguments(ArgResults arguments) {
  final directoryPath = arguments[outputDirectoryName] as String;

  if (directoryPath == null || !Directory(directoryPath).existsSync()) {
    throw InvalidArgumentException(
      'Output folder $directoryPath does not exist or not a directory',
    );
  }
}

// ---------------------- Arguments Validation Exceptions ----------------------

@immutable
class InvalidArgumentException implements Exception {
  final String message;

  const InvalidArgumentException(this.message);
}

// ----------------------------- Metrics Generator -----------------------------

void metricsDocumentation(String root) {
  final directory = '$root/metrics';

  Directory(directory).createSync(recursive: true);

  final metrics = checker.metrics(config: {});
  MetricHtmlIndexGenerator(metrics).generate(directory);

  for (final metric in metrics) {
    MetricHtmlGenerator(metric).generate(directory);
  }
}

class MetricHtmlIndexGenerator {
  final Iterable<checker.Metric> _metrics;

  MetricHtmlIndexGenerator(this._metrics);

  void generate(String filePath) {
    final outPath = '$filePath/index.html';
    print('Writing to $outPath');
    File(outPath).writeAsStringSync(_generate());
  }

  String _generate() {
    final section = Element.tag('section')
      ..append(Element.tag('h1')..text = 'Supported Metrics')
      ..append(Element.tag('p')
        ..text = 'This list is auto-generated from our sources.');

    for (final metric in _metrics) {
      section
        ..append(Element.tag('strong')
          ..append(Element.tag('a')
            ..attributes['href'] = '${metric.id}.html'
            ..text = metric.documentation.name))
        ..append(Element.tag('br'))
        ..append(Element.tag('p')..text = metric.documentation.brief);
    }

    final body = Element.tag('body')
      ..append(Element.tag('div')
        ..classes.add('wrapper')
        ..append(headerElement(
          header: 'Code Checker',
          paragraphs: ['Metrics'],
          buttons: const [
            HeaderButton(
              titleStart: 'Using the',
              titleEnd: 'Checker',
              href: '../index.html',
            ),
          ],
        ))
        ..append(section))
      ..append(footer());

    final html = Element.tag('html')
      ..attributes['lang'] = 'en'
      ..append(headElement(
        title: 'Code Checker Metrics',
        description: 'The list of supported metrics',
        pageUrl:
            'https://dart-code-checker-project.github.io/code-checker/metrics/index.html',
      ))
      ..append(body);

    return (Document()..append(DocumentType('html', null, null))..append(html))
        .outerHtml
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}

class MetricHtmlGenerator {
  final checker.Metric _metric;

  MetricHtmlGenerator(this._metric);

  void generate(String filePath) {
    final outPath = '$filePath/${_metric.id}.html';
    print('Writing to $outPath');
    File(outPath).writeAsStringSync(_generate());
  }

  String _generate() {
    final section = Element.tag('section');
    if (_metric.documentation.details.isNotEmpty) {
      section.append(markdownToHtml(_metric.documentation.details));
    } else {
      section.append(Element.tag('p')..text = _metric.documentation.brief);
    }

    final body = Element.tag('body')
      ..append(Element.tag('div')
        ..classes.add('wrapper')
        ..append(headerElement(
          header:
              '${_metric.documentation.name} (${_metric.documentation.shortName})',
          paragraphs: [
            'ID: ${_metric.id}',
            'Measured Entity: ${_measuredEntity(_metric.documentation.measuredType)}',
          ],
          buttons: const [
            HeaderButton(
              titleStart: 'View all',
              titleEnd: 'Metrics',
              href: 'index.html',
            ),
          ],
        ))
        ..append(section))
      ..append(footer());

    final html = Element.tag('html')
      ..attributes['lang'] = 'en'
      ..append(headElement(
        title: _metric.documentation.name,
        description: _metric.documentation.brief,
        pageUrl:
            'https://dart-code-checker-project.github.io/code-checker/metrics/${_metric.id}.html',
      ))
      ..append(body);

    embedDartCode(html);

    return (Document()..append(DocumentType('html', null, null))..append(html))
        .outerHtml
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}

const _entityTypeMapping = {
  checker.EntityType.classEntity: 'Class',
  checker.EntityType.methodEntity: 'Method',
};

String _measuredEntity(checker.EntityType type) =>
    _entityTypeMapping[type] ?? '';

// ------------------------------- Html Helpers --------------------------------

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

String getRandomString(int length) {
  final rnd = Random();

  return String.fromCharCodes(Iterable.generate(
    length,
    (_) => _chars.codeUnitAt(rnd.nextInt(_chars.length)),
  ));
}

Node headElement({
  @required String title,
  @required String description,
  @required String pageUrl,
}) =>
    Element.tag('head')
      ..append(Element.tag('meta')..attributes['charset'] = 'utf-8')
      ..append(Element.tag('meta')
        ..attributes['property'] = 'og:url'
        ..attributes['content'] = pageUrl)
      ..append(Element.tag('meta')
        ..attributes['property'] = 'og:title'
        ..attributes['content'] = title)
      ..append(Element.tag('meta')
        ..attributes['property'] = 'og:description'
        ..attributes['content'] = description)
      ..append(Element.tag('meta')
        ..attributes['property'] = 'og:locale'
        ..attributes['content'] = 'en_US')
      ..append(Element.tag('meta')
        ..attributes['property'] = 'og:site_name'
        ..attributes['content'] = 'Code Checker')
//    ..append(Element.tag('link')
//      ..attributes['rel'] = 'shortcut icon'
//      ..attributes['href'] = 'path-to-icon.png')
      ..append(Element.tag('meta')
        ..attributes['name'] = 'viewport'
        ..attributes['content'] =
            'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no')
      ..append(Element.tag('meta')
        ..attributes['name'] = 'mobile-web-app-capable'
        ..attributes['content'] = 'yes')
      ..append(Element.tag('meta')
        ..attributes['name'] = 'apple-mobile-web-app-capable'
        ..attributes['content'] = 'yes')
      ..append(Element.tag('title')..text = title)
      ..append(Element.tag('meta')
        ..attributes['name'] = 'description'
        ..attributes['content'] = description)
      ..append(Element.tag('link')
        ..attributes['rel'] = 'canonical'
        ..attributes['href'] = pageUrl)
      ..append(Element.tag('link')
        ..attributes['rel'] = 'stylesheet'
        ..attributes['href'] =
            '/code-checker/assets/css/style.css?v=${getRandomString(48)}');
//            'https://dart-code-checker-project.github.io/code-checker/assets/css/style.css?v=${getRandomString(48)}');

@immutable
class HeaderButton {
  final String titleStart;
  final String titleEnd;
  final String href;

  const HeaderButton({
    @required this.titleStart,
    @required this.titleEnd,
    @required this.href,
  });
}

Node headerElement({
  @required String header,
  @required Iterable<String> paragraphs,
  @required Iterable<HeaderButton> buttons,
}) {
  final node = Element.tag('header')..append(Element.tag('h1')..text = header);

  for (final paragraph in paragraphs) {
    node.append(Element.tag('p')..text = paragraph);
  }

  if (buttons.isNotEmpty) {
    for (final button in buttons) {
      node.append(Element.tag('p')
        ..classes.add('view')
        ..append(Element.tag('a')
          ..attributes['href'] = button.href.trim()
          ..text = '${button.titleStart.trim()} ${button.titleEnd.trim()}'));
    }

    final desktopButtons = Element.tag('ul');
    for (final button in buttons) {
      desktopButtons.append(Element.tag('li')
        ..append(Element.tag('a')
          ..attributes['href'] = button.href.trim()
          ..text =
              '${button.titleStart.trim()} <strong>${button.titleEnd.trim()}</strong>'));
    }

    node.append(desktopButtons);
  }

  return node;
}

Node footer() => Element.tag('footer')
  ..append(Element.tag('p')
    ..text =
        'Project maintained by <a href="https://github.com/dart-code-checker-project">Dart Code Checker Project</a>')
  ..append(Element.tag('p')
    ..text =
        'Hosted on GitHub Pages — Theme by <a href="https://github.com/orderedlist">orderedlist</a>');

Node markdownToHtml(String markdown) =>
    DocumentFragment.html(md.markdownToHtml(markdown));

void embedDartCode(Node node) {
  final visitor = CodeVisitor()..visit(node);

  for (final codeBlock in visitor.codeBlocks) {
    final codeContent = parseFragment(codeBlock.text).children.first;

    final path = codeContent.attributes['path'];
    if (path != null) {
      codeBlock.text = File(path).readAsStringSync();
    }
  }
}

const dartExtension = '.dart';

class CodeVisitor extends TreeVisitor {
  final _codeBlocks = <Text>[];

  Iterable<Text> get codeBlocks => _codeBlocks;

  @override
  void visitElement(Element node) {
    if (node.localName == 'code') {
      final textNode = node.nodes.single as Text;
      if (textNode.text.startsWith('<source')) {
        _codeBlocks.add(textNode);
      }
    }

    super.visitElement(node);
  }
}
