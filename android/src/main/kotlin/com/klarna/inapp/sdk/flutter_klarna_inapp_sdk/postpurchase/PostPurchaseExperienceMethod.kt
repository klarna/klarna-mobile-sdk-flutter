package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.method.MethodParser
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.requireArgument
import io.flutter.plugin.common.MethodCall

internal sealed class PostPurchaseExperienceMethod {
    class Initialize(
            val locale: String,
            val purchaseCountry: String
    ) : PostPurchaseExperienceMethod()

    class RenderOperation(val locale: String, val operationToken: String) : PostPurchaseExperienceMethod()
    class AuthorizationRequest(
            val locale: String,
            val clientId: String,
            val scope: String,
            val redirectUri: String,
            val state: String,
            val loginHint: String
    ) : PostPurchaseExperienceMethod()

    internal object Parser : MethodParser<PostPurchaseExperienceMethod> {
        override fun parse(call: MethodCall): PostPurchaseExperienceMethod? {
            return when (call.method) {
                "initialize" -> Initialize(
                        call.requireArgument("locale"),
                        call.requireArgument("purchaseCountry")
                )
                "renderOperation" -> RenderOperation(
                        call.requireArgument("locale"),
                        call.requireArgument("operationToken")
                )
                "authorizationRequest" -> AuthorizationRequest(
                        call.requireArgument("locale"),
                        call.requireArgument("clientId"),
                        call.requireArgument("scope"),
                        call.requireArgument("redirectUri"),
                        call.requireArgument("state"),
                        call.requireArgument("loginHint")
                )
                else -> null
            }
        }

    }
}