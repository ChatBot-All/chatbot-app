import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MultiStateWidget<T> extends StatelessWidget {
  const MultiStateWidget({
    Key? key,
    required this.value,
    required this.data,
    this.sliver = false,
    this.onError,
    this.onLoading,
  }) : super(key: key);

  final AsyncValue<T> value;

  final bool sliver;

  final Widget? onLoading;
  final Widget Function(BuildContext context, String msg)? onError;
  final Widget Function(T) data;

  @override
  Widget build(BuildContext context) {
    if (sliver) {
      return value.when(
        data: data,
        loading: () => SliverToBoxAdapter(
          child: onLoading ?? const SizedBox(),
        ),
        error: (e, _) => SliverToBoxAdapter(
          child: onError != null
              ? onError!(context, e.toString())
              : Center(
                  child: Text(e.toString()),
                ),
        ),
      );
    } else {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 40,
        ),
        child: value.when(
          data: data,
          loading: () => onLoading ?? const SizedBox(),
          error: (e, _) => onError != null
              ? onError!(context, e.toString())
              : Center(
                  child: Text(e.toString()),
                ),
        ),
      );
    }
  }
}
