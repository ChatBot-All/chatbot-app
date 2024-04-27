import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

extension ExtensionLog on Object? {
  void e() {
    if (this == null) return;
    _logger.log(Level.error, this);
  }

  void w() {
    if (this == null) return;
    _logger.log(Level.warning, this);
  }

  void i() {
    if (this == null) return;
    _logger.log(Level.info, this);
  }

  void d() {
    if (this == null) return;
    _logger.log(Level.debug, this);
  }

  void v() {
    if (this == null) return;
    _logger.log(Level.trace, this);
  }

  void fatal() {
    if (this == null) return;
    _logger.log(Level.fatal, this);
  }
}

extension ExtensionList on List? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  Widget toList({required NullableIndexedWidgetBuilder itemBuilder, IndexedWidgetBuilder? separatorBuilder}) {
    if (separatorBuilder != null) {
      return ListView.separated(
        itemBuilder: itemBuilder,
        itemCount: this?.length ?? 0,
        separatorBuilder: separatorBuilder,
      );
    }

    return ListView.builder(
      itemBuilder: itemBuilder,
      itemCount: this?.length ?? 0,
    );
  }
}
