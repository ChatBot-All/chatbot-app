import 'package:flutter/cupertino.dart';

import '../../base.dart';

class SendButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const SendButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, ref) {
    return CupertinoButton(
      minSize: 10,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(5),
      child: Text(
        S.current.send,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        onPressed();
      },
    );
  }
}

class WaitingSendButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const WaitingSendButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoButton(
      minSize: 10,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 10,
        height: 10,
        color: Colors.white,
      ),
      onPressed: () {
        onPressed();
      },
    );
  }
}
