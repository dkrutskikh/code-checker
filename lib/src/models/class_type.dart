/// Enum class for type of a class. Used when reporting.
class ClassType {
  static const ClassType generic = ClassType._('Class');
  static const ClassType mixin = ClassType._('Mixin');
  static const ClassType extension = ClassType._('Extension');

  final String _value;

  const ClassType._(this._value);

  @override
  String toString() => _value;
}
