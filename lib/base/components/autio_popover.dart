import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../../base.dart';

class AudioPopOver extends StatefulWidget {
  const AudioPopOver({super.key});

  @override
  State<AudioPopOver> createState() => _AudioPopOverState();
}

class _AudioPopOverState extends State<AudioPopOver> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));

    _animation = Tween<double>(begin: 50, end: 200).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Consumer(builder: (context, ref, _) {
        var state = ref.watch(audioRecordingStateProvider);
        return Container(
          height: F.height,
          width: F.width,
          color: Colors.black.withOpacity(0.8),
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                painter: AudioAnimationBgPainter(
                  color:
                      state == AudioRecordingState.canceling ? const Color(0xffFB5151) : Theme.of(context).primaryColor,
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  reverseDuration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Lottie.asset(
                      "assets/lottie/recording.json",
                      width: state == AudioRecordingState.canceling ? 150 : F.width / 2.1,
                      height: 80,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                state == AudioRecordingState.canceling ? S.current.leave_cancel : "",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 80,
                height: 80,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: state == AudioRecordingState.recording ? 50 : 80,
                        height: state == AudioRecordingState.recording ? 50 : 80,
                        decoration: BoxDecoration(
                          color: state == AudioRecordingState.recording ? const Color(0xff3D3A3D) : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          CupertinoIcons.clear,
                          color: state == AudioRecordingState.recording
                              ? Colors.grey
                              : Theme.of(context).textTheme.titleMedium?.color,
                          size: state == AudioRecordingState.recording ? 25 : 25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Transform.translate(
                offset: const Offset(0, 30),
                child: Text(
                  state == AudioRecordingState.recording ? S.current.leave_send : "",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, value) {
                      return SizedBox(
                        width: F.width,
                        height: _animation.value,
                        child: CustomPaint(
                          painter: AudioLayoutPainter(),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).bottom),
                              child: Icon(
                                CupertinoIcons.dot_radiowaves_right,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class AudioLayoutPainter extends CustomPainter {
  final painter = Paint()
    ..style = PaintingStyle.fill
    ..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xffA3A0A2),
        Color(0xffA5A2A5),
        Color(0xffA6A4A7),
        Color(0xffBEBBBD),
        Color(0xffCECCCF),
      ],
    ).createShader(Rect.fromLTWH(0, 0, F.width, 300));

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path()..moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, painter);

    var path2 = Path()..moveTo(0, size.height * 0.4);
    path2.quadraticBezierTo(size.width / 2, 0, size.width, size.height * 0.4);
    var painter2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xffACAAAC);
    canvas.drawPath(path, painter2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AudioAnimationBgPainter extends CustomPainter {
  final Color color;
  final painter = Paint()
    ..style = PaintingStyle.fill
    ..strokeJoin = StrokeJoin.round;

  AudioAnimationBgPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    painter.color = color;
    canvas.drawRRect(RRect.fromLTRBR(0, 0, size.width, size.height - 10, const Radius.circular(15)), painter);

    //在底部，中间绘制一个倒三角,三角形要有圆角
    var path = Path()
      ..moveTo(size.width / 2 - 10, size.height - 10)
      ..lineTo(size.width / 2 + 10, size.height - 10)
      ..lineTo(size.width / 2, size.height)
      ..close();
    painter.color = color;
    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

final chatAudioMessageProvider = StateProvider.autoDispose<String>((ref) {
  return "";
});

final audioRecordingStateProvider = StateProvider.autoDispose<AudioRecordingState>((ref) {
  return AudioRecordingState.normal;
});

enum AudioRecordingState {
  normal,
  recording,
  canceling,
  sending,
  speaking,
}

class AudioOverlay {
  OverlayEntry? overlayEntry;

  void update() {
    overlayEntry?.markNeedsBuild();
  }

  void showAudio(BuildContext context) {
    overlayEntry = OverlayEntry(
        builder: (context) {
          return const AudioPopOver();
        },
        opaque: true);
    Overlay.of(context).insert(overlayEntry!);
  }

  void removeAudio() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}

void showAudio(BuildContext context) {
  final overlayEntry = OverlayEntry(builder: (context) {
    return const AudioPopOver();
  });
  Overlay.of(context).insert(overlayEntry);
}
