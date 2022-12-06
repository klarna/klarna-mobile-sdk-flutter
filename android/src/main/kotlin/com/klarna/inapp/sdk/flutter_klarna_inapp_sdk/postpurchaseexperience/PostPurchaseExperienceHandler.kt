package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchaseexperience

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import io.flutter.plugin.common.MethodChannel

internal object PostPurchaseExperienceHandler : BaseMethodHandler<PostPurchaseExperienceMethod>(PostPurchaseExperienceMethod.Parser) {

    val ppeManagerMap = mutableMapOf<Int, PostPurchaseExperienceManager>()

    override fun onMethod(method: PostPurchaseExperienceMethod, result: MethodChannel.Result) {
        when (method) {
            is PostPurchaseExperienceMethod.Initialize -> initialize(method, result)
            is PostPurchaseExperienceMethod.Destroy -> destroy(method, result)
            is PostPurchaseExperienceMethod.RenderOperation -> renderOperation(method, result)
            is PostPurchaseExperienceMethod.AuthorizationRequest -> authorizationRequest(method, result)
        }
    }

    private fun initialize(method: PostPurchaseExperienceMethod.Initialize, result: MethodChannel.Result) {
        val manager = getManager(method)
        if (manager == null) {
            val newManager = PostPurchaseExperienceManager()
            newManager.initialize(method, result)
            ppeManagerMap[method.id] = newManager
        } else {
            getManager(method)?.initialize(method, result)
        }
    }

    private fun destroy(method: PostPurchaseExperienceMethod.Destroy, result: MethodChannel.Result) {
        getManager(method)?.destroy(method, result)
        ppeManagerMap.remove(method.id)
    }

    private fun renderOperation(method: PostPurchaseExperienceMethod.RenderOperation, result: MethodChannel.Result) {
        getManager(method)?.renderOperation(method, result)
    }

    private fun authorizationRequest(method: PostPurchaseExperienceMethod.AuthorizationRequest, result: MethodChannel.Result) {
        getManager(method)?.authorizationRequest(method, result)
    }

    private fun getManager(method: PostPurchaseExperienceMethod): PostPurchaseExperienceManager? {
        return ppeManagerMap[method.id]
    }
}