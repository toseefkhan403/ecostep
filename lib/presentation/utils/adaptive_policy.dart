import 'dart:io' as io;

import 'package:flutter/foundation.dart' as foundation;

enum Platform { web, android, ios, windows, macos, linux, unknown }

class AdaptivePolicy {
  static Platform currentPlatform = Platform.unknown;

  static void init() {
    currentPlatform = getPlatform();
  }

  static Platform getPlatform() {
    if (foundation.kIsWeb) {
      return Platform.web;
    }

    switch (io.Platform.operatingSystem) {
      case 'android':
        return Platform.android;
      case 'ios':
        return Platform.ios;
      case 'macos':
        return Platform.macos;
      case 'windows':
        return Platform.windows;
      case 'linux':
        return Platform.linux;
      default:
        return Platform.unknown;
    }
  }

  static bool isMobile() {
    if (currentPlatform == Platform.android ||
        currentPlatform == Platform.ios) {
      return true;
    }
    return false;
  }
}
