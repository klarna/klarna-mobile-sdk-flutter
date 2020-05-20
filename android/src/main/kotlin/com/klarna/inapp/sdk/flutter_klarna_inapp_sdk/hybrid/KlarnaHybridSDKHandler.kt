package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ResultError
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.flutter.plugin.common.MethodChannel

internal object KlarnaHybridSDKHandler : BaseMethodHandler<KlarnaHybridSDKMethod>(KlarnaHybridSDKMethod.Parser) {

    internal var hybridSDK: KlarnaHybridSDK? = null
    internal val hybridSDKCallback = KlarnaHybridSDKCallback()

    const val NOT_INITIALIZED = "KlarnaHybridSDK is not initialized"

    internal fun notInitialized(result: MethodChannel.Result?) {
        result?.error(
                ResultError.HYBRID_SDK_ERROR.errorCode,
                NOT_INITIALIZED,
                "Call 'KlarnaHybridSDK.initialize' before this."
        )
    }

    override fun onMethod(method: KlarnaHybridSDKMethod, result: MethodChannel.Result) {
        when (method) {
            is KlarnaHybridSDKMethod.Initialize -> initialize(method, result)
        }
    }

    private fun initialize(method: KlarnaHybridSDKMethod.Initialize, result: MethodChannel.Result) {
        if (hybridSDK == null) {
            hybridSDKCallback.result = result
            hybridSDK = KlarnaHybridSDK(method.returnUrl, hybridSDKCallback)
            result.success(null)
            return
        }
        result.error(ResultError.HYBRID_SDK_ERROR.errorCode, "Already initialized.", null)
        return
    }
}