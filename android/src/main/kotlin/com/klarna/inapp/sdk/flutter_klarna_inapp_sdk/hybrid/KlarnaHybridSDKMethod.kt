package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.method.MethodParser
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.requireArgument
import io.flutter.plugin.common.MethodCall

internal sealed class KlarnaHybridSDKMethod {
    class Initialize(val returnUrl: String) : KlarnaHybridSDKMethod()
    class RegisterEventListener : KlarnaHybridSDKMethod()

    internal object Parser : MethodParser<KlarnaHybridSDKMethod> {
        override fun parse(call: MethodCall): KlarnaHybridSDKMethod? {
            return when (call.method) {
                "initialize" -> Initialize(call.requireArgument("returnUrl"))
                "registerEventListener" -> RegisterEventListener()
                else -> null
            }
        }
    }
}