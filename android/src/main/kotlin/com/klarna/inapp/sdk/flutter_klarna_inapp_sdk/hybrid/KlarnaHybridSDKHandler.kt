package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ResultError
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.mobile.sdk.api.KlarnaEventListener
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.flutter.plugin.common.MethodChannel

internal object KlarnaHybridSDKHandler : BaseMethodHandler<KlarnaHybridSDKMethod>(KlarnaHybridSDKMethod.Parser) {

    internal var hybridSDK: KlarnaHybridSDK? = null
    private val hybridSDKCallback = KlarnaHybridSDKCallback()
    private val hybridSDKEventListener: KlarnaEventListener = KlarnaHybridSDKEventListener()

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
            is KlarnaHybridSDKMethod.RegisterEventListener -> registerEventListener(method, result)
        }
    }

    private fun initialized() = hybridSDK != null

    private fun initialize(method: KlarnaHybridSDKMethod.Initialize, result: MethodChannel.Result) {
        if (hybridSDK == null) {
            hybridSDK = KlarnaHybridSDK(method.returnUrl, hybridSDKCallback)
            result.success(null)
            return
        }
        result.error(ResultError.HYBRID_SDK_ERROR.errorCode, "Already initialized.", null)
    }

    private fun registerEventListener(method: KlarnaHybridSDKMethod.RegisterEventListener, result: MethodChannel.Result) {
        if (!initialized()) {
            notInitialized(result)
            return
        }
        hybridSDK?.registerEventListener(hybridSDKEventListener)
        result.success(null)
    }
}