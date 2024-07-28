import 'package:ecostep/presentation/widgets/error_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    this.loading,
    this.nullException,
    this.topMargin = 0,
    super.key,
  });

  final AsyncValue<T?> value;
  final Widget Function(T) data;
  final Widget Function()? loading;
  final String? nullException;
  final double topMargin;

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
      error: (e, st) => Padding(
        padding: EdgeInsets.only(top: topMargin),
        child: Center(child: ErrorMessageWidget(e.toString())),
      ),
      loading: loading ?? () {
        return Padding(
          padding: EdgeInsets.only(top: topMargin),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
