package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.PostPurchaseExperienceHandler
import io.flutter.plugin.common.EventChannel

internal object StreamCallHandlerManager {

    val streamHandlerMap: Map<String, EventChannel.StreamHandler> = mapOf(
            "klarna_post_purchase_experience_events" to PostPurchaseExperienceHandler.eventStreamHandler,
            "klarna_post_purchase_experience_errors" to PostPurchaseExperienceHandler.errorStreamHandler
    )
}