package com.klarna.mobile.sdk.flutter.postpurchase.method

import com.klarna.mobile.sdk.flutter.core.method.MethodParser
import com.klarna.mobile.sdk.flutter.core.util.requireArgument
import io.flutter.plugin.common.MethodCall

internal sealed class KlarnaPostPurchaseSDKMethod(val id: Int) {
    class Create(
        id: Int,
        val environment: String?,
        val region: String?,
        val resourceEndpoint: String?
    ) : KlarnaPostPurchaseSDKMethod(id)

    class Initialize(
        id: Int,
        val locale: String,
        val purchaseCountry: String,
        val design: String?
    ) : KlarnaPostPurchaseSDKMethod(id)

    class AuthorizationRequest(
        id: Int,
        val clientId: String,
        val scope: String,
        val redirectUri: String,
        val locale: String?,
        val state: String?,
        val loginHint: String?,
        val responseType: String?
    ) : KlarnaPostPurchaseSDKMethod(id)

    class RenderOperation(
        id: Int,
        val operationToken: String,
        val locale: String?,
        val redirectUri: String?
    ) :
        KlarnaPostPurchaseSDKMethod(id)

    class Destroy(id: Int) : KlarnaPostPurchaseSDKMethod(id)

    internal object Parser : MethodParser<KlarnaPostPurchaseSDKMethod> {
        override fun parse(call: MethodCall): KlarnaPostPurchaseSDKMethod? {
            return when (call.method) {
                "create" -> Create(
                    call.requireArgument("id"),
                    call.argument("environment"),
                    call.argument("region"),
                    call.argument("resourceEndpoint")
                )
                "initialize" -> Initialize(
                    call.requireArgument("id"),
                    call.requireArgument("locale"),
                    call.requireArgument("purchaseCountry"),
                    call.argument("design")
                )
                "authorizationRequest" -> AuthorizationRequest(
                    call.requireArgument("id"),
                    call.requireArgument("clientId"),
                    call.requireArgument("scope"),
                    call.requireArgument("redirectUri"),
                    call.argument("locale"),
                    call.argument("state"),
                    call.argument("loginHint"),
                    call.argument("responseType")
                )
                "renderOperation" -> RenderOperation(
                    call.requireArgument("id"),
                    call.requireArgument("operationToken"),
                    call.argument("locale"),
                    call.argument("redirectUri")
                )
                "destroy" -> Destroy(
                    call.requireArgument("id")
                )
                else -> null
            }
        }

    }
}
