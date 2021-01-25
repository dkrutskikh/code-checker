/// Enum class for type of a function
///
/// Used when reporting
class FunctionType {
  static const FunctionType constructor = FunctionType._('constructor');
  static const FunctionType method = FunctionType._('method');
  static const FunctionType function = FunctionType._('function');
  static const FunctionType getter = FunctionType._('getter');
  static const FunctionType setter = FunctionType._('setter');

  final String _value;

  const FunctionType._(this._value);

  @override
  String toString() => _value;
}
