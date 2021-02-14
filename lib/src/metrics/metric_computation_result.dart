// @dart=2.8

import 'package:meta/meta.dart';

import '../models/context_message.dart';

@immutable
class MetricComputationResult<T> {
  final T value;

  final Iterable<ContextMessage> context;

  const MetricComputationResult({
    @required this.value,
    this.context = const [],
  });
}
