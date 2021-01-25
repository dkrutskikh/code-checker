final _camelRegExp = RegExp('(?=[A-Z])');

extension StringExtensions on String {
  String camelCaseToText() => split(_camelRegExp).join(' ').toLowerCase();

  String capitalize() => this[0].toUpperCase() + substring(1);
}
