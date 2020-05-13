package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.postpurchase

import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.core.handler.BaseMethodHandler
import io.flutter.plugin.common.MethodChannel

internal class PostPurchaseExperienceHandler : BaseMethodHandler<PostPurchaseExperienceMethod>(PostPurchaseExperienceMethod.Parser) {

    override fun onMethod(method: PostPurchaseExperienceMethod, result: MethodChannel.Result) {
        when (method) {
            is PostPurchaseExperienceMethod.Initialize -> initialize(method, result)
            is PostPurchaseExperienceMethod.RenderOperation -> renderOperation(method, result)
            is PostPurchaseExperienceMethod.AuthorizationRequest -> authorizationRequest(method, result)
        }
    }

    private fun initialize(method: PostPurchaseExperienceMethod.Initialize, result: MethodChannel.Result) {
        TODO()
    }

    private fun renderOperation(method: PostPurchaseExperienceMethod.RenderOperation, result: MethodChannel.Result) {
        TODO()
    }

    private fun authorizationRequest(method: PostPurchaseExperienceMethod.AuthorizationRequest, result: MethodChannel.Result) {
        TODO()
    }
}