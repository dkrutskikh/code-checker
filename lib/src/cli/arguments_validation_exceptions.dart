// @dart=2.8

import 'package:meta/meta.dart';

@immutable
class InvalidArgumentException implements Exception {
  final String message;

  const InvalidArgumentException(this.message);
}
