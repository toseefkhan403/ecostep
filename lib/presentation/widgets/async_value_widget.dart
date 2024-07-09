import 'package:ecostep/presentation/widgets/error_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.data,
    required this.value,
    this.nullException,
    super.key,
  });
  final AsyncValue<T?> value;
  final Widget Function(T) data;
  final String? nullException;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (resolved) {
        if (resolved == null) {
          if (nullException != null) {
            throw Exception(nullException);
          }
          return const SizedBox.shrink();
        }
        return data(resolved);
      },
      error: (e, st) => Center(child: ErrorMessageWidget(e.toString())),
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
