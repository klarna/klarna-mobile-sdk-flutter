package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.method.MethodParser
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.requireArgument
import io.flutter.plugin.common.MethodCall

internal sealed class PostPurchaseExperienceMethod(val id: Int) {
    class Initialize(
            id: Int,
            val returnUrl: String,
            val locale: String,
            val purchaseCountry: String,
            val design: String?,
            val sdkSource: String?
    ) : PostPurchaseExperienceMethod(id)

    class Destroy(id: Int) : PostPurchaseExperienceMethod(id)

    class RenderOperation(id: Int, val locale: String?, val operationToken: String) : PostPurchaseExperienceMethod(id)
    class AuthorizationRequest(
            id: Int,
            val locale: String?,
            val clientId: String,
            val scope: String,
            val redirectUri: String,
            val state: String?,
            val loginHint: String?,
            val responseType: String?
    ) : PostPurchaseExperienceMethod(id)

    internal object Parser : MethodParser<PostPurchaseExperienceMethod> {
        override fun parse(call: MethodCall): PostPurchaseExperienceMethod? {
            return when (call.method) {
                "initialize" -> Initialize(
                        call.requireArgument("id"),
                        call.requireArgument("returnUrl"),
                        call.requireArgument("locale"),
                        call.requireArgument("purchaseCountry"),
                        call.argument("design"),
                        call.argument("sdkSource")
                )
                "destroy" -> Destroy(
                        call.requireArgument("id")
                )
                "renderOperation" -> RenderOperation(
                        call.requireArgument("id"),
                        call.argument("locale"),
                        call.requireArgument("operationToken")
                )
                "authorizationRequest" -> AuthorizationRequest(
                        call.requireArgument("id"),
                        call.argument("locale"),
                        call.requireArgument("clientId"),
                        call.requireArgument("scope"),
                        call.requireArgument("redirectUri"),
                        call.argument("state"),
                        call.argument("loginHint"),
                        call.argument("responseType")
                )
                else -> null
            }
        }

    }
}