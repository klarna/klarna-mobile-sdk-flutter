package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKEventHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.callback.KlarnaPostPurchaseSDKCallbackHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchaseexperience.PostPurchaseExperienceEventHandler
import io.flutter.plugin.common.EventChannel

internal object StreamCallHandlerManager {

    val streamHandlerMap: Map<String, EventChannel.StreamHandler> = mapOf(
        "klarna_events" to EventCallbackHandler,
        "klarna_errors" to ErrorCallbackHandler,
        "klarna_hybrid_sdk_events" to KlarnaHybridSDKEventHandler,
        "klarna_post_purchase_experience_events" to PostPurchaseExperienceEventHandler,
        "klarna_post_purchase_sdk_events" to KlarnaPostPurchaseSDKCallbackHandler
    )
}