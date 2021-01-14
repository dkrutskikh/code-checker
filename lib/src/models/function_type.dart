/// Enum class for type of a function. Used when reporting.
class FunctionType {
  static const FunctionType constructor = FunctionType._('Constructor');
  static const FunctionType method = FunctionType._('Method');
  static const FunctionType function = FunctionType._('Function');
  static const FunctionType getter = FunctionType._('Getter');
  static const FunctionType setter = FunctionType._('Setter');

  final String _value;

  const FunctionType._(this._value);

  @override
  String toString() => _value;
}
