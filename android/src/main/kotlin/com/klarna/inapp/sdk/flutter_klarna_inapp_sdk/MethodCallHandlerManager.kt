package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.KlarnaPostPurchaseSDKHandler
import io.flutter.plugin.common.MethodChannel

internal object MethodCallHandlerManager {

    val methodHandlerMap: Map<String, MethodChannel.MethodCallHandler> = mapOf(
        "klarna_post_purchase_sdk" to KlarnaPostPurchaseSDKHandler
    )
}