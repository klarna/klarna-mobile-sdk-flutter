package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.KlarnaPostPurchaseSDKHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchaseexperience.PostPurchaseExperienceHandler
import io.flutter.plugin.common.MethodChannel

internal object MethodCallHandlerManager {

    val methodHandlerMap: Map<String, MethodChannel.MethodCallHandler> = mapOf(
        "klarna_hybrid_sdk" to KlarnaHybridSDKHandler,
        "klarna_post_purchase_experience" to PostPurchaseExperienceHandler,
        "klarna_post_purchase_sdk" to KlarnaPostPurchaseSDKHandler
    )
}