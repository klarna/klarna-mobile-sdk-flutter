package com.klarna.mobile.sdk.flutter

import com.klarna.mobile.sdk.flutter.postpurchase.callback.KlarnaPostPurchaseSDKCallbackHandler
import io.flutter.plugin.common.EventChannel

internal object StreamCallHandlerManager {

    val streamHandlerMap: Map<String, EventChannel.StreamHandler> = mapOf(
        "klarna_post_purchase_sdk_events" to KlarnaPostPurchaseSDKCallbackHandler
    )
}