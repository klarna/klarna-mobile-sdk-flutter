package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.manager.KlarnaPostPurchaseSDKManager
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.method.KlarnaPostPurchaseSDKMethod
import io.flutter.plugin.common.MethodChannel

internal object KlarnaPostPurchaseSDKHandler :
    BaseMethodHandler<KlarnaPostPurchaseSDKMethod>(KlarnaPostPurchaseSDKMethod.Parser) {

    val postPurchaseSDKManagerMap = mutableMapOf<Int, KlarnaPostPurchaseSDKManager>()

    override fun onMethod(method: KlarnaPostPurchaseSDKMethod, result: MethodChannel.Result) {
        when (method) {
            is KlarnaPostPurchaseSDKMethod.Create -> create(method, result)
            is KlarnaPostPurchaseSDKMethod.Initialize -> initialize(method, result)
            is KlarnaPostPurchaseSDKMethod.Destroy -> destroy(method, result)
            is KlarnaPostPurchaseSDKMethod.RenderOperation -> renderOperation(method, result)
            is KlarnaPostPurchaseSDKMethod.AuthorizationRequest -> authorizationRequest(
                method,
                result
            )
        }
    }

    private fun create(
        method: KlarnaPostPurchaseSDKMethod.Create,
        result: MethodChannel.Result
    ) {
        val manager = getManager(method)
        if (manager == null) {
            val newManager = KlarnaPostPurchaseSDKManager(method.id)
            newManager.create(method, result)
            postPurchaseSDKManagerMap[method.id] = newManager
        } else {
            getManager(method)?.create(method, result)
        }
    }

    private fun initialize(
        method: KlarnaPostPurchaseSDKMethod.Initialize,
        result: MethodChannel.Result
    ) {
        getManager(method)?.initialize(method, result)
            ?: KlarnaPostPurchaseSDKManager.notInitialized(result)
    }

    private fun authorizationRequest(
        method: KlarnaPostPurchaseSDKMethod.AuthorizationRequest,
        result: MethodChannel.Result
    ) {
        getManager(method)?.authorizationRequest(method, result)
            ?: KlarnaPostPurchaseSDKManager.notInitialized(result)
    }

    private fun renderOperation(
        method: KlarnaPostPurchaseSDKMethod.RenderOperation,
        result: MethodChannel.Result
    ) {
        getManager(method)?.renderOperation(method, result)
            ?: KlarnaPostPurchaseSDKManager.notInitialized(result)
    }

    private fun destroy(method: KlarnaPostPurchaseSDKMethod.Destroy, result: MethodChannel.Result) {
        getManager(method)?.destroy(method, result)
            ?: KlarnaPostPurchaseSDKManager.notInitialized(result)
        postPurchaseSDKManagerMap.remove(method.id)
    }

    private fun getManager(method: KlarnaPostPurchaseSDKMethod): KlarnaPostPurchaseSDKManager? {
        return postPurchaseSDKManagerMap[method.id]
    }
}