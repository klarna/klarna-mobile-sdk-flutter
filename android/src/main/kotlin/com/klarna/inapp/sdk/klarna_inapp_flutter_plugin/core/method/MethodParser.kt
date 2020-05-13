package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.core.method

import io.flutter.plugin.common.MethodCall

interface MethodParser<T> {
    fun parse(call: MethodCall): T?
}