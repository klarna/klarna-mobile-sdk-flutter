package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.method.MethodParser
import io.flutter.plugin.common.MethodCall

internal sealed class PostPurchaseExperienceMethod {
    class Initialize(val locale: String?, val purchaseCountry: String?) : PostPurchaseExperienceMethod()
    class RenderOperation(val locale: String?, val operationToken: String?) : PostPurchaseExperienceMethod()
    class AuthorizationRequest(
            val locale: String?,
            val clientId: String?,
            val scope: String?,
            val redirectUri: String?,
            val state: String?,
            val loginHint: String?
    ) : PostPurchaseExperienceMethod()

    internal object Parser : MethodParser<PostPurchaseExperienceMethod> {
        override fun parse(call: MethodCall): PostPurchaseExperienceMethod? {
            return when (call.method) {
                "initialize" -> Initialize(call.argument("locale"), call.argument("purchaseCountry"))
                "renderOperation" -> RenderOperation(call.argument("locale"), call.argument("operationToken"))
                "authorizationRequest" -> AuthorizationRequest(
                        call.argument("locale"),
                        call.argument("clientId"),
                        call.argument("scope"),
                        call.argument("redirectUri"),
                        call.argument("state"),
                        call.argument("loginHint")
                )
                else -> null
            }
        }

    }
}