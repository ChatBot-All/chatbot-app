import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../base.dart';

class CommonLoading extends StatelessWidget {
  const CommonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        alignment: Alignment.center,
        child: SizedBox(
          width: 40,
          child: LoadingAnimationWidget.prograssiveDots(
            color: Theme.of(context).primaryColor,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class EmptyData extends StatelessWidget {
  const EmptyData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/empty.png", width: 96, height: 130, fit: BoxFit.cover),
          Transform.translate(
              offset: const Offset(0, -10),
              child: Text(S.current.empty_content_need_add, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
