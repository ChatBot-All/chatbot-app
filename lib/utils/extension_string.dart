import '../base.dart';

///easyLoading 和 flutter_toast 扩展
extension ExtensionString on String? {
  bool isEmpty() {
    return this == null || this!.isEmpty;
  }

  String string({String defaultValue = ""}) {
    return this ?? defaultValue;
  }

  bool isNotEmpty() {
    return !isEmpty();
  }

  void loading() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (this != null) {
      EasyLoading.show(
        status: this!,
        maskType: EasyLoadingMaskType.clear,
      );
    }
  }

  Widget toText({TextStyle? style, double? size, Color? color}) {
    return Text(
      this ?? "",
      style: style ??
          TextStyle(
            color: color,
            fontSize: size,
          ),
    );
  }

  void fail() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (this != null) {
      EasyLoading.showError(this!);
    }
  }

  void success() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (this != null) {
      EasyLoading.showSuccess(this!);
    }
  }

  void toast() {
    if (this == null) return;
    Fluttertoast.showToast(msg: this!, gravity: ToastGravity.CENTER);
  }

  void save2SP(String key) {
    if (this == null) return;
    SpUtil.putString(key, this!);
  }

  void toClipboard() {
    if (this == null) return;
    Clipboard.setData(ClipboardData(text: this!));
    S.current.copy_success.success();
  }

  Widget action(VoidCallback onPressed, {TextStyle? style}) {
    return (this ?? "").toText(style: style).padding(15.paddingHorizontal()).click(onPressed);
  }
}

extension ExtensionIconData on IconData {
  Widget action(VoidCallback onPressed, {Color? color, double? size}) {
    return Icon(this, color: color, size: size).padding(15.paddingHorizontal()).click(onPressed);
  }
}

void eDismiss() {
  if (EasyLoading.isShow) {
    EasyLoading.dismiss();
  }
}
