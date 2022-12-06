package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.callback

import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseError
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseRenderResult
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseSDK
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseSDKCallback

internal class KlarnaPostPurchaseSDKCallbackImpl(private val id: Int) :
    KlarnaPostPurchaseSDKCallback {

    override fun onInitialized(klarnaPostPurchaseSDK: KlarnaPostPurchaseSDK) {
        val event = KlarnaPostPurchaseSDKCallbackEvent.OnInitialized(id)
        KlarnaPostPurchaseSDKCallbackHandler.sendValue(event)
    }

    override fun onAuthorizeRequested(klarnaPostPurchaseSDK: KlarnaPostPurchaseSDK) {
        val event = KlarnaPostPurchaseSDKCallbackEvent.OnAuthorizeRequested(id)
        KlarnaPostPurchaseSDKCallbackHandler.sendValue(event)
    }

    override fun onRenderedOperation(
        klarnaPostPurchaseSDK: KlarnaPostPurchaseSDK,
        result: KlarnaPostPurchaseRenderResult
    ) {
        val event = KlarnaPostPurchaseSDKCallbackEvent.OnRenderedOperation(id, result)
        KlarnaPostPurchaseSDKCallbackHandler.sendValue(event)
    }

    override fun onError(
        klarnaPostPurchaseSDK: KlarnaPostPurchaseSDK,
        error: KlarnaPostPurchaseError
    ) {
        val event = KlarnaPostPurchaseSDKCallbackEvent.OnError(id, error)
        KlarnaPostPurchaseSDKCallbackHandler.sendValue(event)
    }
}