package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.stream.BaseStreamHandler
import io.flutter.plugin.common.MethodChannel

internal class PostPurchaseExperienceHandler : BaseMethodHandler<PostPurchaseExperienceMethod>(PostPurchaseExperienceMethod.Parser) {

    companion object {
        var errorStreamHandler = BaseStreamHandler()
        var eventStreamHandler = BaseStreamHandler()
    }

    override fun onMethod(method: PostPurchaseExperienceMethod, result: MethodChannel.Result) {
        when (method) {
            is PostPurchaseExperienceMethod.Initialize -> initialize(method, result)
            is PostPurchaseExperienceMethod.RenderOperation -> renderOperation(method, result)
            is PostPurchaseExperienceMethod.AuthorizationRequest -> authorizationRequest(method, result)
        }
    }

    private fun initialize(method: PostPurchaseExperienceMethod.Initialize, result: MethodChannel.Result) {

        // Event callback trigger example
        //eventStreamHandler.sink?.success("PP INITIALIZE EVENT")

        // Error callback trigger example
        //errorStreamHandler.sink?.success("PP INITIALIZE ERROR")

        TODO()
    }

    private fun renderOperation(method: PostPurchaseExperienceMethod.RenderOperation, result: MethodChannel.Result) {
        TODO()
    }

    private fun authorizationRequest(method: PostPurchaseExperienceMethod.AuthorizationRequest, result: MethodChannel.Result) {
        TODO()
    }
}
