package com.klarna.mobile.sdk.flutter.core.handler

import com.klarna.mobile.sdk.flutter.ResultError
import com.klarna.mobile.sdk.flutter.core.method.MethodParser
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal abstract class BaseMethodHandler<T>(val parser: MethodParser<T>) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            val method = parser.parse(call)
            if (method != null) {
                onMethod(method, result)
            } else {
                result.notImplemented()
            }
        } catch (e: Throwable) {
            result.error(ResultError.PLUGIN_METHOD_ERROR.errorCode, call.method, e.message)
        }
    }

    abstract fun onMethod(method: T, result: MethodChannel.Result)
}