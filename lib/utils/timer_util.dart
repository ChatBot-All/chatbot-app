import 'dart:async';

class TimerUtil {
  Timer? timer;

  int seconds = 60;

  TimerUtil(this.seconds);

  void stopCountDown() {
    timer?.cancel();
    timer = null;
  }

  void dispose() {
    stopCountDown();
  }

  bool isRunning() {
    return timer != null && timer!.isActive;
  }

  void startCountDown(Function(int) onTick, Function() onEnd) {
    stopCountDown();
    timer = Timer.periodic(Duration(seconds: seconds), (timer) {
      onTick(seconds - timer.tick);
      if (timer.tick >= seconds) {
        stopCountDown();
        onEnd();
      }
    });
  }
}
