package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.callback.KlarnaPostPurchaseSDKCallbackHandler
import io.flutter.plugin.common.EventChannel

internal object StreamCallHandlerManager {

    val streamHandlerMap: Map<String, EventChannel.StreamHandler> = mapOf(
        "klarna_post_purchase_sdk_events" to KlarnaPostPurchaseSDKCallbackHandler
    )
}