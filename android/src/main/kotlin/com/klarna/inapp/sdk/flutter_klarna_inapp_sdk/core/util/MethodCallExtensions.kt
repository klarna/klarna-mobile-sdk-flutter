package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util

import io.flutter.plugin.common.MethodCall

internal fun <T> MethodCall.requireArgument(key: String): T {
    return argument<T>(key) ?: throw IllegalArgumentException("Argument $key can not be null.")
}