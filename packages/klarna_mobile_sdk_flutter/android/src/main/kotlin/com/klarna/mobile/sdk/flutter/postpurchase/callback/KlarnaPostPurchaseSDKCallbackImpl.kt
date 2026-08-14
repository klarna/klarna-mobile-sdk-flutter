package com.klarna.mobile.sdk.flutter.postpurchase.callback

import com.klarna.mobile.sdk.flutter.core.util.ParserUtil
import com.klarna.mobile.sdk.flutter.postpurchase.error.KlarnaPostPurchaseErrorWrapper
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseError
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseRenderResult
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseSDK
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseSDKCallback

internal class KlarnaPostPurchaseSDKCallbackImpl(private val id: Int) :
    KlarnaPostPurchaseSDKCallback {

    override fun onInitialized(klarnaPostPurchaseSDK: KlarnaPostPurchaseSDK) {
        val event = KlarnaPostPurchaseSDKCallbackEvent.OnInitialized(id)
        KlarnaPostPurchaseSDKCallbackHandler.sendValue(ParserUtil.toJsonSafe(event))
    }

    override fun onAuthorizeRequested(klarnaPostPurchaseSDK: KlarnaPostPurchaseSDK) {
        val event = KlarnaPostPurchaseSDKCallbackEvent.OnAuthorizeRequested(id)
        KlarnaPostPurchaseSDKCallbackHandler.sendValue(ParserUtil.toJsonSafe(event))
    }

    override fun onRenderedOperation(
        klarnaPostPurchaseSDK: KlarnaPostPurchaseSDK,
        result: KlarnaPostPurchaseRenderResult
    ) {
        val event = KlarnaPostPurchaseSDKCallbackEvent.OnRenderedOperation(id, result)
        KlarnaPostPurchaseSDKCallbackHandler.sendValue(ParserUtil.toJsonSafe(event))
    }

    override fun onError(
        klarnaPostPurchaseSDK: KlarnaPostPurchaseSDK,
        error: KlarnaPostPurchaseError
    ) {
        val errorWrapper = KlarnaPostPurchaseErrorWrapper(
            error.name, error.message, error.status, error.isFatal
        )
        val event = KlarnaPostPurchaseSDKCallbackEvent.OnError(id, errorWrapper)
        KlarnaPostPurchaseSDKCallbackHandler.sendValue(ParserUtil.toJsonSafe(event))
    }
}