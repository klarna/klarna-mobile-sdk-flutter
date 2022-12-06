package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.callback

import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseError
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseRenderResult

internal sealed class KlarnaPostPurchaseSDKCallbackEvent(
    val id: Int,
    val name: String
) {
    class OnInitialized(id: Int) : KlarnaPostPurchaseSDKCallbackEvent(id, "onInitialized")
    class OnAuthorizeRequested(id: Int) :
        KlarnaPostPurchaseSDKCallbackEvent(id, "onAuthorizeRequested")

    class OnRenderedOperation(
        id: Int,
        val renderResult: KlarnaPostPurchaseRenderResult
    ) : KlarnaPostPurchaseSDKCallbackEvent(id, "onRenderedOperation")

    class OnError(id: Int, val error: KlarnaPostPurchaseError) :
        KlarnaPostPurchaseSDKCallbackEvent(id, "onError")
}