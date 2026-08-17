package com.klarna.mobile.sdk.flutter.core.method

import io.flutter.plugin.common.MethodCall

internal interface MethodParser<T> {
    fun parse(call: MethodCall): T?
}