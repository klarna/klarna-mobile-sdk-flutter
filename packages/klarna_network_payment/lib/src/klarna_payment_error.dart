import 'package:flutter/services.dart';
import 'package:klarna_network_core/klarna_network_core.dart';

/// Converts a platform [error] into a [KlarnaSDKError].
KlarnaSDKError klarnaSDKErrorFromPlatformException(PlatformException error) =>
    KlarnaSDKError(
      name: error.code,
      message: error.message ?? error.code,
      cause: error.details,
    );
