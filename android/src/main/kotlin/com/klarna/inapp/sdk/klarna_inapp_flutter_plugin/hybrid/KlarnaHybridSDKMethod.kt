package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.hybrid

import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.core.method.MethodParser
import io.flutter.plugin.common.MethodCall

internal sealed class KlarnaHybridSDKMethod {
    class Initialize(val returnUrl: String) : KlarnaHybridSDKMethod()
    object SetupWebView : KlarnaHybridSDKMethod()

    internal object Parser : MethodParser<KlarnaHybridSDKMethod> {
        override fun parse(call: MethodCall): KlarnaHybridSDKMethod? {
            return when (call.method) {
                "initialize" -> Initialize(call.argument("returnUrl") ?: "")
                "setupWebView" -> SetupWebView
                else -> null
            }
        }
    }
}