/// Enum class for type of a class. Used when reporting
class ClassType {
  static const ClassType generic = ClassType._('class');
  static const ClassType mixin = ClassType._('mixin');
  static const ClassType extension = ClassType._('extension');

  final String _value;

  const ClassType._(this._value);

  @override
  String toString() => _value;
}
