/// Enum class for severity. Used when reporting issues.
class Severity {
  /// Programming error.
  ///
  /// This indicates severe issue like memory leak etc.
  /// The issue is certain.
  static const error = Severity('error');

  /// Warning.
  ///
  /// Used for dangerous coding style that can cause severe runtime errors.
  /// For example: accessing an out of range array element.
  static const warning = Severity('warning');

  /// Performance warning.
  ///
  /// Suboptimal code and fixing it probably leads to faster performance.
  static const performance = Severity('performance');

  /// Style warning.
  ///
  /// Used for general code cleanup recommendations. Fixing these will not fix
  /// any bugs but will make the code easier to maintain.
  /// For example: trailing comma, blank line before return, etc.
  static const style = Severity('style');

  /// No severity (default value).
  static const none = Severity('none');

  static const _all = [error, warning, performance, style, none];

  final String _value;

  const Severity(this._value);

  /// Converts the human readable [severity] string into a [Severity] value.
  static Severity fromString(String severity) => severity != null
      ? _all.firstWhere(
          (val) => val._value == severity.toLowerCase(),
          orElse: () => Severity.none,
        )
      : null;
}
