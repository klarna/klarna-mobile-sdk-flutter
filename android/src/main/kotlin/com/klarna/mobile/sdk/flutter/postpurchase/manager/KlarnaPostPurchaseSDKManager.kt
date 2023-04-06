package com.klarna.mobile.sdk.flutter.postpurchase.manager

import com.klarna.mobile.sdk.flutter.PluginContext
import com.klarna.mobile.sdk.flutter.ResultError
import com.klarna.mobile.sdk.flutter.core.util.KlarnaParamMapper
import com.klarna.mobile.sdk.flutter.postpurchase.method.KlarnaPostPurchaseSDKMethod
import com.klarna.mobile.sdk.flutter.postpurchase.callback.KlarnaPostPurchaseSDKCallbackImpl
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseSDK
import io.flutter.plugin.common.MethodChannel

internal class KlarnaPostPurchaseSDKManager(private val id: Int) {

    companion object {
        private const val NOT_INITIALIZED = "KlarnaPostPurchaseSDK is not initialized"

        fun notInitialized(result: MethodChannel.Result?) {
            result?.error(
                ResultError.KLARNA_POST_PURCHASE_SDK_ERROR.errorCode,
                NOT_INITIALIZED,
                "Call 'KlarnaPostPurchaseSDK.createInstance' before this."
            )
        }
    }

    private var postPurchaseSDK: KlarnaPostPurchaseSDK? = null
    private val postPurchaseSDKCallback: KlarnaPostPurchaseSDKCallbackImpl =
        KlarnaPostPurchaseSDKCallbackImpl(id)

    fun create(method: KlarnaPostPurchaseSDKMethod.Create, result: MethodChannel.Result?) {
        PluginContext.activity?.let { activity ->
            val environment = KlarnaParamMapper.getEnvironment(method.environment)
            val region = KlarnaParamMapper.getRegion(method.region)
            val resourceEndpoint = KlarnaParamMapper.getResourceEndpoint(method.resourceEndpoint)
            postPurchaseSDK = KlarnaPostPurchaseSDK(
                activity,
                environment,
                region,
                postPurchaseSDKCallback,
                resourceEndpoint
            )
            postPurchaseSDK?.returnURL = method.returnURL
        } ?: run {
            result?.error(
                ResultError.KLARNA_POST_PURCHASE_SDK_ERROR.errorCode,
                "Failed to construct.",
                null
            )
            return
        }
        result?.success(null)
    }

    fun initialize(method: KlarnaPostPurchaseSDKMethod.Initialize, result: MethodChannel.Result?) {
        postPurchaseSDK?.let {
            it.initialize(method.locale, method.purchaseCountry, method.design)
        } ?: run {
            notInitialized(result)
            return
        }
        result?.success(null)
    }

    fun authorizationRequest(
        method: KlarnaPostPurchaseSDKMethod.AuthorizationRequest,
        result: MethodChannel.Result?
    ) {
        postPurchaseSDK?.let {
            it.authorizationRequest(
                method.clientId,
                method.scope,
                method.redirectUri,
                method.locale,
                method.state,
                method.loginHint,
                method.responseType
            )
        } ?: run {
            notInitialized(result)
            return
        }
        result?.success(null)
    }

    fun renderOperation(
        method: KlarnaPostPurchaseSDKMethod.RenderOperation,
        result: MethodChannel.Result?
    ) {
        postPurchaseSDK?.let {
            it.renderOperation(method.operationToken, method.locale, method.redirectUri)
        } ?: run {
            notInitialized(result)
            return
        }
        result?.success(null)
    }

    fun destroy(method: KlarnaPostPurchaseSDKMethod.Destroy, result: MethodChannel.Result?) {
        postPurchaseSDK?.removeCallback(postPurchaseSDKCallback)
        postPurchaseSDK = null
        result?.success(null)
    }
}