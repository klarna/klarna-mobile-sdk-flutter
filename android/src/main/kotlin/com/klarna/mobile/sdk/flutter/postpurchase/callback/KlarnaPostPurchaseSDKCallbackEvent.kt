package com.klarna.mobile.sdk.flutter.postpurchase.callback

import com.klarna.mobile.sdk.flutter.postpurchase.error.KlarnaPostPurchaseErrorWrapper
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

    class OnError(id: Int, val error: KlarnaPostPurchaseErrorWrapper) :
        KlarnaPostPurchaseSDKCallbackEvent(id, "onError")
}