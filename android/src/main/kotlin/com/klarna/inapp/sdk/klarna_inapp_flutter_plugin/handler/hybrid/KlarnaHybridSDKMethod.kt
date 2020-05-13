package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.handler.hybrid

import io.flutter.plugin.common.MethodCall

internal sealed class KlarnaHybridSDKMethod {
    class Initialize(val returnUrl: String) : KlarnaHybridSDKMethod()
    object SetupWebView : KlarnaHybridSDKMethod()

    companion object {
        fun findMethod(call: MethodCall): KlarnaHybridSDKMethod? {
            return when (call.method) {
                "initialize" -> Initialize(call.argument("returnUrl") ?: "")
                "setupWebView" -> SetupWebView
                else -> null
            }
        }
    }
}