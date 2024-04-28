import 'package:extended_image/extended_image.dart';

import '../base.dart';

class SlidePage extends StatefulWidget {
  const SlidePage({super.key, this.url});

  final String? url;

  @override
  State createState() => _SlidePageState();
}

class _SlidePageState extends State<SlidePage> {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey = GlobalKey<ExtendedImageSlidePageState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ExtendedImageSlidePage(
        key: slidePagekey,
        slideAxis: SlideAxis.both,
        slideType: SlideType.onlyImage,
        slidePageBackgroundHandler: (Offset offset, Size pageSize) {
          double opacity = (1 - offset.distance / pageSize.shortestSide);
          if (opacity < 0) {
            opacity = 0;
          }
          if (opacity > 1) {
            opacity = 1;
          }
          return Colors.black.withOpacity(opacity);
        },
        child: GestureDetector(
          child: widget.url == 'This is an video'
              ? ExtendedImageSlidePageHandler(
                  child: Material(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.yellow,
                      child: const Text('This is an video'),
                    ),
                  ),
                  heroBuilderForSlidingPage: (Widget result) {
                    return Hero(
                      tag: widget.url!,
                      child: result,
                      flightShuttleBuilder: (BuildContext flightContext,
                          Animation<double> animation,
                          HeroFlightDirection flightDirection,
                          BuildContext fromHeroContext,
                          BuildContext toHeroContext) {
                        final Hero hero = (flightDirection == HeroFlightDirection.pop
                            ? fromHeroContext.widget
                            : toHeroContext.widget) as Hero;

                        return hero.child;
                      },
                    );
                  },
                )
              : HeroWidget(
                  tag: widget.url!,
                  slideType: SlideType.onlyImage,
                  slidePagekey: slidePagekey,
                  child: ExtendedImage.network(
                    widget.url!,
                    enableSlideOutPage: true,
                    mode: ExtendedImageMode.gesture,
                  ),
                ),
          onTap: () {
            slidePagekey.currentState!.popPage();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

/// make hero better when slide out
class HeroWidget extends StatefulWidget {
  const HeroWidget({
    super.key,
    required this.child,
    required this.tag,
    required this.slidePagekey,
    this.slideType = SlideType.onlyImage,
  });

  final Widget child;
  final SlideType slideType;
  final Object tag;
  final GlobalKey<ExtendedImageSlidePageState> slidePagekey;

  @override
  State createState() => _HeroWidgetState();
}

class _HeroWidgetState extends State<HeroWidget> {
  RectTween? _rectTween;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.tag,
      createRectTween: (Rect? begin, Rect? end) {
        _rectTween = RectTween(begin: begin, end: end);
        return _rectTween!;
      },
      // make hero better when slide out
      flightShuttleBuilder: (BuildContext flightContext, Animation<double> animation,
          HeroFlightDirection flightDirection, BuildContext fromHeroContext, BuildContext toHeroContext) {
        // make hero more smoothly
        final Hero hero =
            (flightDirection == HeroFlightDirection.pop ? fromHeroContext.widget : toHeroContext.widget) as Hero;
        if (_rectTween == null) {
          return hero;
        }

        if (flightDirection == HeroFlightDirection.pop) {
          final bool fixTransform = widget.slideType == SlideType.onlyImage &&
              (widget.slidePagekey.currentState!.offset != Offset.zero ||
                  widget.slidePagekey.currentState!.scale != 1.0);

          final Widget toHeroWidget = (toHeroContext.widget as Hero).child;
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext buildContext, Widget? child) {
              Widget animatedBuilderChild = hero.child;

              // make hero more smoothly
              animatedBuilderChild = Stack(
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: 1 - animation.value,
                    child: UnconstrainedBox(
                      child: SizedBox(
                        width: _rectTween!.begin!.width,
                        height: _rectTween!.begin!.height,
                        child: toHeroWidget,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: animation.value,
                    child: animatedBuilderChild,
                  )
                ],
              );

              // fix transform when slide out
              if (fixTransform) {
                final Tween<Offset> offsetTween =
                    Tween<Offset>(begin: Offset.zero, end: widget.slidePagekey.currentState!.offset);

                final Tween<double> scaleTween =
                    Tween<double>(begin: 1.0, end: widget.slidePagekey.currentState!.scale);
                animatedBuilderChild = Transform.translate(
                  offset: offsetTween.evaluate(animation),
                  child: Transform.scale(
                    scale: scaleTween.evaluate(animation),
                    child: animatedBuilderChild,
                  ),
                );
              }

              return animatedBuilderChild;
            },
          );
        }
        return hero.child;
      },
      child: widget.child,
    );
  }
}
