
import '../base.dart';

extension ExtensionInt on int? {
  SizedBox width() {
    return SizedBox(width: toInt().toDouble());
  }

  int toInt() {
    return this ?? 0;
  }

  String toYMD() {
    return DateUtil.formatDateMs(toInt(), format: DateFormats.y_mo_d);
  }

  String toYMDHM() {
    //如果是今天，就只展示时分，如果是昨天就展示昨天，如果是今年，就只展示 月/日 ,否则展示年/月/日
    var now = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(toInt());
    if (now.year == date.year) {
      if (now.month == date.month && now.day == date.day) {
        return DateUtil.formatDateMs(toInt(), format: DateFormats.h_m);
      } else if (now.month == date.month &&
          now.day - date.day == 1 &&
          now.year == date.year) {
        return "${S.current.yesterday} ${DateUtil.formatDateMs(toInt(), format: DateFormats.h_m)}";
      } else {
        return DateUtil.formatDateMs(toInt(), format: DateFormats.mo_d_h_m);
      }
    } else {
      return DateUtil.formatDateMs(toInt(), format: DateFormats.y_mo_d_h_m);
    }
  }

  SizedBox height() {
    return SizedBox(height: toInt().toDouble());
  }

  EdgeInsets paddingAll() {
    return EdgeInsets.all(toInt().toDouble());
  }

  EdgeInsets paddingHorizontal({int vertical = 0}) {
    return EdgeInsets.symmetric(
        horizontal: toInt().toDouble(), vertical: vertical.toDouble());
  }

  EdgeInsets paddingVertical({int horizontal = 0}) {
    return EdgeInsets.symmetric(
        vertical: toInt().toDouble(), horizontal: horizontal.toDouble());
  }

  TextStyle textStyle({Color? color}) {
    return TextStyle(fontSize: toInt().toDouble(), color: color);
  }
}

extension ExtensionColor on Color {
  TextStyle textStyle({double? size}) {
    return TextStyle(fontSize: size, color: this);
  }
}
